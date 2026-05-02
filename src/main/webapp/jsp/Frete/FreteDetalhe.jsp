<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Frete ${frete.numero} – GW Fretes</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/validacoes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/componentes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/fretes.css">
</head>
<body>
<%@ include file="/jsp/NavBar.jsp" %>

<div class="main-wrapper">

    <div class="topbar">
        <div class="topbar-title">Fretes</div>
        <div class="topbar-actions">
            <a href="${pageContext.request.contextPath}/relatorios?acao=documentoFrete&idFrete=${frete.id}"
               class="btn btn-primary"
               onclick="window.open(this.href, '_blank'); return false;">
                Imprimir Documento
            </a>
            <a href="${pageContext.request.contextPath}/fretes" class="btn btn-secondary">&larr; Voltar</a>
        </div>
    </div>

<div class="container detalhe-frete-page">

    <div class="detalhe-header">
        <div>
            <h1 class="detalhe-titulo">${frete.numero}</h1>
            <span class="subtitulo-pagina">${frete.rota}</span>
        </div>
        <span class="badge ${frete.aberto ? 'badge-transito' : (frete.statusCancelado ? 'badge-cancelado' : (frete.statusNaoEntregue ? 'badge-naoentregue' : 'badge-entregue'))}">
            ${frete.status.descricao}
        </span>
    </div>

    <c:if test="${not empty sessionScope.sucesso}">
        <div class="alert alert-sucesso">${sessionScope.sucesso}</div>
        <c:remove var="sucesso" scope="session"/>
    </c:if>
    <c:if test="${not empty erro}">
        <div class="alert alert-erro">${erro}</div>
    </c:if>

    <%-- =========================================================
         LINHA DO TEMPO DE STATUS
         ========================================================= --%>
    <div class="status-timeline">
        <div class="step ${frete.timelineEmitidoDone ? 'done' : ''} ${frete.statusEmitido ? 'atual' : ''}">
            <div class="step-dot"></div>
            <div class="step-label">Emitido</div>
        </div>
        <div class="step-line ${frete.timelineSaidaDone ? 'done' : ''}"></div>
        <div class="step ${frete.timelineSaidaDone ? 'done' : ''} ${frete.statusSaidaConfirmada ? 'atual' : ''}">
            <div class="step-dot"></div>
            <div class="step-label">Saída Conf.</div>
        </div>
        <div class="step-line ${frete.timelineTransitoDone ? 'done' : ''}"></div>
        <div class="step ${frete.timelineTransitoDone ? 'done' : ''} ${frete.statusEmTransito ? 'atual' : ''}">
            <div class="step-dot"></div>
            <div class="step-label">Em Trânsito</div>
        </div>
        <div class="step-line ${frete.timelineFinalDone ? 'done' : ''}"></div>
        <div class="step ${frete.timelineFinalDone ? 'done' : ''} ${frete.statusEntregue ? 'atual entregue' : ''} ${frete.statusNaoEntregue ? 'nao-entregue' : ''} ${frete.statusCancelado ? 'atual cancelado' : ''}">
            <div class="step-dot"></div>
            <div class="step-label">${frete.statusFinalLabel}</div>
        </div>
    </div>

    <%-- =========================================================
         DADOS DO FRETE
         ========================================================= --%>
    <div class="detalhe-grid">

        <%-- Bloco: Partes --%>
        <div class="card detalhe-bloco">
            <h3 class="secao-titulo">Partes</h3>
            <dl class="dados-lista">
                <dt>Remetente</dt>
                <dd>${frete.remetente.razaoSocial}
                    <c:if test="${not empty frete.remetente.documentoFiscal}">
                        <small class="text-muted">(${frete.remetente.documentoFiscalFormatado})</small>
                    </c:if>
                </dd>
                <dt>Destinatário</dt>
                <dd>${frete.destinatario.razaoSocial}
                    <c:if test="${not empty frete.destinatario.documentoFiscal}">
                        <small class="text-muted">(${frete.destinatario.documentoFiscalFormatado})</small>
                    </c:if>
                </dd>
                <dt>Motorista</dt>
                <dd>${frete.motorista.nome}
                    <small class="text-muted">— CNH válida até
                        ${frete.motorista.cnhValidadeFormatada}
                    </small>
                </dd>
                <dt>Veículo</dt>
                <dd>${frete.veiculo.placa}</dd>
            </dl>
        </div>

        <%-- Bloco: Valores --%>
        <div class="card detalhe-bloco">
            <h3 class="secao-titulo">Valores</h3>
            <dl class="dados-lista">
                <dt>Valor do Frete</dt>
                <dd><fmt:formatNumber value="${frete.valorFrete}" type="currency" currencySymbol="R$ "/></dd>

                <c:if test="${frete.aliquotaIcms > 0}">
                    <dt>ICMS (${frete.aliquotaIcms}%)</dt>
                    <dd><fmt:formatNumber value="${frete.valorIcms}" type="currency" currencySymbol="R$ "/></dd>
                </c:if>

                <c:if test="${frete.aliquotaIbs > 0}">
                    <dt>IBS (${frete.aliquotaIbs}%)</dt>
                    <dd><fmt:formatNumber value="${frete.valorIbs}" type="currency" currencySymbol="R$ "/></dd>
                </c:if>

                <c:if test="${frete.aliquotaCbs > 0}">
                    <dt>CBS (${frete.aliquotaCbs}%)</dt>
                    <dd><fmt:formatNumber value="${frete.valorCbs}" type="currency" currencySymbol="R$ "/></dd>
                </c:if>

                <dt class="destaque">Valor Total</dt>
                <dd class="destaque">
                    <fmt:formatNumber value="${frete.valorTotal}" type="currency" currencySymbol="R$ "/>
                </dd>

                <c:if test="${not empty frete.pesoKg}">
                    <dt>Peso</dt>
                    <dd><fmt:formatNumber value="${frete.pesoKg}"/> kg</dd>
                </c:if>
                <c:if test="${not empty frete.volumes}">
                    <dt>Volumes</dt>
                    <dd>${frete.volumes}</dd>
                </c:if>
            </dl>
        </div>

        <%-- Bloco: Datas --%>
        <div class="card detalhe-bloco">
            <h3 class="secao-titulo">Datas</h3>
            <dl class="dados-lista">
                <dt>Emissão</dt>
                <dd>${frete.dataEmissaoFormatada}</dd>

                <dt>Prev. Entrega</dt>
                <dd>
                    ${frete.dataPrevEntregaFormatada}
                    <c:if test="${frete.diasAtraso > 0}">
                        <span class="badge badge-erro">${frete.diasAtraso}d atraso</span>
                    </c:if>
                </dd>

                <c:if test="${not empty frete.dataSaida}">
                    <dt>Saída</dt>
                    <dd>${frete.dataSaidaFormatada}</dd>
                </c:if>

                <c:if test="${not empty frete.dataEntrega}">
                    <dt>Entrega</dt>
                    <dd>${frete.dataEntregaFormatada}</dd>
                </c:if>
            </dl>

            <c:if test="${not empty frete.observacao}">
                <h3 class="secao-titulo" style="margin-top:16px;">Observações</h3>
                <p class="obs-texto">${frete.observacao}</p>
            </c:if>
        </div>

    </div><%-- /detalhe-grid --%>

    <%-- =========================================================
         AÇÕES DE STATUS (botões conforme estado atual)
         ========================================================= --%>
    <c:if test="${frete.aberto}">
        <div class="card acoes-status">
            <h3 class="secao-titulo">Movimentar Frete</h3>

            <%-- EMITIDO → Confirmar Saída --%>
            <c:if test="${frete.statusEmitido}">
                <details class="acao-collapse">
                    <summary class="btn btn-warning">▶ Confirmar Saída do Pátio</summary>
                    <form method="post" action="${pageContext.request.contextPath}/fretes"
                          class="acao-form">
                        <input type="hidden" name="acao"    value="saida">
                        <input type="hidden" name="idFrete" value="${frete.id}">
                        <div class="form-row cols-2">
                            <div class="form-group">
                                <label>Município de Saída</label>
                                <input type="text" name="municipioSaida" class="form-control"
                                       value="${frete.municipioOrigem}" required maxlength="80">
                            </div>
                            <div class="form-group">
                                <label>UF</label>
                                <input type="text" name="ufSaida" class="form-control"
                                       value="${frete.ufOrigem}" maxlength="2"
                                       style="text-transform:uppercase" required>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-warning">Confirmar Saída</button>
                    </form>
                </details>
            </c:if>

            <%-- SAÍDA_CONFIRMADA → Iniciar Trânsito --%>
            <c:if test="${frete.statusSaidaConfirmada}">
                <details class="acao-collapse">
                    <summary class="btn btn-info">🚛 Iniciar Trânsito</summary>
                    <form method="post" action="${pageContext.request.contextPath}/fretes"
                          class="acao-form">
                        <input type="hidden" name="acao"    value="transito">
                        <input type="hidden" name="idFrete" value="${frete.id}">
                        <div class="form-row cols-2">
                            <div class="form-group">
                                <label>Município Atual</label>
                                <input type="text" name="municipioAtual" class="form-control"
                                       placeholder="Localização atual" maxlength="80">
                            </div>
                            <div class="form-group">
                                <label>UF</label>
                                <input type="text" name="ufAtual" class="form-control"
                                       maxlength="2" style="text-transform:uppercase">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-info">Iniciar Trânsito</button>
                    </form>
                </details>
            </c:if>

            <%-- EM_TRANSITO → Registrar Entrega --%>
            <c:if test="${frete.statusEmTransito}">
                <details class="acao-collapse">
                    <summary class="btn btn-primary">✓ Registrar Entrega</summary>
                    <form method="post" action="${pageContext.request.contextPath}/fretes"
                          class="acao-form">
                        <input type="hidden" name="acao"    value="entrega">
                        <input type="hidden" name="idFrete" value="${frete.id}">
                        <div class="form-row cols-2">
                            <div class="form-group">
                                <label>Nome do Recebedor <span class="obrigatorio">*</span></label>
                                <input type="text" name="nomeRecebedor" class="form-control"
                                       required maxlength="100">
                            </div>
                            <div class="form-group">
                                <label>Documento do Recebedor <span class="obrigatorio">*</span></label>
                                <input type="text" name="documentoRecebedor" class="form-control"
                                       required maxlength="20" placeholder="CPF ou RG">
                            </div>
                        </div>
                        <div class="form-row cols-2">
                            <div class="form-group">
                                <label>Município da Entrega</label>
                                <input type="text" name="municipioEntrega" class="form-control"
                                       value="${frete.municipioDestino}" maxlength="80">
                            </div>
                            <div class="form-group">
                                <label>UF</label>
                                <input type="text" name="ufEntrega" class="form-control"
                                       value="${frete.ufDestino}" maxlength="2"
                                       style="text-transform:uppercase">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary">Confirmar Entrega</button>
                    </form>
                </details>

                <details class="acao-collapse">
                    <summary class="btn btn-warning">✗ Registrar Não Entrega</summary>
                    <form method="post" action="${pageContext.request.contextPath}/fretes"
                          class="acao-form">
                        <input type="hidden" name="acao"    value="naoEntrega">
                        <input type="hidden" name="idFrete" value="${frete.id}">
                        <div class="form-row cols-3">
                            <div class="form-group">
                                <label>Motivo <span class="obrigatorio">*</span></label>
                                <input type="text" name="motivoNaoEntrega" class="form-control"
                                       required maxlength="200"
                                       placeholder="Ex: Destinatário ausente">
                            </div>
                            <div class="form-group">
                                <label>Município Atual</label>
                                <input type="text" name="municipioAtual" class="form-control"
                                       value="${frete.municipioDestino}" maxlength="80">
                            </div>
                            <div class="form-group">
                                <label>UF</label>
                                <input type="text" name="ufAtual" class="form-control"
                                       value="${frete.ufDestino}" maxlength="2"
                                       style="text-transform:uppercase">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-warning">Registrar Não Entrega</button>
                    </form>
                </details>
            </c:if>

            <%-- CANCELAR (qualquer estado aberto) --%>
            <details class="acao-collapse acao-danger">
                <summary class="btn btn-danger">✕ Cancelar Frete</summary>
                <form method="post" action="${pageContext.request.contextPath}/fretes"
                      class="acao-form">
                    <input type="hidden" name="acao"    value="cancelar">
                    <input type="hidden" name="idFrete" value="${frete.id}">
                    <div class="form-group">
                        <label>Motivo do Cancelamento <span class="obrigatorio">*</span></label>
                        <input type="text" name="motivoCancelamento" class="form-control"
                               required maxlength="200"
                               placeholder="Informe o motivo do cancelamento">
                    </div>
                    <button type="submit" class="btn btn-danger"
                            onclick="return confirm('Confirma o cancelamento do frete ${frete.numero}?')">
                        Cancelar Frete
                    </button>
                </form>
            </details>

            <%-- OCORRÊNCIA AVULSA (qualquer estado aberto) --%>
            <details class="acao-collapse">
                <summary class="btn btn-secondary">+ Registrar Ocorrência</summary>
                <form method="post" action="${pageContext.request.contextPath}/fretes"
                      class="acao-form">
                    <input type="hidden" name="acao"    value="ocorrencia">
                    <input type="hidden" name="idFrete" value="${frete.id}">

                    <div class="form-row cols-3">
                        <div class="form-group">
                            <label>Tipo <span class="obrigatorio">*</span></label>
                            <select name="tipoOcorrencia" class="form-control" required
                                    id="sel-tipo-oc">
                                <option value="">Selecione...</option>
                                <c:forEach var="t" items="${tiposOcorrencia}">
                                    <option value="${t.codigo}">${t.descricao}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Município</label>
                            <input type="text" name="municipio" class="form-control" maxlength="80">
                        </div>
                        <div class="form-group">
                            <label>UF</label>
                            <input type="text" name="uf" class="form-control"
                                   maxlength="2" style="text-transform:uppercase">
                        </div>
                    </div>

                    <%-- Campos condicionais por tipo --%>
                    <div id="campo-descricao" class="form-group" style="display:none">
                        <label>Descrição <span class="obrigatorio">*</span></label>
                        <textarea name="descricao" class="form-control" rows="2"
                                  maxlength="500"></textarea>
                    </div>

                    <div id="campos-recebedor" style="display:none">
                        <div class="form-row cols-2">
                            <div class="form-group">
                                <label>Nome do Recebedor <span class="obrigatorio">*</span></label>
                                <input type="text" name="nomeRecebedor" class="form-control"
                                       maxlength="100">
                            </div>
                            <div class="form-group">
                                <label>Documento <span class="obrigatorio">*</span></label>
                                <input type="text" name="documentoRecebedor" class="form-control"
                                       maxlength="20">
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-secondary">Salvar Ocorrência</button>
                </form>
            </details>
        </div>
    </c:if>

    <%-- =========================================================
         HISTÓRICO DE OCORRÊNCIAS
         ========================================================= --%>
    <div class="card">
        <h3 class="secao-titulo">Histórico de Ocorrências</h3>
        <c:choose>
            <c:when test="${empty ocorrencias}">
                <p class="text-muted text-center" style="padding:16px">
                    Nenhuma ocorrência registrada.
                </p>
            </c:when>
            <c:otherwise>
                <div class="timeline-oc">
                    <c:forEach var="oc" items="${ocorrencias}">
                        <div class="oc-item oc-tipo-${oc.tipo.codigo}">
                            <div class="oc-icon">
                                ${oc.icone}
                            </div>
                            <div class="oc-corpo">
                                <div class="oc-header">
                                    <strong>${oc.tipo.descricao}</strong>
                                    <span class="oc-data">
                                        ${oc.dataHoraFormatada}
                                    </span>
                                </div>
                                <c:if test="${not empty oc.localizacao and oc.localizacao ne '—'}">
                                    <div class="oc-local">📍 ${oc.localizacao}</div>
                                </c:if>
                                <c:if test="${not empty oc.descricao}">
                                    <div class="oc-desc">${oc.descricao}</div>
                                </c:if>
                                <c:if test="${not empty oc.nomeRecebedor}">
                                    <div class="oc-recebedor">
                                        Recebido por: <strong>${oc.nomeRecebedor}</strong>
                                        — Doc: ${oc.documentoRecebedor}
                                    </div>
                                </c:if>
                                <c:if test="${not empty oc.createdBy}">
                                    <div class="oc-usuario">Por: ${oc.createdBy}</div>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

</div>
</div>

<script>
/* Campos condicionais na seção de ocorrência avulsa */
(function () {
    var sel    = document.getElementById('sel-tipo-oc');
    if (!sel) return;
    var divDesc = document.getElementById('campo-descricao');
    var divRec  = document.getElementById('campos-recebedor');

    /* Tipos que exigem descrição: A, X, O */
    var EXIGE_DESC = ['A', 'X', 'O'];
    /* Tipos que exigem recebedor: E */
    var EXIGE_REC  = ['E'];

    sel.addEventListener('change', function () {
        var v = this.value;
        divDesc.style.display = EXIGE_DESC.includes(v) ? 'block' : 'none';
        divRec.style.display  = EXIGE_REC.includes(v)  ? 'block' : 'none';
    });
})();
</script>
<script type="module" src="${pageContext.request.contextPath}/js/validacoes.js"></script>
</body>
</html>
