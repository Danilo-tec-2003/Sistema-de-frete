<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Home – Sistema de Fretes GW</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/jsp/NavBar.jsp" %>

<div class="container">
    <div class="page-header">
        <h1>Bem-vindo, ${sessionScope.usuarioLogado.nome}!</h1>
    </div>

    <div class="card-grid">
        <a href="${pageContext.request.contextPath}/clientes" class="card-link">
            <div class="card card-menu">
                <div class="card-icon">👤</div>
                <h3>Clientes</h3>
                <p>Gerenciar remetentes e destinatários</p>
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
        <a href="${pageContext.request.contextPath}/fretes" class="card-link">
            <div class="card card-menu">
                <div class="card-icon">📦</div>
                <h3>Fretes</h3>
                <p>Emissão e acompanhamento</p>
            </div>
        </a>
    </div>
</div>
</body>
</html>