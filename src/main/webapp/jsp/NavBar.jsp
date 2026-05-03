<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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

<div class="sidebar-overlay" id="sidebarOverlay"></div>

<button class="sidebar-toggle" id="sidebarToggle" aria-label="Abrir menu">
    <span></span><span></span><span></span>
</button>

<aside class="sidebar" id="sidebar">

    <div class="sidebar-brand">
        <div class="brand-icon">
            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path d="M20 8h-3V4H3c-1.1 0-2 .9-2 2v11h2c0 1.66 1.34 3 3 3s3-1.34 3-3h6c0 1.66 1.34 3 3 3s3-1.34 3-3h2v-5l-3-4zM6 18.5c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zm13.5-9l1.96 2.5H17V9.5h2.5zm-1.5 9c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5z"/>
            </svg>
        </div>
        <div class="brand-name">
            <span>Fiscal</span><span>Move</span>
        </div>
    </div>

    <nav class="sidebar-nav" aria-label="Navegação principal">

        <a href="${pageContext.request.contextPath}/home"
           class="nav-item ${pageContext.request.servletPath.contains('/home') ? 'active' : ''}">
            <span class="nav-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24"><path d="M3 11.2 12 4l9 7.2v8.3a1.5 1.5 0 0 1-1.5 1.5h-5v-6h-5v6h-5A1.5 1.5 0 0 1 3 19.5v-8.3Z"/></svg>
            </span>
            <span class="nav-label">Dashboard</span>
        </a>

        <a href="${pageContext.request.contextPath}/fretes"
           class="nav-item ${pageContext.request.servletPath.contains('/fretes') ? 'active' : ''}">
            <span class="nav-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24"><path d="m12 3 8 4.3v9.4L12 21l-8-4.3V7.3L12 3Zm0 2.2L6.4 8.1 12 11l5.6-2.9L12 5.2Zm-6 4.6v5.7l5 2.7v-5.7L6 9.8Zm12 0-5 2.7v5.7l5-2.7V9.8Z"/></svg>
            </span>
            <span class="nav-label">Fretes</span>
        </a>

        <a href="${pageContext.request.contextPath}/relatorios"
           class="nav-item ${pageContext.request.servletPath.contains('/relatorios') ? 'active' : ''}">
            <span class="nav-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24"><path d="M4 20V5h2v13h14v2H4Zm4-4V9h3v7H8Zm5 0V4h3v12h-3Zm5 0v-5h3v5h-3Z"/></svg>
            </span>
            <span class="nav-label">Relatórios</span>
        </a>

        <a href="${pageContext.request.contextPath}/clientes"
           class="nav-item ${pageContext.request.servletPath.contains('/clientes') ? 'active' : ''}">
            <span class="nav-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24"><path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm-8 9a8 8 0 0 1 16 0h-2a6 6 0 0 0-12 0H4Z"/></svg>
            </span>
            <span class="nav-label">Clientes</span>
        </a>

        <a href="${pageContext.request.contextPath}/motoristas"
           class="nav-item ${pageContext.request.servletPath.contains('/motoristas') ? 'active' : ''}">
            <span class="nav-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24"><path d="M4 5h11v9h2.1l1.8-3H22v6h-2.1a3 3 0 0 1-5.8 0H9.9a3 3 0 0 1-5.8 0H2V7a2 2 0 0 1 2-2Zm0 2v8.2a3 3 0 0 1 5.4-.2H13V7H4Zm11 8h.6a3 3 0 0 1 4.2 0h.2v-2h-.9l-1.8 3H15v-1Zm-8 3.5a1 1 0 1 0 0-2 1 1 0 0 0 0 2Zm10 0a1 1 0 1 0 0-2 1 1 0 0 0 0 2Z"/></svg>
            </span>
            <span class="nav-label">Motoristas</span>
        </a>

        <a href="${pageContext.request.contextPath}/veiculos"
           class="nav-item ${pageContext.request.servletPath.contains('/veiculos') ? 'active' : ''}">
            <span class="nav-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24"><path d="M5 7h11a2 2 0 0 1 2 2v2h1.5l2.5 3.2V18h-2.1a3 3 0 0 1-5.8 0H9.9a3 3 0 0 1-5.8 0H2V10a3 3 0 0 1 3-3Zm0 2a1 1 0 0 0-1 1v6h.8a3 3 0 0 1 4.4 0H16V9H5Zm13 4v3h.8a3 3 0 0 1 1.2-.8V15l-1.5-2H18ZM7 18.5a1 1 0 1 0 0-2 1 1 0 0 0 0 2Zm10 0a1 1 0 1 0 0-2 1 1 0 0 0 0 2Z"/></svg>
            </span>
            <span class="nav-label">Veículos</span>
        </a>

    </nav>

    <div class="sidebar-footer">
        <div class="system-card">
            <div class="system-status"><span></span> Sistema operacional</div>
            <small>Todos os serviços ativos</small>
            <div class="system-spark" aria-hidden="true"></div>
        </div>

        <a href="${pageContext.request.contextPath}/logout"
           class="nav-item sidebar-exit"
           data-confirm="Deseja sair do sistema?">
            <span class="nav-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24"><path d="M4 4h8v2H6v12h6v2H4V4Zm11.6 4.4 1.4-1.4L22 12l-5 5-1.4-1.4 2.6-2.6H10v-2h8.2l-2.6-2.6Z"/></svg>
            </span>
            <span class="nav-label">Sair</span>
        </a>

        <div class="user-card">
            <div class="user-avatar">
                ${not empty sessionScope.usuarioLogado ? fn:substring(sessionScope.usuarioLogado.nome,0,2) : 'FM'}
            </div>
            <div class="user-info">
                <div class="user-name">${not empty sessionScope.usuarioLogado ? sessionScope.usuarioLogado.nome : 'Administrador'}</div>
                <div class="user-role">FiscalMove FMS</div>
            </div>
        </div>

        <div class="brand-version">
            FiscalMove FMS - v1.0<br>
            2026 &copy; Todos os direitos reservados
        </div>
    </div>

