<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Motoristas – FiscalMove FMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Exo+2:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/jsp/NavBar.jsp" %>
<div class="main-wrapper">

    <div class="topbar">
        <div class="topbar-title">Motoristas</div>
        <div class="topbar-actions">
            <a href="${pageContext.request.contextPath}/motoristas?acao=novo" class="btn btn-primary btn-sm">
                + Novo Motorista
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

        <form method="get" action="${pageContext.request.contextPath}/motoristas" class="filtro-bar">
            <div class="form-group">
                <label for="filtro">Buscar por Nome</label>
                <input type="text" id="filtro" name="filtro"
                       value="${filtro}" class="form-control" placeholder="Digite para filtrar...">
            </div>
            <button type="submit" class="btn btn-secondary">Filtrar</button>
            <a href="${pageContext.request.contextPath}/motoristas" class="btn btn-secondary">Limpar</a>
        </form>

        <div class="card">
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Nome</th>
                            <th>CPF</th>
                            <th>CNH / Categoria</th>
                            <th>Validade CNH</th>
                            <th>Vínculo</th>
                            <th>Telefone</th>
                            <th>Status</th>
                            <th>Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty motoristas}">
                                <tr><td colspan="9" class="text-center text-muted">
                                    Nenhum motorista encontrado.
                                </td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="m" items="${motoristas}">
                                    <tr>
                                        <td>${m.id}</td>
                                        <td>${m.nome}</td>
                                        <td>${m.cpf}</td>
                                        <td>${m.cnhNumero} / ${m.cnhCategoria}</td>
                                        <td>
                                            ${m.cnhValidade}
                                            <c:if test="${m.cnhVencida}">
                                                <span class="badge badge-inativo" title="CNH vencida!">⚠ Vencida</span>
                                            </c:if>
                                        </td>
                                        <td>${m.tipoVinculo.descricao}</td>
                                        <td>${empty m.telefone ? '—' : m.telefone}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${m.status == 'ATIVO'}">
                                                    <span class="badge badge-ativo">Ativo</span>
                                                </c:when>
                                                <c:when test="${m.status == 'SUSPENSO'}">
                                                    <span class="badge badge-suspenso">Suspenso</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-inativo">Inativo</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/motoristas?acao=editar&id=${m.id}"
                                               class="btn btn-secondary btn-sm">Editar</a>
                                            <a href="${pageContext.request.contextPath}/motoristas?acao=excluir&id=${m.id}"
                                               class="btn btn-danger btn-sm"
                                               onclick="return confirm('Excluir motorista ${m.nome}?')">Excluir</a>
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