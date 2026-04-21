<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Erro – Sistema de Fretes GW</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/jsp/NavBar.jsp" %>

<div class="container">
    <div class="card mt-4 text-center">
        <h2 class="text-danger">Ocorreu um erro inesperado</h2>
        <p>Algo deu errado no servidor. Por favor, tente novamente ou contate o suporte.</p>
        <c:if test="${not empty param.msg}">
            <p class="text-muted">${param.msg}</p>
        </c:if>
        <a href="${pageContext.request.contextPath}/home" class="btn btn-primary">
            Voltar ao início
        </a>
    </div>
</div>
</body>
</html>