</aside>

<script>
(function () {
    const contextPath = '${pageContext.request.contextPath}';
    const userName = "${fn:escapeXml(not empty sessionScope.usuarioLogado ? sessionScope.usuarioLogado.nome : 'Administrador')}";
    const userInitials = "${not empty sessionScope.usuarioLogado ? fn:substring(sessionScope.usuarioLogado.nome,0,2) : 'AD'}";

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

    const path = window.location.pathname;
    document.querySelectorAll('.nav-item').forEach(function (item) {
        const href = item.getAttribute('href') || '';
        if (href && path.includes(href.split('/').pop())) {
            item.classList.add('active');
        }
    });

    function enhanceTopbar() {
        const topbar = document.querySelector('.topbar');
        if (!topbar || topbar.querySelector('.topbar-search')) return;

        const title = topbar.querySelector('.topbar-title');
        if (title && !title.querySelector('.topbar-kicker')) {
            const kicker = document.createElement('span');
            kicker.className = 'topbar-kicker';
            kicker.innerHTML = '<span></span> Tudo em dia, tudo sob controle.';
            title.appendChild(kicker);
        }

        let actions = topbar.querySelector('.topbar-actions');
        if (!actions) {
            actions = document.createElement('div');
            actions.className = 'topbar-actions';
            topbar.appendChild(actions);
        }

        const search = document.createElement('form');
        search.className = 'topbar-search';
        search.setAttribute('role', 'search');
        search.innerHTML =
            '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M10.5 4a6.5 6.5 0 0 1 5.2 10.4l4 4-1.4 1.4-4-4A6.5 6.5 0 1 1 10.5 4Zm0 2a4.5 4.5 0 1 0 0 9 4.5 4.5 0 0 0 0-9Z"/></svg>' +
            '<input type="search" name="filtro" placeholder="Buscar no sistema..." aria-label="Buscar no sistema">' +
            '<kbd>⌘ K</kbd>';
        search.addEventListener('submit', function (event) {
            event.preventDefault();
            const termo = search.querySelector('input').value.trim();
            if (termo) {
                window.location.href = contextPath + '/fretes?filtro=' + encodeURIComponent(termo);
            }
        });

        const utilities = document.createElement('div');
        utilities.className = 'topbar-utilities';
        utilities.innerHTML =
            '<a href="' + contextPath + '/fretes" class="icon-btn" aria-label="Notificações"><svg viewBox="0 0 24 24"><path d="M12 22a2.3 2.3 0 0 0 2.2-1.6H9.8A2.3 2.3 0 0 0 12 22Zm7-5-1.8-2.2V10a5.2 5.2 0 0 0-4.2-5.1V3h-2v1.9A5.2 5.2 0 0 0 6.8 10v4.8L5 17v1.5h14V17Z"/></svg><span>3</span></a>' +
            '<div class="topbar-user"><div class="user-avatar">' + userInitials + '</div><div><strong>' + userName + '</strong><small>FiscalMove FMS</small></div><svg viewBox="0 0 24 24"><path d="m7 10 5 5 5-5H7Z"/></svg></div>';

        topbar.insertBefore(search, actions);
        topbar.insertBefore(utilities, actions);

        document.addEventListener('keydown', function (event) {
            if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k') {
                event.preventDefault();
                const input = search.querySelector('input');
                input && input.focus();
            }
        });
    }

    enhanceTopbar();

    const loader = document.getElementById('fm-loader');
    function showLoader() {
        if (loader) loader.classList.add('active');
    }
    function hideLoader() {
        if (loader) loader.classList.remove('active');
    }

    document.querySelectorAll('a[href]').forEach(function (a) {
        const href = a.getAttribute('href');
        if (!href || href.startsWith('#') || href.startsWith('javascript') || href.startsWith('mailto')) return;
        if (a.getAttribute('onclick')) return;
        a.addEventListener('click', function (e) {
            if (e.ctrlKey || e.metaKey || e.shiftKey) return;
            showLoader();
        });
    });

    document.querySelectorAll('form').forEach(function (form) {
        if (form.method.toLowerCase() === 'get' && !form.action.includes('acao=')) return;
        form.addEventListener('submit', showLoader);
    });

    window.addEventListener('pageshow', hideLoader);
    window.addEventListener('load', hideLoader);

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
<script type="module" src="${pageContext.request.contextPath}/js/validacoes.js"></script>
