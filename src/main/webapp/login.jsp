<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Login – FiscalMove FMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Exo+2:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script type="module" src="${pageContext.request.contextPath}/js/validacoes.js"></script>
</head>
<body class="login-page auth-page auth-login-page">

<main class="auth-shell auth-shell-login auth-stage">
    <section class="auth-visual" aria-hidden="true">
        <img src="${pageContext.request.contextPath}/img/banner-truck.png" alt="">
        <svg class="delivery-map auth-delivery-map" viewBox="0 0 1440 520" preserveAspectRatio="none">
            <defs>
                <filter id="authRouteGlowLogin" x="-20%" y="-40%" width="140%" height="180%">
                    <feGaussianBlur stdDeviation="3.5" result="blur"/>
                    <feMerge>
                        <feMergeNode in="blur"/>
                        <feMergeNode in="SourceGraphic"/>
                    </feMerge>
                </filter>
            </defs>
            <path class="route-track"
                  d="M28 468 C150 436 220 386 330 408 C465 434 540 510 692 502 C810 493 862 416 985 424 C1110 432 1168 512 1304 498 C1386 489 1376 402 1420 386"/>
            <path class="route-line route-line-strong"
                  d="M28 468 C150 436 220 386 330 408 C465 434 540 510 692 502 C810 493 862 416 985 424 C1110 432 1168 512 1304 498 C1386 489 1376 402 1420 386"
                  filter="url(#authRouteGlowLogin)"/>
            <path class="route-flow"
                  d="M28 468 C150 436 220 386 330 408 C465 434 540 510 692 502 C810 493 862 416 985 424 C1110 432 1168 512 1304 498 C1386 489 1376 402 1420 386"/>
            <g class="route-checkpoints">
                <circle cx="28" cy="468" r="8"/>
                <circle cx="330" cy="408" r="7"/>
                <circle cx="692" cy="502" r="7"/>
                <circle cx="985" cy="424" r="7"/>
                <circle cx="1420" cy="386" r="12" class="route-end"/>
            </g>
            <circle r="6" class="route-dot">
                <animateMotion dur="8s" repeatCount="indefinite"
                               path="M28 468 C150 436 220 386 330 408 C465 434 540 510 692 502 C810 493 862 416 985 424 C1110 432 1168 512 1304 498 C1386 489 1376 402 1420 386"/>
            </circle>
        </svg>
    </section>

    <section class="auth-hero-copy">
        <div class="auth-page-brand">
            <div class="logo-icon">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M20 8h-3V4H3c-1.1 0-2 .9-2 2v11h2c0 1.66 1.34 3 3 3s3-1.34 3-3h6c0 1.66 1.34 3 3 3s3-1.34 3-3h2v-5l-3-4zM6 18.5c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zm13.5-9l1.96 2.5H17V9.5h2.5zm-1.5 9c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5z"/>
                </svg>
            </div>
            <div>
                <div class="logo-text"><span class="w">Fiscal</span><span class="g">Move</span></div>
                <p>Freight Management System</p>
            </div>
        </div>
        <h1>Movimentamos cargas.<br><span>Impulsionamos resultados.</span></h1>
        <p>Gestão inteligente, rastreabilidade em tempo real e eficiência em cada entrega.</p>
    </section>

<div class="login-box auth-card">

    <div class="login-logo">
        <div class="brand-row">
            <div class="logo-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M20 8h-3V4H3c-1.1 0-2 .9-2 2v11h2c0 1.66 1.34 3 3 3s3-1.34 3-3h6c0 1.66 1.34 3 3 3s3-1.34 3-3h2v-5l-3-4zM6 18.5c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zm13.5-9l1.96 2.5H17V9.5h2.5zm-1.5 9c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5z"/>
                </svg>
            </div>
            <div class="logo-text">
                <span class="w">Fiscal</span><span class="g">Move</span>
            </div>
        </div>
        <p>Freight Management System</p>
    </div>

    <c:if test="${not empty erro}">
        <div class="alert alert-erro">${erro}</div>
    </c:if>

    <c:if test="${param.cadastro eq 'ok'}">
        <div class="alert alert-sucesso">
            ✓ Conta criada com sucesso! Faça login para continuar.
        </div>
    </c:if>

    <h2>Acesse sua conta</h2>
    <p class="auth-card-subtitle">Entre com suas credenciais para continuar.</p>

    <form method="post" action="${pageContext.request.contextPath}/login"
          autocomplete="off" id="loginForm">

        <div class="form-group">
            <label for="login">Login</label>
            <div class="input-shell">
                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm-8 9a8 8 0 0 1 16 0h-2a6 6 0 0 0-12 0H4Z"/></svg>
                <input type="text" id="login" name="login"
                       value="${loginDigitado}"
                       class="form-control"
                       placeholder="Seu usuário"
                       required>
            </div>
        </div>

        <div class="form-group">
            <label for="senha">Senha</label>
            <div class="password-field input-shell">
                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M17 9h1a2 2 0 0 1 2 2v9H4v-9a2 2 0 0 1 2-2h1V7a5 5 0 0 1 10 0v2Zm-8 0h6V7a3 3 0 0 0-6 0v2Z"/></svg>
                <input type="password" id="senha" name="senha"
                       class="form-control"
                       placeholder="Digite sua senha"
                       required>
                <button type="button" id="toggleSenha"
                        class="password-toggle"
                        aria-label="Mostrar senha"
                        aria-pressed="false">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <path d="M12 5c5 0 8.7 4.4 9.7 6.3a1.5 1.5 0 0 1 0 1.4C20.7 14.6 17 19 12 19s-8.7-4.4-9.7-6.3a1.5 1.5 0 0 1 0-1.4C3.3 9.4 7 5 12 5Zm0 2c-3.8 0-6.8 3.2-7.8 5 1 1.8 4 5 7.8 5s6.8-3.2 7.8-5C18.8 10.2 15.8 7 12 7Zm0 2.2A2.8 2.8 0 1 1 12 14.8 2.8 2.8 0 0 1 12 9.2Z"/>
                    </svg>
                </button>
            </div>
        </div>

        <div class="auth-form-options">
            <label><input type="checkbox" name="lembrar" checked> <span>Lembrar-me</span></label>
        </div>

        <button type="submit" class="btn btn-primary btn-block" style="margin-top:8px;">
            Entrar no Sistema <span aria-hidden="true">→</span>
        </button>
    </form>

    <div class="login-footer">
        Não tem conta?
        <a href="${pageContext.request.contextPath}/cadastroUsuario">Criar agora</a>
    </div>

    <div style="text-align:center;margin-top:28px;font-size:.68rem;color:var(--text-dim);letter-spacing:.5px;">
        FiscalMove FMS &nbsp;·&nbsp; v1.0
    </div>
