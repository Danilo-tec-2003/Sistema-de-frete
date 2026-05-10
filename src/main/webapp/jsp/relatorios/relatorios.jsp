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

    <main class="container relatorios-page">

        <header class="card relatorios-hero">
            <div class="relatorios-hero-copy">
                <span class="eyebrow">Central operacional</span>
                <h1>Relatórios para fechar a operação sem perder contexto</h1>
                <p>
                    Gere documentos de transporte, extratos por cliente, histórico de ocorrências
                    e indicadores de desempenho com os filtros usados no dia a dia.
                </p>
            </div>
            <div class="relatorios-hero-stats" aria-label="Resumo da central de relatórios">
                <div>
                    <strong>6</strong>
                    <span>modelos</span>
                </div>
                <div>
                    <strong>PDF</strong>
                    <span>saída padrão</span>
                </div>
                <div>
                    <strong>${dataHoje}</strong>
                    <span>data base</span>
                </div>
            </div>
        </header>

        <c:if test="${not empty erro}">
            <div class="alert alert-erro">${erro}</div>
        </c:if>

        <section class="relatorio-section-head">
            <div>
                <span class="eyebrow">Catálogo</span>
                <h2>Escolha o documento</h2>
            </div>
            <a href="${pageContext.request.contextPath}/fretes" class="btn btn-secondary btn-sm">
                Consultar fretes
            </a>
        </section>

        <div class="relatorio-grid">

            <section class="card relatorio-card relatorio-card-wide">
                <div class="relatorio-card-top">
                    <span class="relatorio-icon">
                        <svg viewBox="0 0 24 24"><path d="M4 5h11a2 2 0 0 1 2 2v3h1.5l2.5 3.2V18h-2.1a3 3 0 0 1-5.8 0H9.9a3 3 0 0 1-5.8 0H2V7a2 2 0 0 1 2-2Zm0 2v9h.8a3 3 0 0 1 4.4 0H15V7H4Zm13 5v4h.8a3 3 0 0 1 1.2-.8V14l-1.5-2H17Z"/></svg>
                    </span>
                    <div>
                        <span>Entrega e acompanhamento</span>
                        <h2>Fretes em aberto</h2>
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
                <div class="relatorio-card-top">
                    <span class="relatorio-icon">
                        <svg viewBox="0 0 24 24"><path d="M6 3h12v18H6V3Zm2 2v14h8V5H8Zm2 3h4v2h-4V8Zm0 4h4v2h-4v-2Z"/></svg>
                    </span>
                    <div>
                        <span>Conferência de saída</span>
                        <h2>Romaneio de carga</h2>
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
                <div class="relatorio-card-top">
                    <span class="relatorio-icon">
                        <svg viewBox="0 0 24 24"><path d="M5 3h10l4 4v14H5V3Zm9 2H7v14h10V8h-3V5Zm-4 6h5v2h-5v-2Zm0 4h5v2h-5v-2Z"/></svg>
                    </span>
                    <div>
                        <span>Impressão individual</span>
                        <h2>Documento de frete</h2>
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
                <div class="relatorio-card-top">
                    <span class="relatorio-icon">
                        <svg viewBox="0 0 24 24"><path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm-8 9a8 8 0 0 1 16 0h-2a6 6 0 0 0-12 0H4Z"/></svg>
                    </span>
                    <div>
                        <span>Extrato comercial</span>
                        <h2>Fretes por cliente</h2>
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
                <div class="relatorio-card-top">
                    <span class="relatorio-icon">
                        <svg viewBox="0 0 24 24"><path d="M12 2a8 8 0 0 1 8 8c0 5.3-8 12-8 12S4 15.3 4 10a8 8 0 0 1 8-8Zm0 5a3 3 0 1 0 0 6 3 3 0 0 0 0-6Z"/></svg>
                    </span>
                    <div>
                        <span>Rastreamento e auditoria</span>
                        <h2>Ocorrências por período</h2>
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
                <div class="relatorio-card-top">
                    <span class="relatorio-icon">
                        <svg viewBox="0 0 24 24"><path d="M4 20V5h2v13h14v2H4Zm4-4V9h3v7H8Zm5 0V4h3v12h-3Zm5 0v-5h3v5h-3Z"/></svg>
                    </span>
                    <div>
                        <span>Indicadores de entrega</span>
                        <h2>Desempenho de motoristas</h2>
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
    </main>
</div>
</body>
</html>
