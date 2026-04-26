<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Veículos – FiscalMove FMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Exo+2:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/jsp/NavBar.jsp" %>
<div class="main-wrapper">

    <div class="topbar">
        <div class="topbar-title">Veículos</div>
        <div class="topbar-actions">
            <a href="${pageContext.request.contextPath}/veiculos?acao=novo" class="btn btn-primary btn-sm">
                + Novo Veículo
            </a>
        </div>
    </div>

    <div class="container">

        <c:if test="${not empty erro}">
            <div class="alert alert-erro">${erro}</div>
        </c:if>
        <c:if test="${not empty sucesso}">
            <div class="alert alert-sucesso">${sucesso}</div>
        </c:if>

        <form method="get" action="${pageContext.request.contextPath}/veiculos" class="filtro-bar">
            <div class="form-group">
                <label for="filtro">Buscar por Placa</label>
                <input type="text" id="filtro" name="filtro"
                       value="${filtro}" class="form-control" placeholder="ABC1D23">
            </div>
            <button type="submit" class="btn btn-secondary">Filtrar</button>
            <a href="${pageContext.request.contextPath}/veiculos" class="btn btn-secondary">Limpar</a>
        </form>

        <div class="card">
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Placa</th>
                            <th>RNTRC</th>
                            <th>Tipo</th>
                            <th>Ano</th>
                            <th>Capacidade (kg)</th>
                            <th>Volume (m³)</th>
                            <th>Status</th>
                            <th>Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty veiculos}">
                                <tr><td colspan="9" class="text-center text-muted">
                                    Nenhum veículo encontrado.
                                </td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="v" items="${veiculos}">
                                    <tr>
                                        <td>${v.id}</td>
                                        <td><strong>${v.placa}</strong></td>
                                        <td>${empty v.rntrc ? '—' : v.rntrc}</td>
                                        <td>${v.tipo.descricao}</td>
                                        <td>${empty v.anoFabricacao ? '—' : v.anoFabricacao}</td>
                                        <td>${empty v.capacidadeKg ? '—' : v.capacidadeKg}</td>
                                        <td>${empty v.volumeM3 ? '—' : v.volumeM3}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${v.status == 'DISPONIVEL'}">
                                                    <span class="badge badge-disponivel">Disponível</span>
                                                </c:when>
                                                <c:when test="${v.status == 'EM_VIAGEM'}">
                                                    <span class="badge badge-viagem">Em Viagem</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-manutencao">Manutenção</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/veiculos?acao=editar&id=${v.id}"
                                               class="btn btn-secondary btn-sm">Editar</a>
                                            <a href="${pageContext.request.contextPath}/veiculos?acao=excluir&id=${v.id}"
                                               class="btn btn-danger btn-sm"
                                               onclick="return confirm('Excluir veículo ${v.placa}?')">Excluir</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <c:if test="${totalPaginas > 1}">
                <div class="paginacao">
                    <c:if test="${paginaAtual > 1}">
                        <a href="?filtro=${filtro}&pagina=${paginaAtual - 1}">&laquo;</a>
                    </c:if>
                    <c:forEach begin="1" end="${totalPaginas}" var="p">
                        <c:choose>
                            <c:when test="${p == paginaAtual}"><span class="ativo">${p}</span></c:when>
                            <c:otherwise><a href="?filtro=${filtro}&pagina=${p}">${p}</a></c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <c:if test="${paginaAtual < totalPaginas}">
                        <a href="?filtro=${filtro}&pagina=${paginaAtual + 1}">&raquo;</a>
                    </c:if>
                </div>
            </c:if>
        </div>
    </div>
</div>
</body>
</html>