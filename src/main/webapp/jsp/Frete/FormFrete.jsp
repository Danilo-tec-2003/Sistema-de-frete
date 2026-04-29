<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Novo Frete – FiscalMove FMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Exo+2:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/validacoes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/componentes.css">
    <style>
        /* Estilos inline para validação — mover para validacoes.css após revisão */
        .campo-erro { border-color: #e53e3e !important; }
        .msg-erro-campo {
            color: #e53e3e;
            font-size: 0.78rem;
            margin-top: 4px;
            display: none;
        }
        .msg-erro-campo.visivel { display: block; }
        #alerta-validacao {
            background: #fff5f5;
            border: 1px solid #fc8181;
            border-radius: 6px;
            padding: 12px 16px;
            margin-bottom: 16px;
            display: none;
        }
        #alerta-validacao.visivel { display: block; }
        #alerta-validacao ul { margin: 8px 0 0 16px; padding: 0; }
        #alerta-validacao li { margin: 4px 0; font-size: 0.9rem; }
        .aviso-igual {
            background: #fffbeb;
            border: 1px solid #f6ad55;
            border-radius: 4px;
            padding: 6px 10px;
            font-size: 0.82rem;
            margin-top: 4px;
            display: none;
        }
        .aviso-igual.visivel { display: block; }
    </style>
</head>
<body>
<%@ include file="/jsp/NavBar.jsp" %>

