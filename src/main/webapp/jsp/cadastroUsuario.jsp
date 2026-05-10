<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Criar Conta – FiscalMove FMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Exo+2:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script type="module" src="${pageContext.request.contextPath}/js/validacoes.js"></script>
</head>
<body class="login-page auth-page auth-register-page">

<main class="auth-shell auth-shell-register auth-stage">
    <section class="auth-visual" aria-hidden="true">
        <img src="${pageContext.request.contextPath}/img/banner-truck.png" alt="">
        <svg class="delivery-map auth-delivery-map" viewBox="0 0 1440 520" preserveAspectRatio="none">
            <defs>
                <filter id="authRouteGlowRegister" x="-20%" y="-40%" width="140%" height="180%">
                    <feGaussianBlur stdDeviation="3.5" result="blur"/>
                    <feMerge>
                        <feMergeNode in="blur"/>
                        <feMergeNode in="SourceGraphic"/>
                    </feMerge>
                </filter>
            </defs>
            <path class="route-track"
                  d="M28 470 C160 448 196 400 292 406 C430 414 468 492 650 506 C825 512 862 470 998 442 C1112 418 1190 446 1310 416 C1385 397 1382 352 1420 338"/>
            <path class="route-line route-line-strong"
                  d="M28 470 C160 448 196 400 292 406 C430 414 468 492 650 506 C825 512 862 470 998 442 C1112 418 1190 446 1310 416 C1385 397 1382 352 1420 338"
                  filter="url(#authRouteGlowRegister)"/>
            <path class="route-flow"
                  d="M28 470 C160 448 196 400 292 406 C430 414 468 492 650 506 C825 512 862 470 998 442 C1112 418 1190 446 1310 416 C1385 397 1382 352 1420 338"/>
            <g class="route-checkpoints">
                <circle cx="28" cy="470" r="8"/>
                <circle cx="292" cy="406" r="7"/>
                <circle cx="650" cy="506" r="7"/>
                <circle cx="998" cy="442" r="7"/>
                <circle cx="1420" cy="338" r="12" class="route-end"/>
            </g>
            <circle r="6" class="route-dot">
                <animateMotion dur="8.4s" repeatCount="indefinite"
                               path="M28 470 C160 448 196 400 292 406 C430 414 468 492 650 506 C825 512 862 470 998 442 C1112 418 1190 446 1310 416 C1385 397 1382 352 1420 338"/>
            </circle>
        </svg>
    </section>

<div class="login-box auth-card">

    <div class="login-logo">
        <div class="brand-row">
            <div class="logo-icon">
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

    <h2>Criar nova conta</h2>
    <p class="auth-card-subtitle">Preencha os campos abaixo para criar sua conta e começar a usar o sistema.</p>

    <form method="post" action="${pageContext.request.contextPath}/cadastroUsuario"
          autocomplete="off" id="cadastroForm">

        <div class="form-group" style="margin-bottom:16px;">
            <label for="nome">Nome completo</label>
            <div class="input-shell">
                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm-8 9a8 8 0 0 1 16 0h-2a6 6 0 0 0-12 0H4Z"/></svg>
                <input type="text" id="nome" name="nome"
                       class="form-control"
                       placeholder="Seu nome completo"
                       value="${nome}"
                       required>
            </div>
        </div>

        <div class="form-group" style="margin-bottom:16px;">
            <label for="login">Login</label>
            <div class="input-shell">
                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm-8 9a8 8 0 0 1 16 0h-2a6 6 0 0 0-12 0H4Z"/></svg>
                <input type="text" id="login" name="login"
                       class="form-control"
                       placeholder="Mínimo 4 caracteres"
                       minlength="4"
                       value="${login}"
                       required>
            </div>
        </div>

        <div class="form-group" style="margin-bottom:16px;">
            <label for="senha">Senha</label>
            <div class="password-field input-shell">
                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M17 9h1a2 2 0 0 1 2 2v9H4v-9a2 2 0 0 1 2-2h1V7a5 5 0 0 1 10 0v2Zm-8 0h6V7a3 3 0 0 0-6 0v2Z"/></svg>
                <input type="password" id="senha" name="senha"
                       class="form-control"
                       placeholder="Mínimo 6 caracteres"
                       minlength="6"
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

        <div class="form-group" style="margin-bottom:24px;">
            <label for="confirmaSenha">Confirmar senha</label>
            <div class="password-field input-shell">
                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M17 9h1a2 2 0 0 1 2 2v9H4v-9a2 2 0 0 1 2-2h1V7a5 5 0 0 1 10 0v2Zm-8 0h6V7a3 3 0 0 0-6 0v2Z"/></svg>
                <input type="password" id="confirmaSenha" name="confirmaSenha"
                       class="form-control"
                       placeholder="Repita a senha"
                       data-match="#senha"
                       data-match-message="As senhas não coincidem."
                       required>
                <button type="button" id="toggleConfirma"
                        class="password-toggle"
                        aria-label="Mostrar confirmação de senha"
                        aria-pressed="false">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <path d="M12 5c5 0 8.7 4.4 9.7 6.3a1.5 1.5 0 0 1 0 1.4C20.7 14.6 17 19 12 19s-8.7-4.4-9.7-6.3a1.5 1.5 0 0 1 0-1.4C3.3 9.4 7 5 12 5Zm0 2c-3.8 0-6.8 3.2-7.8 5 1 1.8 4 5 7.8 5s6.8-3.2 7.8-5C18.8 10.2 15.8 7 12 7Zm0 2.2A2.8 2.8 0 1 1 12 14.8 2.8 2.8 0 0 1 12 9.2Z"/>
                    </svg>
                </button>
            </div>
        </div>

        <button type="submit" class="btn btn-primary btn-block">
            Criar conta <span aria-hidden="true">→</span>
        </button>
    </form>

    <div class="login-footer">
        Já tem conta?
        <a href="${pageContext.request.contextPath}/login">Fazer login</a>
    </div>

    <div style="text-align:center;margin-top:28px;font-size:.68rem;color:var(--text-dim);letter-spacing:.5px;">
        FiscalMove FMS &nbsp;·&nbsp; v1.0
    </div>
</div>
</main>

<script>
function toggleInput(btnId, inputId, labelBase) {
    document.getElementById(btnId).addEventListener('click', function () {
        var inp = document.getElementById(inputId);
        inp.type = inp.type === 'password' ? 'text' : 'password';
        this.setAttribute('aria-pressed', inp.type === 'text' ? 'true' : 'false');
        this.setAttribute('aria-label', (inp.type === 'password' ? 'Mostrar ' : 'Ocultar ') + labelBase);
    });
}
toggleInput('toggleSenha', 'senha', 'senha');
toggleInput('toggleConfirma', 'confirmaSenha', 'confirmação de senha');

</script>
</body>
</html>
