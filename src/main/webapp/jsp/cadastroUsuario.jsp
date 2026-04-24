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
</head>
<body class="login-page">

<!-- Orb decorativo -->
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

    <!-- Alerta de erro -->
    <c:if test="${not empty erro}">
        <div class="alert alert-erro">${erro}</div>
    </c:if>

    <h2>Criar nova conta</h2>

    <form method="post" action="${pageContext.request.contextPath}/cadastroUsuario"
          autocomplete="off" id="cadastroForm">

        <div class="form-group" style="margin-bottom:16px;">
            <label for="nome">Nome completo</label>
            <input type="text" id="nome" name="nome"
                   class="form-control"
                   placeholder="Seu nome completo"
                   value="${nome}"
                   required autofocus>
        </div>

        <div class="form-group" style="margin-bottom:16px;">
            <label for="login">Login</label>
            <input type="text" id="login" name="login"
                   class="form-control"
                   placeholder="Mínimo 4 caracteres"
                   minlength="4"
                   value="${login}"
                   required>
        </div>

        <div class="form-group" style="margin-bottom:16px;">
            <label for="senha">Senha</label>
            <div style="position:relative;">
                <input type="password" id="senha" name="senha"
                       class="form-control"
                       placeholder="Mínimo 6 caracteres"
                       minlength="6"
                       required
                       style="padding-right:42px;">
                <button type="button" id="toggleSenha"
                        style="position:absolute;right:12px;top:50%;transform:translateY(-50%);
                               background:none;border:none;cursor:pointer;color:var(--text-muted);
                               font-size:.9rem;padding:4px;">👁</button>
            </div>
        </div>

        <div class="form-group" style="margin-bottom:24px;">
            <label for="confirmaSenha">Confirmar senha</label>
            <div style="position:relative;">
                <input type="password" id="confirmaSenha" name="confirmaSenha"
                       class="form-control"
                       placeholder="Repita a senha"
                       required
                       style="padding-right:42px;">
                <button type="button" id="toggleConfirma"
                        style="position:absolute;right:12px;top:50%;transform:translateY(-50%);
                               background:none;border:none;cursor:pointer;color:var(--text-muted);
                               font-size:.9rem;padding:4px;">👁</button>
            </div>
        </div>

        <button type="submit" class="btn btn-primary btn-block">
            Criar conta
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

<script>
function toggleInput(btnId, inputId) {
    document.getElementById(btnId).addEventListener('click', function () {
        var inp = document.getElementById(inputId);
        inp.type = inp.type === 'password' ? 'text' : 'password';
        this.textContent = inp.type === 'password' ? '👁' : '🙈';
    });
}
toggleInput('toggleSenha',    'senha');
toggleInput('toggleConfirma', 'confirmaSenha');

/* Validação client-side: senhas coincidem */
document.getElementById('cadastroForm').addEventListener('submit', function (e) {
    var s  = document.getElementById('senha').value;
    var cs = document.getElementById('confirmaSenha').value;
    if (s !== cs) {
        e.preventDefault();
        alert('As senhas não coincidem.');
        document.getElementById('confirmaSenha').focus();
    }
});
</script>
</body>
</html>