<div class="main-wrapper">

    <div class="topbar">
        <div class="topbar-title">Emitir Frete</div>
        <div class="topbar-actions">
            <a href="${pageContext.request.contextPath}/fretes" class="btn btn-secondary">&larr; Voltar</a>
        </div>
    </div>

    <div class="container">

        <%-- Erro vindo do backend (após submit) --%>
        <c:if test="${not empty erro}">
            <div class="alert alert-erro" role="alert">${erro}</div>
        </c:if>

        <%-- Alerta de validação frontend (preenchido via JS) --%>
        <div id="alerta-validacao" role="alert">
            <strong>⚠ Corrija os seguintes itens antes de continuar:</strong>
            <ul id="lista-erros-validacao"></ul>
        </div>

        <div class="card">
            <form method="post" action="${pageContext.request.contextPath}/fretes"
                  novalidate id="form-frete">
                <input type="hidden" name="acao" value="emitir">

                <%-- ==============================================
                     PARTES
                     ============================================== --%>
                <h3 class="secao-titulo">Partes</h3>
                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="idRemetente">Remetente <span class="obrigatorio">*</span></label>
                        <select id="idRemetente" name="idRemetente" class="form-control">
                            <option value="">Selecione o remetente...</option>
                            <c:forEach var="c" items="${clientes}">
                                <option value="${c.id}"
                                    <c:if test="${frete.idRemetente == c.id}">selected</c:if>>
                                    ${c.razaoSocial}<c:if test="${not empty c.cnpj}"> — ${c.cnpj}</c:if>
                                </option>
                            </c:forEach>
                        </select>
                        <span class="msg-erro-campo" id="err-remetente">Selecione o remetente.</span>
                    </div>
                    <div class="form-group">
                        <label for="idDestinatario">Destinatário <span class="obrigatorio">*</span></label>
                        <select id="idDestinatario" name="idDestinatario" class="form-control">
                            <option value="">Selecione o destinatário...</option>
                            <c:forEach var="c" items="${clientes}">
                                <option value="${c.id}"
                                    <c:if test="${frete.idDestinatario == c.id}">selected</c:if>>
                                    ${c.razaoSocial}<c:if test="${not empty c.cnpj}"> — ${c.cnpj}</c:if>
                                </option>
                            </c:forEach>
                        </select>
                        <span class="msg-erro-campo" id="err-destinatario">Selecione o destinatário.</span>
                        <%-- CORREÇÃO: aviso imediato ao selecionar remetente == destinatário --%>
                        <div class="aviso-igual" id="aviso-rem-igual">
                            ⚠ Remetente e Destinatário não podem ser o mesmo cliente.
                        </div>
                    </div>
                </div>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="idMotorista">Motorista <span class="obrigatorio">*</span></label>
                        <select id="idMotorista" name="idMotorista" class="form-control">
                            <option value="">Selecione o motorista...</option>
                            <c:forEach var="m" items="${motoristas}">
                                <option value="${m.id}"
                                    <c:if test="${frete.idMotorista == m.id}">selected</c:if>>
                                    ${m.nome} — CPF: ${m.cpf}
                                </option>
                            </c:forEach>
                        </select>
                        <span class="msg-erro-campo" id="err-motorista">Selecione o motorista.</span>
                    </div>
                    <div class="form-group">
                        <label for="idVeiculo">Veículo <span class="obrigatorio">*</span></label>
                        <select id="idVeiculo" name="idVeiculo" class="form-control">
                            <option value="">Selecione o veículo...</option>
                            <c:forEach var="v" items="${veiculos}">
                                <option value="${v.id}"
                                    data-capacidade="${v.capacidadeKg}"
                                    <c:if test="${frete.idVeiculo == v.id}">selected</c:if>>
                                    ${v.placa} — ${v.tipo.descricao}
                                    <c:if test="${not empty v.capacidadeKg}">
                                        (cap. ${v.capacidadeKg} kg)
                                    </c:if>
                                </option>
                            </c:forEach>
                        </select>
                        <small class="campo-hint">Somente veículos Disponíveis são listados.</small>
                        <span class="msg-erro-campo" id="err-veiculo">Selecione o veículo.</span>
                    </div>
                </div>

                <%-- ==============================================
                     ROTA
                     ============================================== --%>
                <h3 class="secao-titulo">Rota</h3>
                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="municipioOrigem">Município de Origem <span class="obrigatorio">*</span></label>
                        <input type="text" id="municipioOrigem" name="municipioOrigem"
                               value="${frete.municipioOrigem}" class="form-control"
                               maxlength="80" placeholder="Ex: Recife">
                        <span class="msg-erro-campo" id="err-mun-orig">Informe o município de origem.</span>
                    </div>
                    <div class="form-group">
                        <label for="ufOrigem">UF Origem <span class="obrigatorio">*</span></label>
                        <%-- CORREÇÃO: select de UF em vez de input livre — elimina erros de digitação --%>
                        <select id="ufOrigem" name="ufOrigem" class="form-control">
                            <option value="">UF...</option>
                        </select>
                        <span class="msg-erro-campo" id="err-uf-orig">Selecione a UF de origem.</span>
                    </div>
                </div>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="municipioDestino">Município de Destino <span class="obrigatorio">*</span></label>
                        <input type="text" id="municipioDestino" name="municipioDestino"
                               value="${frete.municipioDestino}" class="form-control"
                               maxlength="80" placeholder="Ex: São Paulo">
                        <span class="msg-erro-campo" id="err-mun-dest">Informe o município de destino.</span>
                    </div>
                    <div class="form-group">
                        <label for="ufDestino">UF Destino <span class="obrigatorio">*</span></label>
                        <select id="ufDestino" name="ufDestino" class="form-control">
                            <option value="">UF...</option>
                        </select>
                        <span class="msg-erro-campo" id="err-uf-dest">Selecione a UF de destino.</span>
                    </div>
                </div>

                <%-- ==============================================
                     CARGA
                     ============================================== --%>
                <h3 class="secao-titulo">Carga</h3>

                <%-- CORREÇÃO: campo descricaoCarga estava ausente no formulário original --%>
                <div class="form-group">
                    <label for="descricaoCarga">
                        Descrição da Carga <span class="obrigatorio">*</span>
                    </label>
                    <input type="text" id="descricaoCarga" name="descricaoCarga"
                           value="${frete.descricaoCarga}" class="form-control"
                           maxlength="200"
                           placeholder="Ex: Eletrônicos, Alimentos não perecíveis, Maquinário">
                    <small class="campo-hint">Informe o tipo de mercadoria transportada.</small>
                    <span class="msg-erro-campo" id="err-carga">Informe a descrição da carga.</span>
                </div>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="pesoKg">Peso (kg)</label>
                        <input type="number" id="pesoKg" name="pesoKg"
                               value="${frete.pesoKg ne 0 ? frete.pesoKg : ''}"
                               class="form-control" step="0.01" min="0.01"
                               placeholder="Ex: 1500.00">
                        <small class="campo-hint" id="hint-capacidade"></small>
                        <span class="msg-erro-campo" id="err-peso"></span>
                    </div>
                    <div class="form-group">
                        <label for="volumes">Volumes</label>
                        <input type="number" id="volumes" name="volumes"
                               value="${frete.volumes}" class="form-control"
                               step="1" min="1" placeholder="Ex: 10">
                    </div>
                </div>

                <%-- ==============================================
                     VALORES
                     ============================================== --%>
                <h3 class="secao-titulo">Valores</h3>
                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="valorFrete">Valor do Frete (R$) <span class="obrigatorio">*</span></label>
                        <input type="number" id="valorFrete" name="valorFrete"
                               value="${frete.valorFrete ne 0 ? frete.valorFrete : ''}"
                               class="form-control" step="0.01" min="0.01"
                               placeholder="Ex: 2500.00">
                        <span class="msg-erro-campo" id="err-valor">
                            O valor do frete deve ser maior que zero.
                        </span>
                    </div>
                    <div class="form-group">
                        <label for="dataPrevEntrega">
                            Data Prev. Entrega <span class="obrigatorio">*</span>
                        </label>
                        <%-- CORREÇÃO: min definido via JS para garantir data >= hoje --%>
                        <input type="date" id="dataPrevEntrega" name="dataPrevEntrega"
                               value="${frete.dataPrevEntregaFormatada ne '' ? frete.dataPrevEntrega : ''}"
                               class="form-control">
                        <span class="msg-erro-campo" id="err-data">
                            Informe uma data igual ou posterior a hoje.
                        </span>
                    </div>
                </div>

                <div class="form-row cols-3">
                    <div class="form-group">
                        <label for="aliquotaIcms">Alíquota ICMS (%)</label>
                        <input type="number" id="aliquotaIcms" name="aliquotaIcms"
                               value="${frete.aliquotaIcms ne 0 ? frete.aliquotaIcms : ''}"
                               class="form-control" step="0.01" min="0" max="100"
                               placeholder="0,00">
                    </div>
                    <div class="form-group">
                        <label for="aliquotaIbs">Alíquota IBS (%)</label>
                        <input type="number" id="aliquotaIbs" name="aliquotaIbs"
                               value="${frete.aliquotaIbs ne 0 ? frete.aliquotaIbs : ''}"
                               class="form-control" step="0.01" min="0" max="100"
                               placeholder="0,00">
                    </div>
                    <div class="form-group">
                        <label for="aliquotaCbs">Alíquota CBS (%)</label>
                        <input type="number" id="aliquotaCbs" name="aliquotaCbs"
                               value="${frete.aliquotaCbs ne 0 ? frete.aliquotaCbs : ''}"
                               class="form-control" step="0.01" min="0" max="100"
                               placeholder="0,00">
                    </div>
                </div>

                <div class="info-calculada" id="preview-valores" style="display:none">
                    <strong>Preview de valores:</strong>
                    <span id="preview-icms"></span>
                    <span id="preview-ibs"></span>
                    <span id="preview-cbs"></span>
                    <span id="preview-total"></span>
                </div>

                <div class="form-group" style="margin-top:16px;">
                    <label for="observacao">Observações</label>
                    <textarea id="observacao" name="observacao" class="form-control"
                              rows="3" maxlength="1000">${frete.observacao}</textarea>
                </div>

                <div class="form-acoes">
                    <button type="submit" class="btn btn-primary">✓ Emitir Frete</button>
                    <a href="${pageContext.request.contextPath}/fretes"
                       class="btn btn-secondary">Cancelar</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
