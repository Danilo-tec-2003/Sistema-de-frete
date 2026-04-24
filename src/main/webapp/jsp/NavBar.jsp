<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- ============================================================
     FiscalMove – Sidebar + Topbar + Loader
     Incluir em todas as páginas protegidas:
       <%@ include file="/jsp/NavBar.jsp" %>
============================================================ --%>

<!-- ── Loader pneu ─────────────────────────────────────────── -->
<div id="fm-loader">
    <div class="loader-wheel">
        <div class="rim"></div>
        <div class="tire"></div>
        <div class="hub"></div>
    </div>
    <div class="loader-speed">
        <span></span><span></span><span></span>
    </div>
    <div class="loader-text">Carregando…</div>
</div>

<!-- ── Overlay mobile ─────────────────────────────────────── -->
<div class="sidebar-overlay" id="sidebarOverlay"></div>

<!-- ── Toggle mobile ──────────────────────────────────────── -->
<button class="sidebar-toggle" id="sidebarToggle" aria-label="Abrir menu">
    <span></span><span></span><span></span>
</button>

<!-- ════════════════════════════════════════════════════════════
     SIDEBAR
════════════════════════════════════════════════════════════ -->
<aside class="sidebar" id="sidebar">

    <!-- Brand -->
    <div class="sidebar-brand">
        <div class="brand-icon">
            <!-- Ícone caminhão SVG -->
            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path d="M20 8h-3V4H3c-1.1 0-2 .9-2 2v11h2c0 1.66 1.34 3 3 3s3-1.34 3-3h6c0 1.66 1.34 3 3 3s3-1.34 3-3h2v-5l-3-4zM6 18.5c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zm13.5-9l1.96 2.5H17V9.5h2.5zm-1.5 9c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5z"/>
            </svg>
        </div>
        <div class="brand-name">
            <span>Fiscal</span><span>Move</span>
        </div>
    </div>

    <!-- Navegação principal -->
    <nav class="sidebar-nav">

        <div class="nav-section-label">Principal</div>

        <a href="${pageContext.request.contextPath}/home"
           class="nav-item ${pageContext.request.servletPath.contains('/home') ? 'active' : ''}">
            <span class="nav-icon">🏠</span>
            <span class="nav-label">Dashboard</span>
        </a>

        <a href="${pageContext.request.contextPath}/fretes"
           class="nav-item ${pageContext.request.servletPath.contains('/fretes') ? 'active' : ''}">
            <span class="nav-icon">📦</span>
            <span class="nav-label">Fretes</span>
        </a>

        <div class="nav-section-label" style="margin-top:10px;">Cadastros</div>

        <a href="${pageContext.request.contextPath}/clientes"
           class="nav-item ${pageContext.request.servletPath.contains('/clientes') ? 'active' : ''}">
            <span class="nav-icon">👤</span>
            <span class="nav-label">Clientes</span>
        </a>

        <a href="${pageContext.request.contextPath}/motoristas"
           class="nav-item ${pageContext.request.servletPath.contains('/motoristas') ? 'active' : ''}">
            <span class="nav-icon">🚛</span>
            <span class="nav-label">Motoristas</span>
        </a>

        <a href="${pageContext.request.contextPath}/veiculos"
           class="nav-item ${pageContext.request.servletPath.contains('/veiculos') ? 'active' : ''}">
            <span class="nav-icon">🚚</span>
            <span class="nav-label">Veículos</span>
        </a>

        <div class="nav-section-label" style="margin-top:10px;">Sistema</div>

        <a href="${pageContext.request.contextPath}/logout"
           class="nav-item"
           onclick="return confirm('Deseja sair do sistema?')">
            <span class="nav-icon">🚪</span>
            <span class="nav-label">Sair</span>
        </a>

    </nav>

    <!-- Usuário logado -->
    <div class="sidebar-footer">
        <div class="user-card">
            <div class="user-avatar">
                ${not empty sessionScope.usuarioLogado ? fn:substring(sessionScope.usuarioLogado.nome,0,2) : 'FM'}
            </div>
        </div>
    </div>

</aside>

<!-- ════════════════════════════════════════════════════════════
     TOPBAR (injetada dentro do .main-wrapper de cada página)
     Cada página deve abrir o .main-wrapper antes de incluir
     este arquivo, OU usar o padrão abaixo via JS.
════════════════════════════════════════════════════════════ -->
<script>
/* ── Sidebar toggle ──────────────────────────────────────── */
(function () {
    const toggle   = document.getElementById('sidebarToggle');
    const sidebar  = document.getElementById('sidebar');
    const overlay  = document.getElementById('sidebarOverlay');

    function openSidebar() {
        sidebar.classList.add('open');
        overlay.classList.add('active');
        document.body.style.overflow = 'hidden';
    }
    function closeSidebar() {
        sidebar.classList.remove('open');
        overlay.classList.remove('active');
        document.body.style.overflow = '';
    }

    toggle  && toggle.addEventListener('click', openSidebar);
    overlay && overlay.addEventListener('click', closeSidebar);

    /* ── Active nav highlight ────────────────────────────── */
    const path = window.location.pathname;
    document.querySelectorAll('.nav-item').forEach(function (item) {
        const href = item.getAttribute('href') || '';
        if (href && path.includes(href.split('/').pop())) {
            item.classList.add('active');
        }
    });

    /* ── Loader ─────────────────────────────────────────── */
    const loader = document.getElementById('fm-loader');
    function showLoader() {
        if (loader) loader.classList.add('active');
    }
    function hideLoader() {
        if (loader) loader.classList.remove('active');
    }

    /* Mostrar loader em links de navegação (exceto âncoras e botões de filtro) */
    document.querySelectorAll('a[href]').forEach(function (a) {
        const href = a.getAttribute('href');
        if (!href || href.startsWith('#') || href.startsWith('javascript') || href.startsWith('mailto')) return;
        if (a.getAttribute('onclick')) return;
        a.addEventListener('click', function (e) {
            if (e.ctrlKey || e.metaKey || e.shiftKey) return;
            showLoader();
        });
    });

    /* Mostrar loader em submit de formulários */
    document.querySelectorAll('form').forEach(function (form) {
        /* Não mostrar no filtro de busca (GET simples) */
        if (form.method.toLowerCase() === 'get' && !form.action.includes('acao=')) return;
        form.addEventListener('submit', showLoader);
    });

    /* Esconder ao carregar a página */
    window.addEventListener('pageshow', hideLoader);
    window.addEventListener('load', hideLoader);

    /* ── Ripple nos botões ───────────────────────────────── */
    document.querySelectorAll('.btn').forEach(function (btn) {
        btn.classList.add('ripple');
        btn.addEventListener('click', function (e) {
            const rect   = btn.getBoundingClientRect();
            const size   = Math.max(rect.width, rect.height);
            const x      = e.clientX - rect.left - size / 2;
            const y      = e.clientY - rect.top  - size / 2;
            const ripple = document.createElement('span');
            ripple.className = 'ripple-effect';
            Object.assign(ripple.style, {
                width: size + 'px', height: size + 'px',
                left:  x + 'px',   top:    y + 'px'
            });
            btn.appendChild(ripple);
            ripple.addEventListener('animationend', function () { ripple.remove(); });
        });
    });
})();
</script>