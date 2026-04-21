<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<nav class="navbar">
    <div class="navbar-brand">
        <a href="${pageContext.request.contextPath}/home">GW Fretes</a>
    </div>
    <ul class="navbar-menu">
        <li><a href="${pageContext.request.contextPath}/clientes">Clientes</a></li>
        <li><a href="${pageContext.request.contextPath}/motoristas">Motoristas</a></li>
        <li><a href="${pageContext.request.contextPath}/veiculos">Veículos</a></li>
        <li><a href="${pageContext.request.contextPath}/fretes">Fretes</a></li>
    </ul>
    <div class="navbar-user">
        <span>Olá, <strong>${sessionScope.usuarioLogado.nome}</strong></span>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Sair</a>
    </div>
</nav>