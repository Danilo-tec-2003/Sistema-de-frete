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
</head>
<body class="login-page">

<!-- Orb decorativo secundário -->
<div style="
    position:fixed; bottom:-120px; right:-100px;
    width:400px; height:400px; border-radius:50%;
    background:radial-gradient(circle, rgba(109,197,42,.08) 0%, transparent 70%);
    pointer-events:none;
"></div>

<div class="login-box">

    <!-- Logo -->
    <div class="login-logo">
        <div class="brand-row">
            <div class="logo-icon">
                <!-- Caminhão SVG -->
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

    <!-- Alertas -->
    <c:if test="${not empty erro}">
        <div class="alert alert-erro">${erro}</div>
    </c:if>

    <c:if test="${param.cadastro eq 'ok'}">
        <div class="alert alert-sucesso">
            ✓ Conta criada com sucesso! Faça login para continuar.
        </div>
    </c:if>

    <h2>Acesse sua conta</h2>

    <!-- Form -->
    <form method="post" action="${pageContext.request.contextPath}/login"
          autocomplete="off" id="loginForm">

        <div class="form-group">
            <label for="login">Login</label>
            <input type="text" id="login" name="login"
                   value="${loginDigitado}"
                   class="form-control"
                   placeholder="Seu usuário"
                   required autofocus>
        </div>

        <div class="form-group">
            <label for="senha">Senha</label>
            <div style="position:relative;">
                <input type="password" id="senha" name="senha"
                       class="form-control"
                       placeholder="••••••••"
                       required
                       style="padding-right:42px;">
                <button type="button" id="toggleSenha"
                        style="position:absolute;right:12px;top:50%;transform:translateY(-50%);
                               background:none;border:none;cursor:pointer;color:var(--text-muted);
                               font-size:.9rem;padding:4px;">
                    👁
                </button>
            </div>
        </div>

        <button type="submit" class="btn btn-primary btn-block" style="margin-top:8px;">
            Entrar no Sistema
        </button>
    </form>

    <div class="login-footer">
        Não tem conta?
        <a href="${pageContext.request.contextPath}/cadastroUsuario">Criar agora</a>
    </div>

    <!-- Version label -->
    <div style="text-align:center;margin-top:28px;font-size:.68rem;color:var(--text-dim);letter-spacing:.5px;">
        FiscalMove FMS &nbsp;·&nbsp; v1.0
    </div>
</div>

<!-- Loader -->
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
/* Toggle senha */
document.getElementById('toggleSenha').addEventListener('click', function () {
    var inp = document.getElementById('senha');
    inp.type = inp.type === 'password' ? 'text' : 'password';
    this.textContent = inp.type === 'password' ? '👁' : '🙈';
});

/* Loader no submit */
document.getElementById('loginForm').addEventListener('submit', function () {
    var loader = document.getElementById('fm-loader');
    if (loader) loader.classList.add('active');
});

window.addEventListener('pageshow', function () {
    var loader = document.getElementById('fm-loader');
    if (loader) loader.classList.remove('active');
});

/* Ripple */
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
