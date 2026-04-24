// Aguarda o DOM carregar
document.addEventListener('DOMContentLoaded', function () {

    // ── CPF ──────────────────────────────────────────────
    const cpf = document.querySelector('[data-mask="cpf"]');
    if (cpf) IMask(cpf, { mask: '000.000.000-00' });

    // ── CNPJ ─────────────────────────────────────────────
    const cnpj = document.querySelector('[data-mask="cnpj"]');
    if (cnpj) IMask(cnpj, { mask: '00.000.000/0000-00' });

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
    const cep = document.querySelector('[data-mask="cep"]');
    if (cep) IMask(cep, { mask: '00000-000' });

    // ── Placa (Mercosul e antiga) ─────────────────────────
    const placa = document.querySelector('[data-mask="placa"]');
    if (placa) {
        IMask(placa, {
            mask: [
                { mask: 'aaa0000' },   // antiga:   ABC1234
                { mask: 'aaa0a00' }    // Mercosul: ABC1D23
            ],
            prepare: function (str) { return str.toUpperCase(); }
        });
    }

    // ── Peso / Capacidade / Volume (decimais) ─────────────
    document.querySelectorAll('[data-mask="decimal"]').forEach(function (el) {
        IMask(el, {
            mask: Number,
            scale: 2,
            thousandsSeparator: '.',
            radix: ',',
            min: 0,
            max: 9999999
        });
    });

    // ── Ano ───────────────────────────────────────────────
    const ano = document.querySelector('[data-mask="ano"]');
    if (ano) IMask(ano, { mask: '0000' });
});