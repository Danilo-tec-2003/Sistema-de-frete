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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/fretes.css">
    <script src="https://cdn.jsdelivr.net/npm/imask@7.6.1/dist/imask.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/masks.js" defer></script>
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
        <c:if test="${not empty avisoMotoristas}">
            <div class="alert" role="alert">${avisoMotoristas}</div>
        </c:if>

        <%-- Alerta de validação frontend (preenchido via JS) --%>
        <div id="alerta-validacao" role="alert">
            <strong>Corrija os seguintes itens antes de continuar:</strong>
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
                                    data-documento="${c.documentoFiscal}"
                                    <c:if test="${frete.idRemetente == c.id}">selected</c:if>>
                                    ${c.razaoSocial}<c:if test="${not empty c.documentoFiscal}"> — ${c.documentoFiscalFormatado}</c:if>
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
                                    data-documento="${c.documentoFiscal}"
                                    <c:if test="${frete.idDestinatario == c.id}">selected</c:if>>
                                    ${c.razaoSocial}<c:if test="${not empty c.documentoFiscal}"> — ${c.documentoFiscalFormatado}</c:if>
                                </option>
                            </c:forEach>
                        </select>
                        <span class="msg-erro-campo" id="err-destinatario">Selecione o destinatário.</span>
                        <div class="aviso-igual" id="aviso-rem-igual">
                            Remetente e Destinatário não podem ser o mesmo cliente.
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
                                    data-cnh-categoria="${m.cnhCategoria.codigo}"
                                    data-cnh-validade="${m.cnhValidade}"
                                    <c:if test="${frete.idMotorista == m.id}">selected</c:if>>
                                    ${m.nome} — CNH ${m.cnhCategoria.codigo}
                                </option>
                            </c:forEach>
                        </select>
                        <small class="campo-hint">
                            A lista já considera apenas motoristas aptos e sem frete em aberto.
                        </small>
                        <span class="msg-erro-campo" id="err-motorista">Selecione o motorista.</span>
                    </div>
                    <div class="form-group">
                        <label for="idVeiculo">Veículo <span class="obrigatorio">*</span></label>
                        <select id="idVeiculo" name="idVeiculo" class="form-control">
                            <option value="">Selecione o veículo...</option>
                            <c:forEach var="v" items="${veiculos}">
                                <option value="${v.id}"
                                    data-capacidade="${v.capacidadeKg}"
                                    data-tipo="${v.tipo.descricao}"
                                    data-cnh-minima="${v.tipo.cnhMinima.codigo}"
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
                        <span class="msg-erro-campo" id="err-compatibilidade"></span>
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
                               maxlength="80" placeholder="Ex: Recife" data-allow="city">
                        <span class="msg-erro-campo" id="err-mun-orig">Informe o município de origem.</span>
                    </div>
                    <div class="form-group">
                        <label for="ufOrigem">UF Origem <span class="obrigatorio">*</span></label>
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
                               maxlength="80" placeholder="Ex: São Paulo" data-allow="city">
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

                <div class="form-row cols-2 readonly-grid">
                    <div class="form-group">
                        <label for="tipoOperacaoPreview">Tipo de Operação</label>
                        <input type="text" id="tipoOperacaoPreview" class="form-control readonly-field"
                               value="${frete.tipoOperacaoDescricao}" readonly>
                        <small class="campo-hint">Calculado automaticamente com base na origem e destino.</small>
                    </div>
                    <div class="form-group">
                        <label for="tipoDestinatarioPreview">Tipo de Destinatário</label>
                        <input type="text" id="tipoDestinatarioPreview" class="form-control readonly-field"
                               value="${frete.tipoDestinatarioDescricao}" readonly>
                        <small class="campo-hint">Inferido automaticamente pelo CPF/CNPJ do destinatário.</small>
                    </div>
                </div>

                <%-- ==============================================
                     CARGA
                     ============================================== --%>
                <h3 class="secao-titulo">Carga</h3>

                <div class="form-group">
                    <label for="descricaoCarga">
                        Descrição da Carga <span class="obrigatorio">*</span>
                    </label>
                    <input type="text" id="descricaoCarga" name="descricaoCarga"
                           value="${frete.descricaoCarga}" class="form-control"
                           maxlength="200"
                           placeholder="Ex: Eletrônicos, Alimentos não perecíveis, Maquinário"
                           data-allow="text">
                    <small class="campo-hint">Informe o tipo de mercadoria transportada.</small>
                    <span class="msg-erro-campo" id="err-carga">Informe a descrição da carga.</span>
                </div>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="pesoKg">Peso (kg) <span class="obrigatorio">*</span></label>
                        <input type="text" id="pesoKg" name="pesoKg"
                               value="${frete.pesoKg ne 0 ? frete.pesoKg : ''}"
                               class="form-control" data-mask="weight" data-max-digits="10"
                               placeholder="Ex: 1.500,00 kg">
                        <small class="campo-hint" id="hint-capacidade"></small>
                        <span class="msg-erro-campo" id="err-peso"></span>
                    </div>
                    <div class="form-group">
                        <label for="volumes">Volumes <span class="obrigatorio">*</span></label>
                        <input type="text" id="volumes" name="volumes"
                               value="${frete.volumes}" class="form-control"
                               data-max-digits="6" inputmode="numeric" placeholder="Ex: 10">
                        <span class="msg-erro-campo" id="err-volumes">Informe a quantidade de volumes.</span>
                    </div>
                </div>

                <%-- ==============================================
                     VALORES
                     ============================================== --%>
                <h3 class="secao-titulo">Valores</h3>
                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="valorFrete">Valor do Frete (R$) <span class="obrigatorio">*</span></label>
                        <input type="text" id="valorFrete" name="valorFrete"
                               value="${frete.valorFrete ne 0 ? frete.valorFrete : ''}"
                               class="form-control" data-mask="money" data-max-digits="12"
                               placeholder="Ex: R$ 2.500,00">
                        <span class="msg-erro-campo" id="err-valor">
                            O valor do frete deve ser maior que zero.
                        </span>
                    </div>
                    <div class="form-group">
                        <label for="dataPrevEntrega">
                            Data Prev. Entrega <span class="obrigatorio">*</span>
                        </label>
                        <input type="date" id="dataPrevEntrega" name="dataPrevEntrega"
                               value="${frete.dataPrevEntregaIso}"
                               class="form-control">
                        <span class="msg-erro-campo" id="err-data">
                            Informe uma data igual ou posterior a hoje.
                        </span>
                    </div>
                </div>

                <h3 class="secao-titulo">Resumo Fiscal</h3>
                <div class="fiscal-summary">
                    <div class="form-row cols-3">
                        <div class="form-group">
                            <label for="cfopPreview">CFOP</label>
                            <input type="text" id="cfopPreview" name="cfop" class="form-control readonly-field"
                                   value="${empty frete.cfop ? 'Não calculado' : frete.cfop}" readonly>
                            <small class="campo-hint">Aguardando integração fiscal.</small>
                        </div>
                        <div class="form-group">
                            <label for="statusFiscalPreview">Status Fiscal</label>
                            <input type="text" id="statusFiscalPreview" name="statusFiscal"
                                   class="form-control readonly-field" value="${frete.statusFiscal}" readonly>
                        </div>
                        <div class="form-group">
                            <label for="regraFiscalPreview">Regra Fiscal Aplicada</label>
                            <input type="text" id="regraFiscalPreview" name="regraFiscalAplicada"
                                   class="form-control readonly-field" value="Aguardando integração" readonly>
                        </div>
                    </div>

                    <div class="form-row cols-3">
                        <div class="form-group">
                            <label for="aliquotaIcmsPreview">Alíquota ICMS (%)</label>
                            <input type="text" id="aliquotaIcmsPreview" class="form-control readonly-field"
                                   value="0,00%" readonly>
                        </div>
                        <div class="form-group">
                            <label for="valorIcmsPreview">Valor ICMS (R$)</label>
                            <input type="text" id="valorIcmsPreview" class="form-control readonly-field"
                                   value="R$ 0,00" readonly>
                        </div>
                        <div class="form-group">
                            <label for="aliquotaIbsPreview">Alíquota IBS (%)</label>
                            <input type="text" id="aliquotaIbsPreview" class="form-control readonly-field"
                                   value="0,00%" readonly>
                        </div>
                    </div>

                    <div class="form-row cols-3">
                        <div class="form-group">
                            <label for="valorIbsPreview">Valor IBS (R$)</label>
                            <input type="text" id="valorIbsPreview" class="form-control readonly-field"
                                   value="R$ 0,00" readonly>
                        </div>
                        <div class="form-group">
                            <label for="aliquotaCbsPreview">Alíquota CBS (%)</label>
                            <input type="text" id="aliquotaCbsPreview" class="form-control readonly-field"
                                   value="0,00%" readonly>
                        </div>
                        <div class="form-group">
                            <label for="valorCbsPreview">Valor CBS (R$)</label>
                            <input type="text" id="valorCbsPreview" class="form-control readonly-field"
                                   value="R$ 0,00" readonly>
                        </div>
                    </div>

                    <div class="form-row cols-3">
                        <div class="form-group">
                            <label for="totalTributosPreview">Total de Tributos (R$)</label>
                            <input type="text" id="totalTributosPreview" class="form-control readonly-field"
                                   value="R$ 0,00" readonly>
                        </div>
                        <div class="form-group">
                            <label for="valorTotalEstimadoPreview">Valor Total Estimado (R$)</label>
                            <input type="text" id="valorTotalEstimadoPreview" class="form-control readonly-field"
                                   value="R$ 0,00" readonly>
                        </div>
                        <div class="form-group fiscal-action">
                            <label>&nbsp;</label>
                            <button type="button" class="btn btn-secondary" id="btnCalcularFiscal">
                                Calcular Fiscal
                            </button>
                        </div>
                    </div>

                    <div class="info-calculada">
                        Cálculo fiscal ainda não integrado. Campos preparados para o Motor Fiscal.
                    </div>
                </div>

                <div class="form-group" style="margin-top:16px;">
                    <label for="observacao">Observações</label>
                    <textarea id="observacao" name="observacao" class="form-control"
                              rows="3" maxlength="1000" data-allow="text">${frete.observacao}</textarea>
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

    var UFS = [
        'AC','AL','AP','AM','BA','CE','DF','ES','GO','MA',
        'MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN',
        'RS','RO','RR','SC','SP','SE','TO'
    ];

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

    var hoje     = new Date();
    var anoHoje  = hoje.getFullYear();
    var mesHoje  = String(hoje.getMonth() + 1).padStart(2, '0');
    var diaHoje  = String(hoje.getDate()).padStart(2, '0');
    var hojeStr  = anoHoje + '-' + mesHoje + '-' + diaHoje;

    var dataEl = document.getElementById('dataPrevEntrega');
    dataEl.setAttribute('min', hojeStr);

    var freteInput = document.getElementById('valorFrete');
    var totalEstimadoInput = document.getElementById('valorTotalEstimadoPreview');
    var btnCalcularFiscal = document.getElementById('btnCalcularFiscal');
    var form = document.getElementById('form-frete');
    var fiscalInfo = document.querySelector('.info-calculada');
    var contextPath = '${pageContext.request.contextPath}';

    function parseNumeroLocal(valor) {
        if (!valor) return 0;
        return parseFloat(String(valor)
            .replace('R$', '')
            .replace(/kg/gi, '')
            .replace('%', '')
            .replace(/\s/g, '')
            .replace(/\./g, '')
            .replace(',', '.')) || 0;
    }

    function fmt(v) {
        return 'R$ ' + Number(v || 0).toLocaleString('pt-BR', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }

    function atualizarTotalEstimado() {
        var vf = parseNumeroLocal(freteInput.value);
        totalEstimadoInput.value = fmt(vf);
    }
    freteInput.addEventListener('input', atualizarTotalEstimado);
    atualizarTotalEstimado();

    btnCalcularFiscal.addEventListener('click', function () {
        calcularPreviewFiscal();
    });

    function calcularPreviewFiscal() {
        btnCalcularFiscal.disabled = true;
        btnCalcularFiscal.textContent = 'Calculando...';
        if (fiscalInfo) {
            fiscalInfo.textContent = 'Consultando Motor Fiscal...';
        }

        fetch(contextPath + '/fretes', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'Accept': 'application/json'
            },
            body: criarParametrosPreviewFiscal().toString()
        })
            .then(function (response) {
                return response.json().then(function (data) {
                    if (!response.ok) {
                        throw new Error(data && data.message ? data.message : 'Erro ao calcular prévia fiscal.');
                    }
                    return data;
                });
            })
            .then(function (data) {
                preencherResumoFiscal(data);
                if (fiscalInfo) {
                    fiscalInfo.textContent = 'Prévia calculada pelo Motor Fiscal. O cálculo oficial será refeito ao emitir o frete.';
                }
            })
            .catch(function (err) {
                limparResumoFiscalPreview();
                var mensagem = err && err.message ? err.message : 'Erro ao calcular prévia fiscal.';
                if (window.FiscalMoveUI && typeof window.FiscalMoveUI.showFormError === 'function') {
                    window.FiscalMoveUI.showFormError(form, mensagem);
                } else {
                    alert(mensagem);
                }
                if (fiscalInfo) {
                    fiscalInfo.textContent = mensagem;
                }
            })
            .finally(function () {
                btnCalcularFiscal.disabled = false;
                btnCalcularFiscal.textContent = 'Calcular Fiscal';
            });
    }

    function criarParametrosPreviewFiscal() {
        var params = new URLSearchParams();
        params.append('acao', 'previewFiscal');
        params.append('idDestinatario', document.getElementById('idDestinatario').value || '');
        params.append('municipioOrigem', document.getElementById('municipioOrigem').value || '');
        params.append('ufOrigem', document.getElementById('ufOrigem').value || '');
        params.append('municipioDestino', document.getElementById('municipioDestino').value || '');
        params.append('ufDestino', document.getElementById('ufDestino').value || '');
        params.append('valorFrete', document.getElementById('valorFrete').value || '');
        return params;
    }

    function preencherResumoFiscal(data) {
        document.getElementById('cfopPreview').value = data.cfop || 'Não calculado';
        document.getElementById('statusFiscalPreview').value = 'CALCULADO';
        document.getElementById('regraFiscalPreview').value = regraFiscalTexto(data);
        document.getElementById('aliquotaIcmsPreview').value = formatarPercentual(data.icms && data.icms.rate);
        document.getElementById('valorIcmsPreview').value = formatarMoedaTecnica(data.icms && data.icms.amount);
        document.getElementById('aliquotaIbsPreview').value = formatarPercentual(data.ibs && data.ibs.rate);
        document.getElementById('valorIbsPreview').value = formatarMoedaTecnica(data.ibs && data.ibs.amount);
        document.getElementById('aliquotaCbsPreview').value = formatarPercentual(data.cbs && data.cbs.rate);
        document.getElementById('valorCbsPreview').value = formatarMoedaTecnica(data.cbs && data.cbs.amount);
        document.getElementById('totalTributosPreview').value = formatarMoedaTecnica(data.total_tax);
        document.getElementById('valorTotalEstimadoPreview').value = formatarMoedaTecnica(data.total_with_tax);
    }

    function limparResumoFiscalPreview() {
        document.getElementById('cfopPreview').value = 'Não calculado';
        document.getElementById('statusFiscalPreview').value = 'PENDENTE';
        document.getElementById('regraFiscalPreview').value = 'Aguardando integração';
        document.getElementById('aliquotaIcmsPreview').value = '0,00%';
        document.getElementById('valorIcmsPreview').value = 'R$ 0,00';
        document.getElementById('aliquotaIbsPreview').value = '0,00%';
        document.getElementById('valorIbsPreview').value = 'R$ 0,00';
        document.getElementById('aliquotaCbsPreview').value = '0,00%';
        document.getElementById('valorCbsPreview').value = 'R$ 0,00';
        document.getElementById('totalTributosPreview').value = 'R$ 0,00';
        atualizarTotalEstimado();
    }

    function regraFiscalTexto(data) {
        if (data.rule_code && data.rule_version) return data.rule_code + ' v' + data.rule_version;
        if (data.rule_version) return data.rule_version;
        return 'Calculado pelo Motor Fiscal';
    }

    function formatarPercentual(valor) {
        var numero = parseFloat(String(valor || '0').replace(',', '.')) || 0;
        return numero.toLocaleString('pt-BR', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }) + '%';
    }

    function formatarMoedaTecnica(valor) {
        var numero = parseFloat(String(valor || '0').replace(',', '.')) || 0;
        return fmt(numero);
    }

    var selVeiculo   = document.getElementById('idVeiculo');
    var selMotorista = document.getElementById('idMotorista');
    var hintCapac    = document.getElementById('hint-capacidade');
    var inputPeso    = document.getElementById('pesoKg');
    var errPeso      = document.getElementById('err-peso');
    var errCompat    = document.getElementById('err-compatibilidade');

    function atualizarCapacidade() {
        var opt = selVeiculo.options[selVeiculo.selectedIndex];
        var cap = opt ? parseFloat(opt.getAttribute('data-capacidade')) : 0;
        var cnhMinima = opt ? opt.getAttribute('data-cnh-minima') : '';
        if (cap > 0) {
            hintCapac.textContent = 'Capacidade do veículo: ' + cap.toLocaleString('pt-BR')
                + ' kg. CNH mínima: ' + cnhMinima + '.';
            inputPeso.setAttribute('max', cap);
        } else {
            hintCapac.textContent = '';
            inputPeso.removeAttribute('max');
        }
        validarPeso();
        validarCompatibilidade();
    }

    function validarPeso() {
        var opt = selVeiculo.options[selVeiculo.selectedIndex];
        var cap = opt ? parseFloat(opt.getAttribute('data-capacidade')) : 0;
        var peso = parseNumeroLocal(inputPeso.value);
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
    atualizarCapacidade();

    function nivelCnh(cnh) {
        var codigo = (cnh || '').toUpperCase();
        if (codigo === 'A') return 0;
        if (codigo === 'B' || codigo === 'AB') return 1;
        if (codigo === 'C' || codigo === 'AC') return 2;
        if (codigo === 'D' || codigo === 'AD') return 3;
        if (codigo === 'E' || codigo === 'AE') return 4;
        return -1;
    }

    function possuiA(cnh) {
        return (cnh || '').toUpperCase().indexOf('A') >= 0;
    }

    function cnhAtende(cnhMotorista, cnhExigida) {
        if (!cnhMotorista || !cnhExigida) return true;
        if (cnhExigida === 'A') return possuiA(cnhMotorista);
        return nivelCnh(cnhMotorista) >= nivelCnh(cnhExigida);
    }

    function validarCompatibilidade() {
        var optMotorista = selMotorista.options[selMotorista.selectedIndex];
        var optVeiculo = selVeiculo.options[selVeiculo.selectedIndex];
        var cnhMotorista = optMotorista ? optMotorista.getAttribute('data-cnh-categoria') : '';
        var cnhMinima = optVeiculo ? optVeiculo.getAttribute('data-cnh-minima') : '';
        var tipoVeiculo = optVeiculo ? optVeiculo.getAttribute('data-tipo') : '';

        if (selMotorista.value && selVeiculo.value && !cnhAtende(cnhMotorista, cnhMinima)) {
            errCompat.textContent = 'Motorista com CNH ' + cnhMotorista
                + ' não pode conduzir veículo ' + tipoVeiculo
                + ' que exige categoria ' + cnhMinima + '.';
            errCompat.classList.add('visivel');
            selMotorista.classList.add('campo-erro');
            selVeiculo.classList.add('campo-erro');
            return false;
        }
        errCompat.classList.remove('visivel');
        selMotorista.classList.remove('campo-erro');
        selVeiculo.classList.remove('campo-erro');
        return true;
    }

    selMotorista.addEventListener('change', validarCompatibilidade);
    selVeiculo.addEventListener('change', validarCompatibilidade);

    var selRem   = document.getElementById('idRemetente');
    var selDest  = document.getElementById('idDestinatario');
    var avisoIgual = document.getElementById('aviso-rem-igual');
    var tipoOperacaoPreview = document.getElementById('tipoOperacaoPreview');
    var tipoDestinatarioPreview = document.getElementById('tipoDestinatarioPreview');
    var municipioOrigem = document.getElementById('municipioOrigem');
    var municipioDestino = document.getElementById('municipioDestino');
    var ufOrigem = document.getElementById('ufOrigem');
    var ufDestino = document.getElementById('ufDestino');

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

    function normalizarTexto(valor) {
        return (valor || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').trim().toUpperCase();
    }

    function atualizarTipoOperacao() {
        var ufo = normalizarTexto(ufOrigem.value);
        var ufd = normalizarTexto(ufDestino.value);
        var munO = normalizarTexto(municipioOrigem.value);
        var munD = normalizarTexto(municipioDestino.value);

        if (!ufo || !ufd || !munO || !munD) {
            tipoOperacaoPreview.value = '';
            return;
        }

        if (ufo !== ufd) tipoOperacaoPreview.value = 'Interestadual';
        else if (munO !== munD) tipoOperacaoPreview.value = 'Estadual';
        else tipoOperacaoPreview.value = 'Municipal';
    }

    function atualizarTipoDestinatario() {
        var opt = selDest.options[selDest.selectedIndex];
        var doc = opt ? (opt.getAttribute('data-documento') || '').replace(/\D/g, '') : '';
        if (doc.length === 11) tipoDestinatarioPreview.value = 'Pessoa Física';
        else if (doc.length === 14) tipoDestinatarioPreview.value = 'Pessoa Jurídica';
        else tipoDestinatarioPreview.value = '';
    }

    [municipioOrigem, municipioDestino, ufOrigem, ufDestino].forEach(function (el) {
        el.addEventListener('input', atualizarTipoOperacao);
        el.addEventListener('change', atualizarTipoOperacao);
    });
    selDest.addEventListener('change', atualizarTipoDestinatario);
    atualizarTipoOperacao();
    atualizarTipoDestinatario();

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

        ['idRemetente','idDestinatario','idMotorista','idVeiculo',
         'municipioOrigem','ufOrigem','municipioDestino','ufDestino',
         'descricaoCarga','pesoKg','volumes','valorFrete','dataPrevEntrega'].forEach(function (id) {
            var el = document.getElementById(id);
            if (el) el.classList.remove('campo-erro');
        });
        document.querySelectorAll('.msg-erro-campo').forEach(function (el) {
            el.classList.remove('visivel');
        });

        if (!selRem.value) {
            erros.push('Remetente é obrigatório');
            marcarErro('idRemetente', 'err-remetente');
        }
        if (!selDest.value) {
            erros.push('Destinatário é obrigatório');
            marcarErro('idDestinatario', 'err-destinatario');
        }
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
        if (!validarCompatibilidade()) {
            erros.push('Motorista e veículo são incompatíveis pela categoria da CNH');
        }

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

        if (!document.getElementById('descricaoCarga').value.trim()) {
            erros.push('Descrição da Carga é obrigatória');
            marcarErro('descricaoCarga', 'err-carga');
        }

        var pesoValObrigatorio = parseNumeroLocal(inputPeso.value);
        if (!pesoValObrigatorio || pesoValObrigatorio <= 0) {
            erros.push('Peso da Carga deve ser maior que zero');
            errPeso.textContent = 'Informe o peso da carga.';
            marcarErro('pesoKg', 'err-peso');
        }

        var volumesVal = parseInt(document.getElementById('volumes').value, 10);
        if (!volumesVal || volumesVal <= 0) {
            erros.push('Volumes deve ser maior que zero');
            marcarErro('volumes', 'err-volumes');
        }

        var vf = parseNumeroLocal(document.getElementById('valorFrete').value);
        if (!vf || vf <= 0) {
            erros.push('Valor do Frete deve ser maior que zero');
            marcarErro('valorFrete', 'err-valor');
        }

        var dataVal = dataEl.value;
        if (!dataVal) {
            erros.push('Data Prevista de Entrega é obrigatória');
            marcarErro('dataPrevEntrega', 'err-data');
        } else if (dataVal < hojeStr) {
            erros.push('Data Prevista de Entrega não pode ser uma data passada');
            marcarErro('dataPrevEntrega', 'err-data');
            document.getElementById('err-data').classList.add('visivel');
        }

        var capOpt = selVeiculo.options[selVeiculo.selectedIndex];
        var capVal = capOpt ? parseFloat(capOpt.getAttribute('data-capacidade')) : 0;
        var pesoVal = parseNumeroLocal(inputPeso.value);
        if (capVal > 0 && pesoVal > 0 && pesoVal > capVal) {
            erros.push('Peso da carga excede a capacidade do veículo selecionado');
        }

        if (erros.length > 0) {
            e.preventDefault();
            listaEl.innerHTML = '';
            erros.forEach(function (msg) {
                var li = document.createElement('li');
                li.textContent = msg;
                listaEl.appendChild(li);
            });
            alertaEl.classList.add('visivel');
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