(function () {
    'use strict';

    /* ──────────────────────────────────────────
       LISTA DE UFs VÁLIDAS — populada nos selects
       ────────────────────────────────────────── */
    var UFS = [
        'AC','AL','AP','AM','BA','CE','DF','ES','GO','MA',
        'MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN',
        'RS','RO','RR','SC','SP','SE','TO'
    ];

    /* Valores previamente selecionados (repopulação após erro do backend) */
    var ufOrigSalva  = '${frete.ufOrigem}';
    var ufDestSalva  = '${frete.ufDestino}';

    function popularSelectUF(selectId, valorSalvo) {
        var sel = document.getElementById(selectId);
        UFS.forEach(function (uf) {
            var opt = document.createElement('option');
            opt.value       = uf;
            opt.textContent = uf;
            if (uf === valorSalvo) opt.selected = true;
            sel.appendChild(opt);
        });
    }
    popularSelectUF('ufOrigem',  ufOrigSalva);
    popularSelectUF('ufDestino', ufDestSalva);

    /* ──────────────────────────────────────────
       DATA MÍNIMA = HOJE
       ────────────────────────────────────────── */
    var hoje     = new Date();
    var anoHoje  = hoje.getFullYear();
    var mesHoje  = String(hoje.getMonth() + 1).padStart(2, '0');
    var diaHoje  = String(hoje.getDate()).padStart(2, '0');
    var hojeStr  = anoHoje + '-' + mesHoje + '-' + diaHoje;

    var dataEl = document.getElementById('dataPrevEntrega');
    dataEl.setAttribute('min', hojeStr);

    /* ──────────────────────────────────────────
       PREVIEW DE VALORES
       ────────────────────────────────────────── */
    var freteInput = document.getElementById('valorFrete');
    var aIcms      = document.getElementById('aliquotaIcms');
    var aIbs       = document.getElementById('aliquotaIbs');
    var aCbs       = document.getElementById('aliquotaCbs');
    var preview    = document.getElementById('preview-valores');

    function fmt(v) { return 'R$ ' + v.toFixed(2).replace('.', ','); }

    function calcularPreview() {
        var vf = parseFloat(freteInput.value) || 0;
        if (vf <= 0) { preview.style.display = 'none'; return; }

        var qi = parseFloat(aIcms.value) || 0;
        var qb = parseFloat(aIbs.value)  || 0;
        var qc = parseFloat(aCbs.value)  || 0;

        var icms  = +(vf * qi / 100).toFixed(2);
        var ibs   = +(vf * qb / 100).toFixed(2);
        var cbs   = +(vf * qc / 100).toFixed(2);
        var total = +(vf + icms + ibs + cbs).toFixed(2);

        document.getElementById('preview-icms').textContent =
            qi > 0 ? ' ICMS: '  + fmt(icms)  : '';
        document.getElementById('preview-ibs').textContent =
            qb > 0 ? ' | IBS: ' + fmt(ibs)   : '';
        document.getElementById('preview-cbs').textContent =
            qc > 0 ? ' | CBS: ' + fmt(cbs)   : '';
        document.getElementById('preview-total').textContent =
            ' | Total: ' + fmt(total);

        preview.style.display = 'block';
    }
    [freteInput, aIcms, aIbs, aCbs].forEach(function (el) {
        if (el) el.addEventListener('input', calcularPreview);
    });
    calcularPreview(); // executar na carga para repopulação

    /* ──────────────────────────────────────────
       CAPACIDADE DO VEÍCULO — hint de peso
       ────────────────────────────────────────── */
    var selVeiculo   = document.getElementById('idVeiculo');
    var hintCapac    = document.getElementById('hint-capacidade');
    var inputPeso    = document.getElementById('pesoKg');
    var errPeso      = document.getElementById('err-peso');

    function atualizarCapacidade() {
        var opt = selVeiculo.options[selVeiculo.selectedIndex];
        var cap = opt ? parseFloat(opt.getAttribute('data-capacidade')) : 0;
        if (cap > 0) {
            hintCapac.textContent = 'Capacidade do veículo: ' + cap.toLocaleString('pt-BR') + ' kg';
            inputPeso.setAttribute('max', cap);
        } else {
            hintCapac.textContent = '';
            inputPeso.removeAttribute('max');
        }
        validarPeso();
    }

    function validarPeso() {
        var opt = selVeiculo.options[selVeiculo.selectedIndex];
        var cap = opt ? parseFloat(opt.getAttribute('data-capacidade')) : 0;
        var peso = parseFloat(inputPeso.value) || 0;
        if (cap > 0 && peso > 0 && peso > cap) {
            errPeso.textContent =
                'Peso (' + peso.toLocaleString('pt-BR') + ' kg) excede a capacidade '
                + 'do veículo (' + cap.toLocaleString('pt-BR') + ' kg).';
            errPeso.classList.add('visivel');
            inputPeso.classList.add('campo-erro');
        } else {
            errPeso.classList.remove('visivel');
            inputPeso.classList.remove('campo-erro');
        }
    }

    selVeiculo.addEventListener('change', atualizarCapacidade);
    inputPeso.addEventListener('input', validarPeso);
    atualizarCapacidade(); // executar na carga

    /* ──────────────────────────────────────────
       CORREÇÃO: REMETENTE ≠ DESTINATÁRIO — feedback imediato
       ────────────────────────────────────────── */
    var selRem   = document.getElementById('idRemetente');
    var selDest  = document.getElementById('idDestinatario');
    var avisoIgual = document.getElementById('aviso-rem-igual');

    function verificarRemetenteDest() {
        var rem  = selRem.value;
        var dest = selDest.value;
        if (rem && dest && rem === dest) {
            avisoIgual.classList.add('visivel');
            selDest.classList.add('campo-erro');
        } else {
            avisoIgual.classList.remove('visivel');
            selDest.classList.remove('campo-erro');
        }
    }
    selRem.addEventListener('change', verificarRemetenteDest);
    selDest.addEventListener('change', verificarRemetenteDest);

    /* ──────────────────────────────────────────
       VALIDAÇÃO NO SUBMIT — inline, sem alert()
       ────────────────────────────────────────── */
    var form     = document.getElementById('form-frete');
    var alertaEl = document.getElementById('alerta-validacao');
    var listaEl  = document.getElementById('lista-erros-validacao');

    function marcarErro(inputId, errId) {
        var el = document.getElementById(inputId);
        var er = document.getElementById(errId);
        if (el) el.classList.add('campo-erro');
        if (er) er.classList.add('visivel');
    }
    function limparErro(inputId, errId) {
        var el = document.getElementById(inputId);
        var er = document.getElementById(errId);
        if (el) el.classList.remove('campo-erro');
        if (er) er.classList.remove('visivel');
    }

    form.addEventListener('submit', function (e) {
        var erros = [];

        /* Limpa erros anteriores */
        ['idRemetente','idDestinatario','idMotorista','idVeiculo',
         'municipioOrigem','ufOrigem','municipioDestino','ufDestino',
         'descricaoCarga','valorFrete','dataPrevEntrega'].forEach(function (id) {
            var el = document.getElementById(id);
            if (el) el.classList.remove('campo-erro');
        });
        document.querySelectorAll('.msg-erro-campo').forEach(function (el) {
            el.classList.remove('visivel');
        });

        /* Selects obrigatórios */
        if (!selRem.value) {
            erros.push('Remetente é obrigatório');
            marcarErro('idRemetente', 'err-remetente');
        }
        if (!selDest.value) {
            erros.push('Destinatário é obrigatório');
            marcarErro('idDestinatario', 'err-destinatario');
        }
        /* CORREÇÃO: bloqueia submit se remetente == destinatário */
        if (selRem.value && selDest.value && selRem.value === selDest.value) {
            erros.push('Remetente e Destinatário não podem ser o mesmo cliente');
            marcarErro('idDestinatario', 'err-destinatario');
            avisoIgual.classList.add('visivel');
        }
        if (!document.getElementById('idMotorista').value) {
            erros.push('Motorista é obrigatório');
            marcarErro('idMotorista', 'err-motorista');
        }
        if (!selVeiculo.value) {
            erros.push('Veículo é obrigatório');
            marcarErro('idVeiculo', 'err-veiculo');
        }

        /* Campos de texto obrigatórios */
        if (!document.getElementById('municipioOrigem').value.trim()) {
            erros.push('Município de Origem é obrigatório');
            marcarErro('municipioOrigem', 'err-mun-orig');
        }
        if (!document.getElementById('ufOrigem').value) {
            erros.push('UF de Origem é obrigatória');
            marcarErro('ufOrigem', 'err-uf-orig');
        }
        if (!document.getElementById('municipioDestino').value.trim()) {
            erros.push('Município de Destino é obrigatório');
            marcarErro('municipioDestino', 'err-mun-dest');
        }
        if (!document.getElementById('ufDestino').value) {
            erros.push('UF de Destino é obrigatória');
            marcarErro('ufDestino', 'err-uf-dest');
        }

        /* CORREÇÃO: descricaoCarga agora é validada no frontend também */
        if (!document.getElementById('descricaoCarga').value.trim()) {
            erros.push('Descrição da Carga é obrigatória');
            marcarErro('descricaoCarga', 'err-carga');
        }

        /* Valor do frete */
        var vf = parseFloat(document.getElementById('valorFrete').value);
        if (!vf || vf <= 0) {
            erros.push('Valor do Frete deve ser maior que zero');
            marcarErro('valorFrete', 'err-valor');
        }

        /* Data prevista: obrigatória e não pode ser passado */
        var dataVal = dataEl.value;
        if (!dataVal) {
            erros.push('Data Prevista de Entrega é obrigatória');
            marcarErro('dataPrevEntrega', 'err-data');
        } else if (dataVal < hojeStr) {
            erros.push('Data Prevista de Entrega não pode ser uma data passada');
            marcarErro('dataPrevEntrega', 'err-data');
            document.getElementById('err-data').classList.add('visivel');
        }

        /* Peso vs capacidade do veículo */
        var capOpt = selVeiculo.options[selVeiculo.selectedIndex];
        var capVal = capOpt ? parseFloat(capOpt.getAttribute('data-capacidade')) : 0;
        var pesoVal = parseFloat(inputPeso.value) || 0;
        if (capVal > 0 && pesoVal > 0 && pesoVal > capVal) {
            erros.push('Peso da carga excede a capacidade do veículo selecionado');
        }

        /* Exibe erros ou prossegue */
        if (erros.length > 0) {
            e.preventDefault();
            listaEl.innerHTML = '';
            erros.forEach(function (msg) {
                var li = document.createElement('li');
                li.textContent = msg;
                listaEl.appendChild(li);
            });
            alertaEl.classList.add('visivel');
            /* Rola para o topo do formulário */
            alertaEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
        } else {
            alertaEl.classList.remove('visivel');
        }
    });

})();
</script>
<script type="module" src="${pageContext.request.contextPath}/js/validacoes.js"></script>
</body>
</html>