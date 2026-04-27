<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Fretes – GW Fretes</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/validacoes.css">
</head>
<body>
<%@ include file="/jsp/NavBar.jsp" %>
<div class="container">

    <div class="page-header">
        <h1>Fretes</h1>
        <a href="${pageContext.request.contextPath}/fretes?acao=novo" class="btn btn-primary">
            + Novo Frete
        </a>
    </div>

    <c:if test="${not empty sessionScope.sucesso}">
        <div class="alert alert-sucesso" role="alert">${sessionScope.sucesso}</div>
        <c:remove var="sucesso" scope="session"/>
    </c:if>
    <c:if test="${not empty erro}">
        <div class="alert alert-erro" role="alert">${erro}</div>
    </c:if>

    <%-- Filtros --%>
    <form method="get" action="${pageContext.request.contextPath}/fretes" class="filtro-bar">
        <div class="form-group">
            <label for="filtro">Buscar (nº, cliente, motorista, placa)</label>
            <input type="text" id="filtro" name="filtro"
                   value="${filtro}" class="form-control" placeholder="FRT-2026-00001">
        </div>
        <div class="form-group">
            <label for="statusFiltro">Status</label>
            <select id="statusFiltro" name="statusFiltro" class="form-control">
                <option value="">Todos</option>
                <c:forEach var="s" items="${statusList}">
                    <option value="${s.codigo}"
                        <c:if test="${statusFiltro == s.codigo}">selected</c:if>>
                        ${s.descricao}
                    </option>
                </c:forEach>
            </select>
        </div>
        <button type="submit" class="btn btn-secondary">Filtrar</button>
        <a href="${pageContext.request.contextPath}/fretes" class="btn btn-secondary">Limpar</a>
    </form>

    <div class="card">
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Número</th>
                        <th>Remetente → Destinatário</th>
                        <th>Rota</th>
                        <th>Motorista / Veículo</th>
                        <th>Emissão</th>
                        <th>Prev. Entrega</th>
                        <th>Valor Total</th>
                        <th>Status</th>
                        <th>Ações</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty fretes}">
                            <tr>
                                <td colspan="9" class="text-center text-muted">
                                    Nenhum frete encontrado.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="f" items="${fretes}">
                                <tr class="${f.diasAtraso > 0 ? 'linha-atraso' : ''}">
                                    <td>
                                        <strong>${f.numero}</strong>
                                        <c:if test="${f.diasAtraso > 0}">
                                            <br><span class="badge badge-erro" title="Dias em atraso">
                                                ⚠ ${f.diasAtraso}d atraso
                                            </span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <small class="text-muted">De:</small>
                                        ${f.remetente.razaoSocial}
                                        <br>
                                        <small class="text-muted">Para:</small>
                                        ${f.destinatario.razaoSocial}
                                    </td>
                                    <td>
                                        <span class="rota-tag">${f.ufOrigem}</span>
                                        →
                                        <span class="rota-tag">${f.ufDestino}</span>
                                        <br>
                                        <small class="text-muted">
                                            ${f.municipioOrigem} / ${f.municipioDestino}
                                        </small>
                                    </td>
                                    <td>
                                        ${f.motorista.nome}
                                        <br>
                                        <small class="text-muted">${f.veiculo.placa}</small>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${f.dataEmissao}"
                                                        pattern="dd/MM/yyyy" type="date"/>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${f.dataPrevEntrega}"
                                                        pattern="dd/MM/yyyy" type="date"/>
                                    </td>
                                    <td class="text-right">
                                        <fmt:formatNumber value="${f.valorTotal}"
                                                          type="currency" currencySymbol="R$"/>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${f.status.codigo == 'E'}">
                                                <span class="badge badge-emitido">Emitido</span>
                                            </c:when>
                                            <c:when test="${f.status.codigo == 'S'}">
                                                <span class="badge badge-saida">Saída Conf.</span>
                                            </c:when>
                                            <c:when test="${f.status.codigo == 'T'}">
                                                <span class="badge badge-transito">Em Trânsito</span>
                                            </c:when>
                                            <c:when test="${f.status.codigo == 'R'}">
                                                <span class="badge badge-entregue">Entregue</span>
                                            </c:when>
                                            <c:when test="${f.status.codigo == 'N'}">
                                                <span class="badge badge-naoentregue">Não Entregue</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-cancelado">Cancelado</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/fretes?acao=detalhe&id=${f.id}"
                                           class="btn btn-secondary btn-sm">Detalhe</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <%-- Paginação --%>
        <c:if test="${totalPaginas > 1}">
            <div class="paginacao">
                <c:if test="${paginaAtual > 1}">
                    <a href="?filtro=${filtro}&statusFiltro=${statusFiltro}&pagina=${paginaAtual - 1}">&laquo;</a>
                </c:if>
                <c:forEach begin="1" end="${totalPaginas}" var="p">
                    <c:choose>
                        <c:when test="${p == paginaAtual}">
                            <span class="ativo">${p}</span>
                        </c:when>
                        <c:otherwise>
                            <a href="?filtro=${filtro}&statusFiltro=${statusFiltro}&pagina=${p}">${p}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
                <c:if test="${paginaAtual < totalPaginas}">
                    <a href="?filtro=${filtro}&statusFiltro=${statusFiltro}&pagina=${paginaAtual + 1}">&raquo;</a>
                </c:if>
            </div>
        </c:if>
    </div>
</div>
<script type="module" src="${pageContext.request.contextPath}/js/validacoes.js"></script>
</body>
</html>