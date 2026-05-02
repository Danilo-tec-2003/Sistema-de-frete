<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Relatórios – FiscalMove FMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/componentes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/relatorios.css">
</head>
<body>
<%@ include file="/jsp/NavBar.jsp" %>

<div class="main-wrapper">

    <div class="topbar">
        <div class="topbar-title">Relatórios</div>
        <div class="topbar-actions">
            <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary btn-sm">
                Voltar ao Dashboard
            </a>
        </div>
    </div>

    <div class="container relatorios-page">

        <div class="relatorios-hero">
            <div>
                <span class="eyebrow">Central de relatórios</span>
                <h1>Informações operacionais para acompanhamento e impressão</h1>
                <p>
                    Gere relatórios consolidados, documentos de frete e demonstrativos por período
                    para apoiar a conferência diária e a gestão da operação.
                </p>
            </div>
        </div>

        <c:if test="${not empty erro}">
            <div class="alert alert-erro">${erro}</div>
        </c:if>

        <div class="relatorio-grid">

            <section class="card relatorio-card">
                <div class="relatorio-card-header">
                    <div class="relatorio-sigla">FA</div>
                    <div>
                        <h2>Fretes em aberto</h2>
                        <p>Entrega e acompanhamento</p>
                    </div>
                </div>
                <p class="relatorio-desc">
                    Relação dos fretes ainda em andamento, com previsão de entrega,
                    destino, motorista responsável e dias em atraso.
                </p>
                <form method="get" action="${pageContext.request.contextPath}/relatorios" target="_blank">
                    <input type="hidden" name="acao" value="fretesAbertos">
                    <button type="submit" class="btn btn-primary btn-block">Visualizar relatório</button>
                </form>
            </section>

            <section class="card relatorio-card">
                <div class="relatorio-card-header">
                    <div class="relatorio-sigla">RC</div>
                    <div>
                        <h2>Romaneio de carga</h2>
                        <p>Conferência de saída</p>
                    </div>
                </div>
                <p class="relatorio-desc">
                    Documento de apoio para separação, conferência e assinatura do motorista.
                </p>
                <form method="get" action="${pageContext.request.contextPath}/relatorios"
                      target="_blank" class="relatorio-form">
                    <input type="hidden" name="acao" value="romaneioCarga">
                    <div class="form-group">
                        <label for="idMotorista">Motorista</label>
                        <select id="idMotorista" name="idMotorista" class="form-control" required>
                            <option value="">Selecione...</option>
                            <c:forEach var="m" items="${motoristas}">
                                <option value="${m.id}">${m.nome}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="dataRomaneio">Data</label>
                        <input type="date" id="dataRomaneio" name="dataRomaneio"
                               value="${dataHoje}" class="form-control" required>
                    </div>
                    <button type="submit" class="btn btn-primary btn-block">Visualizar romaneio</button>
                </form>
            </section>

            <section class="card relatorio-card">
                <div class="relatorio-card-header">
                    <div class="relatorio-sigla">DF</div>
                    <div>
                        <h2>Documento de frete</h2>
                        <p>Impressão individual</p>
                    </div>
                </div>
                <p class="relatorio-desc">
                    Documento com dados completos do frete, partes envolvidas, carga,
                    rota, veículo, motorista e valores.
                </p>
                <form method="get" action="${pageContext.request.contextPath}/relatorios"
                      target="_blank" class="relatorio-form">
                    <input type="hidden" name="acao" value="documentoFrete">
                    <div class="form-group">
                        <label for="idFrete">Frete</label>
                        <select id="idFrete" name="idFrete" class="form-control" required>
                            <option value="">Selecione...</option>
                            <c:forEach var="f" items="${fretesRelatorio}">
                                <option value="${f.id}">${f.descricao}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary btn-block">Visualizar documento</button>
                </form>
            </section>

            <section class="card relatorio-card">
                <div class="relatorio-card-header">
                    <div class="relatorio-sigla">FC</div>
                    <div>
                        <h2>Fretes por cliente</h2>
                        <p>Extrato comercial</p>
                    </div>
                </div>
                <p class="relatorio-desc">
                    Demonstrativo dos fretes vinculados a um cliente no período, incluindo
                    participação como remetente ou destinatário.
                </p>
                <form method="get" action="${pageContext.request.contextPath}/relatorios"
                      target="_blank" class="relatorio-form">
                    <input type="hidden" name="acao" value="fretesCliente">
                    <div class="form-group">
                        <label for="idCliente">Cliente</label>
                        <select id="idCliente" name="idCliente" class="form-control" required>
                            <option value="">Selecione...</option>
                            <c:forEach var="c" items="${clientes}">
                                <option value="${c.id}">${c.razaoSocial}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-row cols-2">
                        <div class="form-group">
                            <label for="clienteDataInicio">Início</label>
                            <input type="date" id="clienteDataInicio" name="dataInicio"
                                   value="${dataHoje}" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="clienteDataFim">Fim</label>
                            <input type="date" id="clienteDataFim" name="dataFim"
                                   value="${dataHoje}" class="form-control" required>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary btn-block">Visualizar extrato</button>
                </form>
            </section>

            <section class="card relatorio-card">
                <div class="relatorio-card-header">
                    <div class="relatorio-sigla">OP</div>
                    <div>
                        <h2>Ocorrências por período</h2>
                        <p>Rastreamento e auditoria</p>
                    </div>
                </div>
                <p class="relatorio-desc">
                    Histórico de ocorrências registradas nos fretes, útil para acompanhamento
                    de rota, auditoria de entrega e análise de exceções.
                </p>
                <form method="get" action="${pageContext.request.contextPath}/relatorios"
                      target="_blank" class="relatorio-form">
                    <input type="hidden" name="acao" value="ocorrenciasPeriodo">
                    <div class="form-row cols-2">
                        <div class="form-group">
                            <label for="ocorrenciaDataInicio">Início</label>
                            <input type="date" id="ocorrenciaDataInicio" name="dataInicio"
                                   value="${dataHoje}" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="ocorrenciaDataFim">Fim</label>
                            <input type="date" id="ocorrenciaDataFim" name="dataFim"
                                   value="${dataHoje}" class="form-control" required>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary btn-block">Visualizar histórico</button>
                </form>
            </section>

            <section class="card relatorio-card">
                <div class="relatorio-card-header">
                    <div class="relatorio-sigla">DM</div>
                    <div>
                        <h2>Desempenho de motoristas</h2>
                        <p>Indicadores de entrega</p>
                    </div>
                </div>
                <p class="relatorio-desc">
                    Consolida entregas concluídas por motorista, pontualidade, atrasos,
                    peso transportado, volumes e valor movimentado no período.
                </p>
                <form method="get" action="${pageContext.request.contextPath}/relatorios"
                      target="_blank" class="relatorio-form">
                    <input type="hidden" name="acao" value="desempenhoMotoristas">
                    <div class="form-row cols-2">
                        <div class="form-group">
                            <label for="desempenhoDataInicio">Início</label>
                            <input type="date" id="desempenhoDataInicio" name="dataInicio"
                                   value="${dataHoje}" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="desempenhoDataFim">Fim</label>
                            <input type="date" id="desempenhoDataFim" name="dataFim"
                                   value="${dataHoje}" class="form-control" required>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary btn-block">Visualizar indicadores</button>
                </form>
            </section>
        </div>
    </div>
</div>
</body>
</html>
