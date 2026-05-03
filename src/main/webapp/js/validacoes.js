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

function labelDoCampo(campo) {
  const id = campo.getAttribute('id');
  const label = id ? document.querySelector(`label[for="${id}"]`) : null;
  if (label) return label.textContent.replace('*', '').trim();
  const labelGrupo = campo.closest('.form-group')?.querySelector('label');
  if (labelGrupo) return labelGrupo.textContent.replace('*', '').trim();
  return campo.getAttribute('aria-label') || campo.getAttribute('name') || 'Campo';
}

function digitsOnly(value) {
  return (value || '').replace(/\D/g, '');
}

function isValidCpf(value) {
  const nums = digitsOnly(value);
  if (nums.length !== 11 || /^(\d)\1{10}$/.test(nums)) return false;
  let soma = 0;
  for (let i = 0; i < 9; i += 1) soma += parseInt(nums.charAt(i), 10) * (10 - i);
  let r1 = (soma * 10) % 11;
  if (r1 === 10) r1 = 0;
  if (r1 !== parseInt(nums.charAt(9), 10)) return false;
  soma = 0;
  for (let i = 0; i < 10; i += 1) soma += parseInt(nums.charAt(i), 10) * (11 - i);
  let r2 = (soma * 10) % 11;
  if (r2 === 10) r2 = 0;
  return r2 === parseInt(nums.charAt(10), 10);
}

function isValidCnpj(value) {
  const nums = digitsOnly(value);
  if (nums.length !== 14 || /^(\d)\1{13}$/.test(nums)) return false;
  const pesos1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  const pesos2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  let soma = 0;
  for (let i = 0; i < 12; i += 1) soma += parseInt(nums.charAt(i), 10) * pesos1[i];
  let r1 = soma % 11;
  r1 = r1 < 2 ? 0 : 11 - r1;
  if (r1 !== parseInt(nums.charAt(12), 10)) return false;
  soma = 0;
  for (let i = 0; i < 13; i += 1) soma += parseInt(nums.charAt(i), 10) * pesos2[i];
  let r2 = soma % 11;
  r2 = r2 < 2 ? 0 : 11 - r2;
  return r2 === parseInt(nums.charAt(13), 10);
}

function mensagemCampo(campo) {
  if (campo.disabled || campo.type === 'hidden' || campo.type === 'button') return '';

  const valor = (campo.value || '').trim();
  const nome = labelDoCampo(campo);

  if (campo.required && !valor) return `${nome} é obrigatório.`;

  const minLength = parseInt(campo.getAttribute('minlength'), 10);
  if (valor && minLength && valor.length < minLength) {
    return `${nome} deve ter pelo menos ${minLength} caracteres.`;
  }

  const maxLength = parseInt(campo.getAttribute('maxlength'), 10);
  if (valor && maxLength && valor.length > maxLength) {
    return `${nome} deve ter no máximo ${maxLength} caracteres.`;
  }

  const matchSelector = campo.getAttribute('data-match');
  if (matchSelector) {
    const alvo = document.querySelector(matchSelector);
    if (alvo && valor !== (alvo.value || '')) {
      return campo.getAttribute('data-match-message') || `${nome} não confere.`;
    }
  }

  if (campo.type === 'email' && valor && !/^[\w._%+\-]+@[\w.\-]+\.[A-Za-z]{2,}$/.test(valor)) {
    return `${nome} deve ser um e-mail válido.`;
  }

  const validator = campo.getAttribute('data-validate');
  if (validator === 'cpf' && valor && !isValidCpf(valor)) {
    return `${nome} deve conter um CPF válido.`;
  }
  if (validator === 'cnpj' && valor && !isValidCnpj(valor)) {
    return `${nome} deve conter um CNPJ válido.`;
  }
  if (validator === 'cpf-cnpj' && valor) {
    const doc = digitsOnly(valor);
    if (doc.length === 11 && !isValidCpf(valor)) return `${nome} deve conter um CPF válido.`;
    if (doc.length === 14 && !isValidCnpj(valor)) return `${nome} deve conter um CNPJ válido.`;
    if (doc.length !== 11 && doc.length !== 14) return `${nome} deve ter 11 dígitos para CPF ou 14 para CNPJ.`;
  }
  if (validator === 'telefone' && valor) {
    const tel = digitsOnly(valor);
    if (tel.length !== 10 && tel.length !== 11) return `${nome} deve conter telefone com DDD.`;
  }
  if (validator === 'cep' && valor && digitsOnly(valor).length !== 8) {
    return `${nome} deve estar no formato 00000-000.`;
  }
  if (validator === 'cnh' && valor) {
    const cnh = digitsOnly(valor);
    if (cnh.length !== 11 || /^(\d)\1{10}$/.test(cnh)) {
      return `${nome} deve conter 11 dígitos numéricos.`;
    }
  }
  if (validator === 'placa' && valor) {
    const placa = valor.toUpperCase().replace(/[^A-Z0-9]/g, '');
    if (!/^[A-Z]{3}[0-9]{4}$/.test(placa) && !/^[A-Z]{3}[0-9][A-Z][0-9]{2}$/.test(placa)) {
      return `${nome} deve estar no formato ABC1234 ou ABC1D23.`;
    }
  }
  if (validator === 'uf' && valor && !/^[A-Z]{2}$/.test(valor.toUpperCase())) {
    return `${nome} deve conter 2 letras.`;
  }

  if (campo.type === 'date' && valor) {
    const min = campo.getAttribute('min');
    const max = campo.getAttribute('max');
    if (min && valor < min) return `${nome} não pode ser anterior a ${min}.`;
    if (max && valor > max) return `${nome} não pode ser posterior a ${max}.`;
  }

  return '';
}

