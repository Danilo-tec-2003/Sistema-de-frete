document.addEventListener('DOMContentLoaded', function () {

    // ── CPF ──────────────────────────────────────────────
    var cpfEl = document.querySelector('[data-mask="cpf"]');
    if (cpfEl) IMask(cpfEl, { mask: '000.000.000-00' });

    // ── CNPJ ─────────────────────────────────────────────
    var cnpjEl = document.querySelector('[data-mask="cnpj"]');
    if (cnpjEl) IMask(cnpjEl, { mask: '00.000.000/0000-00' });

    // ── Telefone (fixo e celular) ─────────────────────────
    document.querySelectorAll('[data-mask="telefone"]').forEach(function (el) {
        IMask(el, {
            mask: [
                { mask: '(00) 0000-0000' },
                { mask: '(00) 00000-0000' }
            ]
        });
    });

    // ── CEP ───────────────────────────────────────────────
    var cepEl = document.querySelector('[data-mask="cep"]');
    if (cepEl) IMask(cepEl, { mask: '00000-000' });

    // ── Placa (Mercosul e antiga) ─────────────────────────
    var placaEl = document.querySelector('[data-mask="placa"]');
    if (placaEl) {
        IMask(placaEl, {
            mask: [
                { mask: 'aaa0000' },   // antiga:   ABC1234
                { mask: 'aaa0a00' }    // Mercosul: ABC1D23
            ],
            prepare: function (str) { return str.toUpperCase(); }
        });
    }

    // ── Peso / Capacidade / Volume (decimais) ─────────────
    // CORREÇÃO 1: o valor inicial vindo do Java usa '.' como decimal
    // (BigDecimal.toString() → "8000.50"), mas o IMask exige ',' (radix pt-BR).
    // Convertemos antes de aplicar a máscara para o campo exibir corretamente.
    //
    // CORREÇÃO 2: ao submeter o formulário o IMask produz "8.000,50",
    // que o Java não consegue parsear. O listener 'submit' converte de volta
    // para "8000.50" antes do envio.
    document.querySelectorAll('[data-mask="decimal"]').forEach(function (el) {
        if (el.value) {
            // "8000.50" → "8000,50"  (apenas o primeiro ponto é o decimal)
            el.value = el.value.replace('.', ',');
        }
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

    // Conversão decimal pt-BR → Java antes do submit
    document.querySelectorAll('form').forEach(function (form) {
        form.addEventListener('submit', function () {
            form.querySelectorAll('[data-mask="decimal"]').forEach(function (el) {
                // "8.000,50" → remove milhares → "8000,50" → troca radix → "8000.50"
                el.value = el.value.replace(/\./g, '').replace(',', '.');
            });
        });
    });

    // ── Ano ───────────────────────────────────────────────
    var anoEl = document.querySelector('[data-mask="ano"]');
    if (anoEl) IMask(anoEl, { mask: '0000' });
});