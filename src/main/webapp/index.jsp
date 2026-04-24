<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard – FiscalMove FMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Exo+2:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<%@ include file="/jsp/NavBar.jsp" %>

<div class="main-wrapper">

    <!-- Topbar -->
    <div class="topbar">
        <div class="topbar-title">Dashboard</div>
        <div class="topbar-actions">
            <button class="topbar-btn">
                🔔
            </button>
            <a href="${pageContext.request.contextPath}/fretes?acao=novo" class="btn btn-primary btn-sm">
                + Novo Frete
            </a>
        </div>
    </div>

    <!-- Conteúdo -->
    <div class="container">

        <!-- Boas vindas -->
        <div style="margin-bottom:28px;">
            <h1 style="font-family:'Rajdhani',sans-serif;font-size:1.7rem;font-weight:700;">
                Olá, <span style="color:var(--green);">${sessionScope.usuarioLogado.nome}</span> 👋
            </h1>
            <p style="color:var(--text-muted);font-size:.88rem;margin-top:4px;">
                Bem-vindo de volta ao FiscalMove FMS. Aqui está um resumo do sistema.
            </p>
        </div>

        <!-- Stats row -->
        <div class="card-grid" style="grid-template-columns:repeat(auto-fill,minmax(200px,1fr));margin-bottom:28px;">

            <div class="card stat-card">
                <div class="stat-icon">📦</div>
                <div>
                    <div class="stat-value">—</div>
                    <div class="stat-label">Fretes ativos</div>
                </div>
            </div>

            <div class="card stat-card">
                <div class="stat-icon">👤</div>
                <div>
                    <div class="stat-value">—</div>
                    <div class="stat-label">Clientes</div>
                </div>
            </div>

            <div class="card stat-card">
                <div class="stat-icon">🚛</div>
                <div>
                    <div class="stat-value">—</div>
                    <div class="stat-label">Motoristas ativos</div>
                </div>
            </div>

            <div class="card stat-card">
                <div class="stat-icon">🚚</div>
                <div>
                    <div class="stat-value">—</div>
                    <div class="stat-label">Veículos disponíveis</div>
                </div>
            </div>

        </div>

        <!-- Menu rápido -->
        <h2 style="font-family:'Rajdhani',sans-serif;font-size:1.15rem;font-weight:700;
                   color:var(--text-muted);margin-bottom:16px;letter-spacing:.5px;text-transform:uppercase;">
            Acesso Rápido
        </h2>

        <div class="card-grid">

            <a href="${pageContext.request.contextPath}/fretes" class="card-link">
                <div class="card card-menu">
                    <div class="card-icon">📦</div>
                    <h3>Fretes</h3>
                    <p>Emissão e acompanhamento de fretes</p>
                </div>
            </a>

            <a href="${pageContext.request.contextPath}/clientes" class="card-link">
                <div class="card card-menu">
                    <div class="card-icon">👤</div>
                    <h3>Clientes</h3>
                    <p>Remetentes e destinatários</p>
                </div>
            </a>

            <a href="${pageContext.request.contextPath}/motoristas" class="card-link">
                <div class="card card-menu">
                    <div class="card-icon">🚛</div>
                    <h3>Motoristas</h3>
                    <p>Cadastro e controle de motoristas</p>
                </div>
            </a>

            <a href="${pageContext.request.contextPath}/veiculos" class="card-link">
                <div class="card card-menu">
                    <div class="card-icon">🚚</div>
                    <h3>Veículos</h3>
                    <p>Frota e disponibilidade</p>
                </div>
            </a>

        </div>

        <!-- Info strip -->
        <div style="margin-top:32px;padding:16px 20px;background:var(--green-dim);
                    border:1px solid rgba(109,197,42,.15);border-radius:var(--radius);
                    display:flex;align-items:center;gap:14px;">
            <span style="font-size:1.4rem;">🚀</span>
            <div>
                <div style="font-family:'Rajdhani',sans-serif;font-weight:700;font-size:1rem;">
                    FiscalMove FMS — v1.0
                </div>
                <div style="font-size:.8rem;color:var(--text-muted);">
                    Sistema de gestão de fretes. Motoristas · Veículos · Clientes · Emissão de CTe
                </div>
            </div>
        </div>

    </div>
</div>

</body>
</html>