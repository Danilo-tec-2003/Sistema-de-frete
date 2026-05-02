document.addEventListener('DOMContentLoaded', function () {
    'use strict';

    var HAS_IMASK = typeof window.IMask === 'function';

    function digitsOnly(value) {
        return (value || '').replace(/\D/g, '');
    }

    function limitDigits(value, maxDigits) {
        if (!maxDigits) return value;
        var digits = digitsOnly(value).slice(0, maxDigits);
        return digits;
    }

    function allowPersonName(value) {
        return (value || '')
            .replace(/[^A-Za-zÀ-ÿ\s'-]/g, '')
            .replace(/\s{2,}/g, ' ');
    }

    function allowCity(value) {
        return (value || '')
            .replace(/[^A-Za-zÀ-ÿ\s'-]/g, '')
            .replace(/\s{2,}/g, ' ');
    }

    function allowText(value) {
        return (value || '')
            .replace(/[^0-9A-Za-zÀ-ÿ\s.,:/()\-']/g, '')
            .replace(/\s{2,}/g, ' ');
    }

    function allowAlphaNum(value) {
        return (value || '')
            .replace(/[^0-9A-Za-zÀ-ÿ\s\-/.]/g, '')
            .replace(/\s{2,}/g, ' ');
    }

    function allowUpperCode(value, maxChars) {
        var clean = (value || '').toUpperCase().replace(/[^A-Z0-9]/g, '');
        return maxChars ? clean.slice(0, maxChars) : clean;
    }

    function formatCpf(value) {
        var d = digitsOnly(value).slice(0, 11);
        if (d.length > 9) return d.replace(/(\d{3})(\d{3})(\d{3})(\d{0,2}).*/, '$1.$2.$3-$4');
        if (d.length > 6) return d.replace(/(\d{3})(\d{3})(\d{0,3}).*/, '$1.$2.$3');
        if (d.length > 3) return d.replace(/(\d{3})(\d{0,3}).*/, '$1.$2');
        return d;
    }

    function formatCnpj(value) {
        var d = digitsOnly(value).slice(0, 14);
        if (d.length > 12) return d.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{0,2}).*/, '$1.$2.$3/$4-$5');
        if (d.length > 8) return d.replace(/(\d{2})(\d{3})(\d{3})(\d{0,4}).*/, '$1.$2.$3/$4');
        if (d.length > 5) return d.replace(/(\d{2})(\d{3})(\d{0,3}).*/, '$1.$2.$3');
        if (d.length > 2) return d.replace(/(\d{2})(\d{0,3}).*/, '$1.$2');
        return d;
    }

    function formatCpfCnpj(value) {
        var d = digitsOnly(value);
        return d.length <= 11 ? formatCpf(d) : formatCnpj(d);
    }

    function formatCep(value) {
        var d = digitsOnly(value).slice(0, 8);
        return d.length > 5 ? d.replace(/(\d{5})(\d{0,3}).*/, '$1-$2') : d;
    }

    function formatPhone(value) {
        var d = digitsOnly(value).slice(0, 11);
        if (d.length > 10) return d.replace(/(\d{2})(\d{5})(\d{0,4}).*/, '($1) $2-$3');
        if (d.length > 6) return d.replace(/(\d{2})(\d{4,5})(\d{0,4}).*/, '($1) $2-$3');
        if (d.length > 2) return d.replace(/(\d{2})(\d{0,5}).*/, '($1) $2');
        return d;
    }

    function formatDecimal(value, maxDigits) {
        var clean = (value || '').replace(/[^\d,]/g, '');
        var parts = clean.split(',');
        var integerPart = digitsOnly(parts[0]);
        var decimalPart = digitsOnly(parts[1] || '').slice(0, 2);

        if (maxDigits && integerPart.length + decimalPart.length > maxDigits) {
            var allowedIntegers = Math.max(0, maxDigits - decimalPart.length);
            integerPart = integerPart.slice(0, allowedIntegers);
        }

        var formattedInt = integerPart.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
        return decimalPart.length > 0 ? formattedInt + ',' + decimalPart : formattedInt;
    }

    function isValidCpf(value) {
        var nums = digitsOnly(value);
        if (nums.length !== 11 || /^(\d)\1{10}$/.test(nums)) return false;

        var soma = 0;
        for (var i = 0; i < 9; i++) soma += parseInt(nums.charAt(i), 10) * (10 - i);
        var r1 = (soma * 10) % 11;
        if (r1 === 10) r1 = 0;
        if (r1 !== parseInt(nums.charAt(9), 10)) return false;

        soma = 0;
        for (i = 0; i < 10; i++) soma += parseInt(nums.charAt(i), 10) * (11 - i);
        var r2 = (soma * 10) % 11;
        if (r2 === 10) r2 = 0;
        return r2 === parseInt(nums.charAt(10), 10);
    }

    function isValidCnpj(value) {
        var nums = digitsOnly(value);
        if (nums.length !== 14 || /^(\d)\1{13}$/.test(nums)) return false;

        var pesos1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
        var pesos2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
        var soma = 0;
        var i;

        for (i = 0; i < 12; i++) soma += parseInt(nums.charAt(i), 10) * pesos1[i];
        var r1 = soma % 11;
        r1 = r1 < 2 ? 0 : 11 - r1;
        if (r1 !== parseInt(nums.charAt(12), 10)) return false;

        soma = 0;
        for (i = 0; i < 13; i++) soma += parseInt(nums.charAt(i), 10) * pesos2[i];
        var r2 = soma % 11;
        r2 = r2 < 2 ? 0 : 11 - r2;
        return r2 === parseInt(nums.charAt(13), 10);
    }

    function setFieldError(el, message) {
        el.setCustomValidity(message || '');
        el.classList.toggle('campo-erro', !!message);
    }

    function validateField(el) {
        var value = (el.value || '').trim();
        var validator = el.getAttribute('data-validate');
        var required = el.hasAttribute('required');

        if (!validator || (!required && value === '')) {
            setFieldError(el, '');
            return true;
        }

        if (required && value === '') {
            setFieldError(el, 'Preencha este campo.');
            return false;
        }

        if (validator === 'cpf' && !isValidCpf(value)) {
            setFieldError(el, 'Informe um CPF valido no formato 000.000.000-00.');
            return false;
        }
        if (validator === 'cnpj' && !isValidCnpj(value)) {
            setFieldError(el, 'Informe um CNPJ valido no formato 00.000.000/0000-00.');
            return false;
        }
        if (validator === 'cpf-cnpj') {
            var docDigits = digitsOnly(value);
            if (docDigits.length === 11 && !isValidCpf(value)) {
                setFieldError(el, 'Informe um CPF valido no formato 000.000.000-00.');
                return false;
            }
            if (docDigits.length === 14 && !isValidCnpj(value)) {
                setFieldError(el, 'Informe um CNPJ valido no formato 00.000.000/0000-00.');
                return false;
            }
            if (docDigits.length !== 11 && docDigits.length !== 14) {
                setFieldError(el, 'Informe um CPF com 11 digitos ou CNPJ com 14 digitos.');
                return false;
            }
        }
        if (validator === 'telefone') {
            var telDigits = digitsOnly(value);
            if (telDigits.length !== 10 && telDigits.length !== 11) {
                setFieldError(el, 'Informe um telefone valido com DDD.');
                return false;
            }
        }
        if (validator === 'cep' && digitsOnly(value).length !== 8) {
            setFieldError(el, 'Informe um CEP valido no formato 00000-000.');
            return false;
        }
        if (validator === 'placa') {
            var plate = allowUpperCode(value, 7);
            if (!/^[A-Z]{3}[0-9]{4}$/.test(plate) && !/^[A-Z]{3}[0-9][A-Z][0-9]{2}$/.test(plate)) {
                setFieldError(el, 'Informe uma placa valida no formato ABC1234 ou ABC1D23.');
                return false;
            }
        }
        if (validator === 'uf') {
            if (!/^[A-Z]{2}$/.test(value.toUpperCase())) {
                setFieldError(el, 'Informe a UF com 2 letras.');
                return false;
            }
        }
        if (validator === 'email' && value !== '') {
            if (!/^[\w._%+\-]+@[\w.\-]+\.[A-Za-z]{2,}$/.test(value)) {
                setFieldError(el, 'Informe um e-mail valido.');
                return false;
            }
        }

        setFieldError(el, '');
        return true;
    }

    function attachSanitizer(selector, fn) {
        document.querySelectorAll(selector).forEach(function (el) {
            el.addEventListener('input', function () {
                var start = el.selectionStart;
                var before = el.value;
                el.value = fn(el.value);
                if (before !== el.value && typeof start === 'number') {
                    el.setSelectionRange(el.value.length, el.value.length);
                }
                validateField(el);
            });
            el.addEventListener('blur', function () {
                el.value = fn(el.value).trim();
                validateField(el);
            });
        });
    }

    function applyMasksWithoutIMask() {
        attachSanitizer('[data-mask="cpf"]', formatCpf);
        attachSanitizer('[data-mask="cnpj"]', formatCnpj);
        attachSanitizer('[data-mask="cpf-cnpj"]', formatCpfCnpj);
        attachSanitizer('[data-mask="cep"]', formatCep);
        attachSanitizer('[data-mask="telefone"]', formatPhone);
        attachSanitizer('[data-mask="placa"]', function (value) {
            return allowUpperCode(value, 7);
        });
        attachSanitizer('[data-mask="ano"]', function (value) {
            return digitsOnly(value).slice(0, 4);
        });
        attachSanitizer('[data-mask="uf"]', function (value) {
            return allowUpperCode(value, 2);
        });
        document.querySelectorAll('[data-mask="decimal"]').forEach(function (el) {
            el.addEventListener('input', function () {
                var maxDigits = parseInt(el.getAttribute('data-max-digits'), 10) || 12;
                el.value = formatDecimal(el.value, maxDigits);
            });
            el.addEventListener('blur', function () {
                var maxDigits = parseInt(el.getAttribute('data-max-digits'), 10) || 12;
                el.value = formatDecimal(el.value, maxDigits);
            });
        });
    }

    if (HAS_IMASK) {
        document.querySelectorAll('[data-mask="cpf"]').forEach(function (el) {
            IMask(el, { mask: '000.000.000-00' });
        });
        document.querySelectorAll('[data-mask="cnpj"]').forEach(function (el) {
            IMask(el, { mask: '00.000.000/0000-00' });
        });
        document.querySelectorAll('[data-mask="cpf-cnpj"]').forEach(function (el) {
            IMask(el, {
                mask: [
                    { mask: '000.000.000-00' },
                    { mask: '00.000.000/0000-00' }
                ],
                dispatch: function (appended, dynamicMasked) {
                    var value = (dynamicMasked.value + appended).replace(/\D/g, '');
                    return dynamicMasked.compiledMasks[value.length > 11 ? 1 : 0];
                }
            });
        });
        document.querySelectorAll('[data-mask="telefone"]').forEach(function (el) {
            IMask(el, {
                mask: [
                    { mask: '(00) 0000-0000' },
                    { mask: '(00) 00000-0000' }
                ]
            });
        });
        document.querySelectorAll('[data-mask="cep"]').forEach(function (el) {
            IMask(el, { mask: '00000-000' });
        });
        document.querySelectorAll('[data-mask="placa"]').forEach(function (el) {
            IMask(el, {
                mask: [
                    { mask: 'aaa0000' },
                    { mask: 'aaa0a00' }
                ],
                prepare: function (str) { return str.toUpperCase(); }
            });
        });
        document.querySelectorAll('[data-mask="ano"]').forEach(function (el) {
            IMask(el, { mask: '0000' });
        });
        document.querySelectorAll('[data-mask="decimal"]').forEach(function (el) {
            if (el.value) el.value = el.value.replace('.', ',');
            IMask(el, {
                mask: Number,
                scale: 2,
                padFractionalZeros: true,
                normalizeZeros: true,
                thousandsSeparator: '.',
                radix: ',',
                min: 0
            });
        });
    } else {
        applyMasksWithoutIMask();
    }

    attachSanitizer('[data-allow="person-name"]', allowPersonName);
    attachSanitizer('[data-allow="city"]', allowCity);
    attachSanitizer('[data-allow="text"]', allowText);
    attachSanitizer('[data-allow="alphanum"]', allowAlphaNum);
    attachSanitizer('[data-mask="uf"]', function (value) { return allowUpperCode(value, 2); });

    document.querySelectorAll('[data-max-digits]').forEach(function (el) {
        el.addEventListener('input', function () {
            var maxDigits = parseInt(el.getAttribute('data-max-digits'), 10);
            var raw = el.value;
            if (el.getAttribute('data-mask') === 'decimal') {
                var cleaned = raw.replace(/[^\d,.-]/g, '');
                var digits = digitsOnly(cleaned);
                if (digits.length > maxDigits) {
                    var extra = digits.length - maxDigits;
                    var trimmed = digits.slice(0, maxDigits);
                    if (cleaned.indexOf(',') >= 0) {
                        var decimalDigits = cleaned.split(',')[1] || '';
                        var intDigitsCount = trimmed.length - Math.min(decimalDigits.length, 2);
                        var intPart = trimmed.slice(0, Math.max(0, intDigitsCount));
                        var fracPart = trimmed.slice(intPart.length);
                        el.value = intPart + (fracPart ? ',' + fracPart : '');
                    } else {
                        el.value = trimmed;
                    }
                }
            } else {
                var limited = digitsOnly(raw).slice(0, maxDigits);
                if (digitsOnly(raw) !== limited) el.value = limited;
            }
        });
    });

    document.querySelectorAll('input[maxlength], textarea[maxlength]').forEach(function (el) {
        el.addEventListener('input', function () {
            var maxLength = parseInt(el.getAttribute('maxlength'), 10);
            if (el.value.length > maxLength) {
                el.value = el.value.slice(0, maxLength);
            }
        });
    });

    document.querySelectorAll('input, textarea, select').forEach(function (el) {
        el.addEventListener('blur', function () { validateField(el); });
        el.addEventListener('input', function () { validateField(el); });
        el.addEventListener('change', function () { validateField(el); });
    });

    document.querySelectorAll('form').forEach(function (form) {
        form.addEventListener('submit', function (e) {
            var invalid = false;

            form.querySelectorAll('[data-validate]').forEach(function (el) {
                if (!validateField(el)) invalid = true;
            });

            form.querySelectorAll('[data-mask="decimal"]').forEach(function (el) {
                el.value = el.value.replace(/\./g, '').replace(',', '.');
            });

            if (invalid) {
                e.preventDefault();
                if (typeof form.reportValidity === 'function') form.reportValidity();
            }
        });
    });
});
