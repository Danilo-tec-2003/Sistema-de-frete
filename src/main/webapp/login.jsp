<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Login – Sistema de Fretes GW</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="login-page">

<div class="login-box">
    <div class="login-logo">
        <span class="logo-text">GW</span>
        <p>Sistema de Gestão de Fretes</p>
    </div>

    <c:if test="${not empty erro}">
        <div class="alert alert-erro">${erro}</div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/login" autocomplete="off">
        <div class="form-group">
            <label for="login">Login</label>
            <input type="text" id="login" name="login"
                   value="${loginDigitado}" required autofocus
                   class="form-control" placeholder="seu.login">
        </div>
        <div class="form-group">
            <label for="senha">Senha</label>
            <input type="password" id="senha" name="senha"
                   required class="form-control" placeholder="••••••••">
        </div>
        <button type="submit" class="btn btn-primary btn-block">Entrar</button>
    </form>
</div>

</body>
</html>