function containerDoCampo(campo) {
  return campo.closest('.form-group') || campo.parentElement || campo;
}

function setErroCampo(campo, mensagem) {
  campo.classList.toggle('campo-erro', !!mensagem);
  campo.setAttribute('aria-invalid', mensagem ? 'true' : 'false');

  const container = containerDoCampo(campo);
  let msg = container.querySelector(':scope > .msg-erro-campo');
  if (!msg && mensagem) {
    msg = document.createElement('span');
    msg.className = 'msg-erro-campo';
    container.appendChild(msg);
  }
  if (msg) {
    msg.textContent = mensagem || '';
    msg.classList.toggle('visivel', !!mensagem);
  }
}

function alertaFormulario(form, mensagem) {
  let alerta = form.parentElement.querySelector(':scope > .fm-client-alert');
  if (!alerta) {
    alerta = document.createElement('div');
    alerta.className = 'alert alert-erro fm-client-alert';
    alerta.setAttribute('role', 'alert');
    form.parentElement.insertBefore(alerta, form);
  }
  alerta.textContent = mensagem;
  alerta.hidden = false;
  alerta.scrollIntoView({ behavior: 'smooth', block: 'center' });
}

function limparAlertaFormulario(form) {
  const alerta = form.parentElement.querySelector(':scope > .fm-client-alert');
  if (alerta) alerta.hidden = true;
}

function validarFormulario(form) {
  let primeiroInvalido = null;
  let primeiraMensagem = '';

  form.querySelectorAll('input, select, textarea').forEach((campo) => {
    const mensagem = mensagemCampo(campo);
    setErroCampo(campo, mensagem);
    if (mensagem && !primeiroInvalido) {
      primeiroInvalido = campo;
      primeiraMensagem = mensagem;
    }
  });

  if (primeiroInvalido) {
    alertaFormulario(form, primeiraMensagem);
    primeiroInvalido.focus({ preventScroll: true });
    return false;
  }

  limparAlertaFormulario(form);
  return true;
}

function configurarValidacaoFormulario() {
  document.querySelectorAll('form').forEach((form) => {
    form.noValidate = true;
    form.addEventListener('submit', (event) => {
      if (!validarFormulario(form)) {
        event.preventDefault();
        event.stopImmediatePropagation();
      }
    }, true);
  });

  document.addEventListener('input', (event) => {
    const campo = event.target.closest('input, select, textarea');
    if (!campo || !campo.form) return;
    setErroCampo(campo, mensagemCampo(campo));
    if (!campo.form.querySelector('.campo-erro')) limparAlertaFormulario(campo.form);
  });

  document.addEventListener('change', (event) => {
    const campo = event.target.closest('input, select, textarea');
    if (!campo || !campo.form) return;
    setErroCampo(campo, mensagemCampo(campo));
  });
}

function criarModalConfirmacao() {
  let modal = document.getElementById('fm-confirm-modal');
  if (modal) return modal;

  modal = document.createElement('div');
  modal.id = 'fm-confirm-modal';
  modal.className = 'fm-confirm-modal';
  modal.innerHTML = `
    <div class="fm-confirm-dialog" role="dialog" aria-modal="true" aria-labelledby="fm-confirm-title">
      <h3 id="fm-confirm-title">Confirmar ação</h3>
      <p id="fm-confirm-message"></p>
      <div class="fm-confirm-actions">
        <button type="button" class="btn btn-secondary" data-fm-confirm-cancel>Cancelar</button>
        <button type="button" class="btn btn-danger" data-fm-confirm-ok>Confirmar</button>
      </div>
    </div>`;
  document.body.appendChild(modal);
  return modal;
}

function abrirConfirmacao(mensagem, aoConfirmar) {
  const modal = criarModalConfirmacao();
  modal.querySelector('#fm-confirm-message').textContent = mensagem;
  modal.classList.add('ativo');

  const btnOk = modal.querySelector('[data-fm-confirm-ok]');
  const btnCancel = modal.querySelector('[data-fm-confirm-cancel]');

  const fechar = () => {
    modal.classList.remove('ativo');
    btnOk.onclick = null;
    btnCancel.onclick = null;
  };

  btnCancel.onclick = fechar;
  btnOk.onclick = () => {
    fechar();
    aoConfirmar();
  };
}

function configurarConfirmacoes() {
  document.addEventListener('click', (event) => {
    const alvo = event.target.closest('[data-confirm]');
    if (!alvo || alvo.dataset.confirmed === 'true') return;

    event.preventDefault();
    const mensagem = alvo.getAttribute('data-confirm') || 'Confirma esta ação?';

    if (alvo.form && !validarFormulario(alvo.form)) return;

    abrirConfirmacao(mensagem, () => {
      alvo.dataset.confirmed = 'true';
      if (alvo.tagName === 'A') {
        window.location.href = alvo.href;
        return;
      }
      if (alvo.form) {
        if (typeof alvo.form.requestSubmit === 'function') alvo.form.requestSubmit(alvo);
        else alvo.form.submit();
      }
      window.setTimeout(() => { delete alvo.dataset.confirmed; }, 0);
    });
  });
}

window.FiscalMoveUI = {
  showFormError: alertaFormulario,
  clearFormError: limparAlertaFormulario
};

document.addEventListener('DOMContentLoaded', () => {
  normalizarUfInputs();
  autoHideAlerts();
  configurarValidacaoFormulario();
  configurarConfirmacoes();
});
