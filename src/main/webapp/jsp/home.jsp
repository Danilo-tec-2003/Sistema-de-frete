<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard - FiscalMove FMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Exo+2:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<%@ include file="/jsp/NavBar.jsp" %>

<div class="main-wrapper">

    <div class="topbar">
        <div class="topbar-title">Dashboard</div>
        <div class="topbar-actions">
            <a href="${pageContext.request.contextPath}/fretes?acao=novo" class="btn btn-primary btn-sm">
                Novo frete
            </a>
        </div>
    </div>

    <main class="container dashboard-container">

        <c:if test="${not empty dashboardAviso}">
            <div class="alert alert-erro">${dashboardAviso}</div>
        </c:if>

        <section class="dashboard-layout">
            <div class="dashboard-main">
                <section class="dashboard-hero card">
                    <div class="hero-copy">
                        <h1>Olá, <span>${empty sessionScope.usuarioLogado ? 'Administrador' : sessionScope.usuarioLogado.nome}</span></h1>
                        <p>Bem-vindo de volta ao FiscalMove FMS. Acompanhe seus indicadores e operações em tempo real.</p>
                        <div class="hero-meta">
                            <span>
                                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M7 2h2v3h6V2h2v3h3v17H4V5h3V2Zm13 8H6v10h14V10ZM6 7v1h14V7H6Z"/></svg>
                                ${empty dataDashboard ? 'Hoje' : dataDashboard}
                            </span>
                            <span>
                                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2a10 10 0 1 1 0 20 10 10 0 0 1 0-20Zm0 2a8 8 0 1 0 0 16 8 8 0 0 0 0-16Zm1 3v4.6l3.2 3.2-1.4 1.4-3.8-3.8V7h2Z"/></svg>
                                ${empty horaDashboard ? '--:--' : horaDashboard}
                            </span>
                        </div>
                    </div>
                    <div class="hero-visual hero-banner" aria-hidden="true">
                        <img src="${pageContext.request.contextPath}/img/banner-truck.png" alt="">
                        <svg class="delivery-map hero-delivery-map" viewBox="0 0 640 300" preserveAspectRatio="none">
                            <defs>
                                <linearGradient id="heroRouteGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                                    <stop offset="0%" stop-color="#5cd214" stop-opacity=".28"/>
                                    <stop offset="45%" stop-color="#c8ff96" stop-opacity=".92"/>
                                    <stop offset="100%" stop-color="#5cd214" stop-opacity=".68"/>
                                </linearGradient>
                                <filter id="heroRouteGlow" x="-20%" y="-40%" width="140%" height="180%">
                                    <feGaussianBlur stdDeviation="3" result="blur"/>
                                    <feMerge>
                                        <feMergeNode in="blur"/>
                                        <feMergeNode in="SourceGraphic"/>
                                    </feMerge>
                                </filter>
                            </defs>
                            <g class="hero-signal-grid">
                                <path d="M52 76H588M52 142H588M52 208H588"/>
                                <path d="M114 50V248M238 50V248M362 50V248M486 50V248"/>
                            </g>
                            <path class="route-track hero-route-track"
                                  d="M38 250 C116 230 168 204 236 214 C304 224 348 246 420 226 C494 206 542 226 604 190"/>
                            <path class="route-line route-line-strong hero-route-main"
                                  d="M38 250 C116 230 168 204 236 214 C304 224 348 246 420 226 C494 206 542 226 604 190"
                                  filter="url(#heroRouteGlow)"/>
                            <path class="route-flow hero-route-flow"
                                  d="M38 250 C116 230 168 204 236 214 C304 224 348 246 420 226 C494 206 542 226 604 190"/>
                            <path class="hero-route-scan"
                                  d="M38 250 C116 230 168 204 236 214 C304 224 348 246 420 226 C494 206 542 226 604 190"/>
                            <g class="route-checkpoints">
                                <circle cx="38" cy="250" r="5"/>
                                <circle cx="236" cy="214" r="5"/>
                                <circle cx="420" cy="226" r="5"/>
                                <circle cx="604" cy="190" r="7" class="route-end"/>
                            </g>
                            <circle r="4.5" class="route-dot hero-route-dot">
                                <animateMotion dur="6.2s" repeatCount="indefinite"
                                               path="M38 250 C116 230 168 204 236 214 C304 224 348 246 420 226 C494 206 542 226 604 190"/>
                            </circle>
                            <circle r="3.4" class="route-dot hero-route-dot-secondary">
                                <animateMotion dur="6.2s" begin="1.7s" repeatCount="indefinite"
                                               path="M38 250 C116 230 168 204 236 214 C304 224 348 246 420 226 C494 206 542 226 604 190"/>
                            </circle>
                        </svg>
                        <div class="hero-banner-telemetry">
                            <span class="telemetry-chip telemetry-green">
                                <i></i>
                                <strong>${empty fretesAndamento ? 0 : fretesAndamento}</strong>
                                <small>em andamento</small>
                            </span>
                            <span class="telemetry-chip telemetry-amber">
                                <i></i>
                                <strong>${empty aguardandoColeta ? 0 : aguardandoColeta}</strong>
                                <small>coleta</small>
                            </span>
                            <span class="telemetry-chip telemetry-red">
                                <i></i>
                                <strong>${empty fretesAtrasados ? 0 : fretesAtrasados}</strong>
                                <small>atrasados</small>
                            </span>
                            <span class="telemetry-chip telemetry-blue">
                                <i></i>
                                <strong>${empty entregasHoje ? 0 : entregasHoje}</strong>
                                <small>hoje</small>
                            </span>
                        </div>
                    </div>
                </section>

                <section class="dashboard-stats">
                    <article class="card stat-card dashboard-stat">
                        <div class="stat-icon">
                            <svg viewBox="0 0 24 24"><path d="m12 3 8 4.3v9.4L12 21l-8-4.3V7.3L12 3Zm0 2.2L6.4 8.1 12 11l5.6-2.9L12 5.2Zm-6 4.6v5.7l5 2.7v-5.7L6 9.8Zm12 0-5 2.7v5.7l5-2.7V9.8Z"/></svg>
                        </div>
                        <div>
                            <div class="stat-label">Fretes ativos</div>
                            <div class="stat-value">${empty totalFretes ? 0 : totalFretes}</div>
                            <div class="stat-trend up">18% vs mês anterior</div>
                        </div>
                    </article>

                    <article class="card stat-card dashboard-stat">
                        <div class="stat-icon">
                            <svg viewBox="0 0 24 24"><path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm-8 9a8 8 0 0 1 16 0h-2a6 6 0 0 0-12 0H4Zm15-9v-3h-3V7h3V4h2v3h3v2h-3v3h-2Z"/></svg>
                        </div>
                        <div>
                            <div class="stat-label">Clientes ativos</div>
                            <div class="stat-value">${empty totalClientes ? 0 : totalClientes}</div>
                            <div class="stat-trend up">12% vs mês anterior</div>
                        </div>
                    </article>

                    <article class="card stat-card dashboard-stat">
                        <div class="stat-icon">
                            <svg viewBox="0 0 24 24"><path d="M4 5h11v9h2.1l1.8-3H22v6h-2.1a3 3 0 0 1-5.8 0H9.9a3 3 0 0 1-5.8 0H2V7a2 2 0 0 1 2-2Zm0 2v8.2a3 3 0 0 1 5.4-.2H13V7H4Zm11 8h.6a3 3 0 0 1 4.2 0h.2v-2h-.9l-1.8 3H15v-1Z"/></svg>
                        </div>
                        <div>
                            <div class="stat-label">Motoristas ativos</div>
                            <div class="stat-value">${empty totalMotoristas ? 0 : totalMotoristas}</div>
                            <div class="stat-trend up">7% vs mês anterior</div>
                        </div>
                    </article>

                    <article class="card stat-card dashboard-stat">
                        <div class="stat-icon">
                            <svg viewBox="0 0 24 24"><path d="M5 7h11a2 2 0 0 1 2 2v2h1.5l2.5 3.2V18h-2.1a3 3 0 0 1-5.8 0H9.9a3 3 0 0 1-5.8 0H2V10a3 3 0 0 1 3-3Zm0 2a1 1 0 0 0-1 1v6h.8a3 3 0 0 1 4.4 0H16V9H5Z"/></svg>
                        </div>
                        <div>
                            <div class="stat-label">Veículos disponíveis</div>
                            <div class="stat-value">${empty totalVeiculos ? 0 : totalVeiculos}</div>
                            <div class="stat-trend up">5% vs mês anterior</div>
                        </div>
                    </article>
                </section>

                <section class="dashboard-lower">
                    <article class="card quick-card">
                        <div class="card-heading">
                            <h2>Ações rápidas</h2>
                        </div>
                        <div class="quick-grid">
                            <a href="${pageContext.request.contextPath}/fretes?acao=novo" class="quick-action">
                                <svg viewBox="0 0 24 24"><path d="M5 7h11a2 2 0 0 1 2 2v2h1.5l2.5 3.2V18h-2.1a3 3 0 0 1-5.8 0H9.9a3 3 0 0 1-5.8 0H2V10a3 3 0 0 1 3-3Z"/></svg>
                                Novo frete
                            </a>
                            <a href="${pageContext.request.contextPath}/clientes?acao=novo" class="quick-action">
                                <svg viewBox="0 0 24 24"><path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm-8 9a8 8 0 0 1 16 0h-2a6 6 0 0 0-12 0H4Zm15-9v-3h-3V7h3V4h2v3h3v2h-3v3h-2Z"/></svg>
                                Cadastrar cliente
                            </a>
                            <a href="${pageContext.request.contextPath}/motoristas?acao=novo" class="quick-action">
                                <svg viewBox="0 0 24 24"><path d="M4 5h11v9h2.1l1.8-3H22v6h-2.1a3 3 0 0 1-5.8 0H9.9a3 3 0 0 1-5.8 0H2V7a2 2 0 0 1 2-2Z"/></svg>
                                Cadastrar motorista
                            </a>
                            <a href="${pageContext.request.contextPath}/veiculos?acao=novo" class="quick-action">
                                <svg viewBox="0 0 24 24"><path d="M5 7h11a2 2 0 0 1 2 2v2h1.5l2.5 3.2V18h-2.1a3 3 0 0 1-5.8 0H9.9a3 3 0 0 1-5.8 0H2V10a3 3 0 0 1 3-3Z"/></svg>
                                Cadastrar veículo
                            </a>
                            <a href="${pageContext.request.contextPath}/fretes" class="quick-action">
                                <svg viewBox="0 0 24 24"><path d="M6 2h9l5 5v15H6V2Zm8 2H8v16h10V8h-4V4Zm-3 8h5v2h-5v-2Zm0 4h5v2h-5v-2Z"/></svg>
                                Emitir CTe
                            </a>
                            <a href="${pageContext.request.contextPath}/relatorios" class="quick-action">
                                <svg viewBox="0 0 24 24"><path d="M4 20V5h2v13h14v2H4Zm4-4V9h3v7H8Zm5 0V4h3v12h-3Zm5 0v-5h3v5h-3Z"/></svg>
                                Ver relatórios
                            </a>
                        </div>
                        <a href="${pageContext.request.contextPath}/fretes" class="wide-link">Todas as ações <span>→</span></a>
                    </article>

                    <article class="card performance-card">
                        <div class="card-heading">
                            <h2>Desempenho de fretes</h2>
                            <span>Últimos 7 dias</span>
                        </div>
                        <div class="chart-legend">
                            <span><i class="green-dot"></i> Entregues</span>
                            <span><i class="muted-dot"></i> Pendentes</span>
                        </div>
                        <div class="chart-wrap" aria-hidden="true">
                            <svg viewBox="0 0 640 220" preserveAspectRatio="none">
                                <path class="grid-line" d="M0 40H640M0 90H640M0 140H640M0 190H640"/>
                                <path class="line-muted" d="M18 176 118 178 218 162 318 157 418 170 518 176 622 160"/>
                                <path class="line-green" d="M18 132 118 116 218 82 318 104 418 88 518 118 622 72"/>
                                <circle cx="218" cy="82" r="5" class="point-green"/>
                                <circle cx="622" cy="72" r="5" class="point-green"/>
                            </svg>
                        </div>
                        <div class="performance-summary">
                            <div><strong>${empty entregasHoje ? 0 : entregasHoje}</strong><span>Entregas hoje</span></div>
                            <div><strong>${empty aguardandoColeta ? 0 : aguardandoColeta}</strong><span>Pendentes coleta</span></div>
                            <div><strong>87.3%</strong><span>Taxa de sucesso</span></div>
                        </div>
                    </article>
                </section>
            </div>

            <aside class="dashboard-rail">
                <article class="card operation-card">
                    <div class="card-heading">
                        <h2>Resumo operacional</h2>
                    </div>
                    <div class="operation-list">
                        <a href="${pageContext.request.contextPath}/fretes" class="operation-item green">
                            <span><small>Fretes em andamento</small><strong>${empty fretesAndamento ? 0 : fretesAndamento}</strong><em>Ver detalhes →</em></span>
                            <b></b>
                        </a>
                        <a href="${pageContext.request.contextPath}/fretes?statusFiltro=E" class="operation-item amber">
                            <span><small>Aguardando coleta</small><strong>${empty aguardandoColeta ? 0 : aguardandoColeta}</strong><em>Ver detalhes →</em></span>
                            <b></b>
                        </a>
                        <a href="${pageContext.request.contextPath}/fretes" class="operation-item red">
                            <span><small>Atrasados</small><strong>${empty fretesAtrasados ? 0 : fretesAtrasados}</strong><em>Ver detalhes →</em></span>
                            <b></b>
                        </a>
                        <a href="${pageContext.request.contextPath}/fretes?statusFiltro=R" class="operation-item blue">
                            <span><small>Entregas hoje</small><strong>${empty entregasHoje ? 0 : entregasHoje}</strong><em>Ver detalhes →</em></span>
                            <b></b>
                        </a>
                    </div>
                </article>

                <article class="card activity-card">
                    <div class="card-heading">
                        <h2>Atividades recentes</h2>
                        <a href="${pageContext.request.contextPath}/fretes">Ver todas</a>
                    </div>
                    <div class="activity-list">
                        <a href="${pageContext.request.contextPath}/fretes" class="activity-item">
                            <i class="activity-icon green"></i>
                            <span><strong>CTe emitido com sucesso</strong><small>Frete registrado no painel</small></span>
                            <time>09:21</time>
                        </a>
                        <a href="${pageContext.request.contextPath}/fretes?statusFiltro=R" class="activity-item">
                            <i class="activity-icon green"></i>
                            <span><strong>Entrega concluída</strong><small>Atualização operacional</small></span>
                            <time>08:45</time>
                        </a>
                        <a href="${pageContext.request.contextPath}/fretes?acao=novo" class="activity-item">
                            <i class="activity-icon blue"></i>
                            <span><strong>Novo frete criado</strong><small>Aguardando acompanhamento</small></span>
                            <time>08:12</time>
                        </a>
                        <a href="${pageContext.request.contextPath}/clientes" class="activity-item">
                            <i class="activity-icon blue"></i>
                            <span><strong>Cliente atualizado</strong><small>Cadastro revisado</small></span>
                            <time>07:58</time>
                        </a>
                    </div>
                    <a href="${pageContext.request.contextPath}/fretes" class="wide-link">Ver todas as atividades <span>→</span></a>
                </article>
            </aside>
        </section>

    </main>
</div>

</body>
</html>
