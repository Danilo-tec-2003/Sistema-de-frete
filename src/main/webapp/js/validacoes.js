const ufSelectors = [
  'input[name$="Uf"]',
  'input[id^="uf"]',
  'input[name^="uf"]',
  'input[name$="uf"]'
];

function normalizarUfInputs() {
  document.querySelectorAll(ufSelectors.join(',')).forEach((input) => {
    input.setAttribute('maxlength', '2');
    input.addEventListener('input', () => {
      input.value = input.value.toUpperCase().replace(/[^A-Z]/g, '').slice(0, 2);
    });
  });
}

function autoHideAlerts() {
  document.querySelectorAll('.alert-sucesso').forEach((alerta) => {
    window.setTimeout(() => {
      alerta.style.transition = 'opacity .25s ease';
      alerta.style.opacity = '0';
    }, 3500);
  });
}

document.addEventListener('DOMContentLoaded', () => {
  normalizarUfInputs();
  autoHideAlerts();
});