</div>

    <div class="auth-trust-row">
        <span>
            <svg viewBox="0 0 24 24" aria-hidden="true">
                <path d="M12 2 4 5.5v6.2c0 5 3.4 8.7 8 10.3 4.6-1.6 8-5.3 8-10.3V5.5L12 2Zm0 2.2 6 2.6v4.9c0 3.8-2.4 6.6-6 8.1-3.6-1.5-6-4.3-6-8.1V6.8l6-2.6Z"/>
            </svg>
            <span>
                <strong>Dados protegidos</strong>
                <small>Segurança de ponta</small>
            </span>
        </span>
        <span>
            <svg viewBox="0 0 24 24" aria-hidden="true">
                <path d="M17 9h1a2 2 0 0 1 2 2v9H4v-9a2 2 0 0 1 2-2h1V7a5 5 0 0 1 10 0v2Zm-8 0h6V7a3 3 0 0 0-6 0v2Zm-3 2v7h12v-7H6Z"/>
            </svg>
            <span>
                <strong>Acesso seguro</strong>
                <small>Autenticação protegida</small>
            </span>
        </span>
        <span>
            <svg viewBox="0 0 24 24" aria-hidden="true">
                <path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Zm0 2a8 8 0 1 1 0 16 8 8 0 0 1 0-16Zm1 3v5.1l3.4 2-.9 1.7-4.5-2.7V7h2Z"/>
            </svg>
            <span>
                <strong>Disponível 24/7</strong>
                <small>Suporte sempre ativo</small>
            </span>
        </span>
    </div>

    <div class="auth-copyright">
        © 2026 FiscalMove. Todos os direitos reservados.
    </div>
</main>

<div id="fm-loader">
    <div class="loader-wheel">
        <div class="rim"></div>
        <div class="tire"></div>
        <div class="hub"></div>
    </div>
    <div class="loader-speed">
        <span></span><span></span><span></span>
    </div>
    <div class="loader-text">Autenticando…</div>
</div>

<script>
document.getElementById('toggleSenha').addEventListener('click', function () {
    var inp = document.getElementById('senha');
    inp.type = inp.type === 'password' ? 'text' : 'password';
    this.setAttribute('aria-pressed', inp.type === 'text' ? 'true' : 'false');
    this.setAttribute('aria-label', inp.type === 'password' ? 'Mostrar senha' : 'Ocultar senha');
});

document.getElementById('loginForm').addEventListener('submit', function () {
    var loader = document.getElementById('fm-loader');
    if (loader) loader.classList.add('active');
});

window.addEventListener('pageshow', function () {
    var loader = document.getElementById('fm-loader');
    if (loader) loader.classList.remove('active');
});

document.querySelectorAll('.btn').forEach(function (btn) {
    btn.addEventListener('click', function (e) {
        var rect   = btn.getBoundingClientRect();
        var size   = Math.max(rect.width, rect.height);
        var ripple = document.createElement('span');
        ripple.className = 'ripple-effect';
        ripple.style.cssText = 'width:'+size+'px;height:'+size+'px;'
            +'left:'+(e.clientX-rect.left-size/2)+'px;'
            +'top:'+(e.clientY-rect.top-size/2)+'px;';
        btn.style.position = 'relative';
        btn.style.overflow = 'hidden';
        btn.appendChild(ripple);
        ripple.addEventListener('animationend', function () { ripple.remove(); });
    });
});
</script>
</body>
</html>
