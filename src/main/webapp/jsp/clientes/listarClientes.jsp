<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Clientes – FiscalMove FMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Exo+2:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/jsp/NavBar.jsp" %>
<div class="main-wrapper">

    <div class="topbar">
        <div class="topbar-title">Clientes</div>
        <div class="topbar-actions">
            <a href="${pageContext.request.contextPath}/clientes?acao=novo" class="btn btn-primary btn-sm">
                + Novo Cliente
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

        <form method="get" action="${pageContext.request.contextPath}/clientes" class="filtro-bar">
            <div class="form-group">
                <label for="filtro">Buscar por Razão Social</label>
                <input type="text" id="filtro" name="filtro"
                       value="${filtro}" class="form-control" placeholder="Digite para filtrar...">
            </div>
            <button type="submit" class="btn btn-secondary">Filtrar</button>
            <a href="${pageContext.request.contextPath}/clientes" class="btn btn-secondary">Limpar</a>
        </form>

        <div class="card">
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Razão Social</th>
                            <th>CPF/CNPJ</th>
                            <th>Município/UF</th>
                            <th>Telefone</th>
                            <th>Status</th>
                            <th>Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty clientes}">
                                <tr><td colspan="7" class="text-center text-muted">
                                    Nenhum cliente encontrado.
                                </td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="c" items="${clientes}">
                                    <tr>
                                        <td>${c.id}</td>
                                        <td>
                                            <strong>${c.razaoSocial}</strong>
                                            <c:if test="${not empty c.nomeFantasia}">
                                                <br><small class="text-muted">${c.nomeFantasia}</small>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${empty c.documentoFiscal}">—</c:when>
                                                <c:otherwise>
                                                    <small class="text-muted">${c.tipoDocumentoFiscal}</small><br>
                                                    ${c.documentoFiscalFormatado}
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:if test="${not empty c.municipio}">
                                                ${c.municipio}/${c.uf}
                                            </c:if>
                                        </td>
                                        <td>${empty c.telefone ? '—' : c.telefone}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${c.ativo}">
                                                    <span class="badge badge-ativo">Ativo</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-inativo">Inativo</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/clientes?acao=editar&id=${c.id}"
                                               class="btn btn-secondary btn-sm">Editar</a>
                                            <a href="${pageContext.request.contextPath}/clientes?acao=excluir&id=${c.id}"
                                               class="btn btn-danger btn-sm"
                                               onclick="return confirm('Excluir cliente ${c.razaoSocial}?')">Excluir</a>
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
