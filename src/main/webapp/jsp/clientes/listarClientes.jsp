<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Clientes - FiscalMove FMS</title>
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
                Novo cliente
            </a>
        </div>
    </div>

    <main class="container entity-page">

        <c:set var="clientesAtivos" value="0"/>
        <c:set var="clientesInativos" value="0"/>
        <c:forEach var="clienteResumo" items="${clientes}">
            <c:choose>
                <c:when test="${clienteResumo.ativo}">
                    <c:set var="clientesAtivos" value="${clientesAtivos + 1}"/>
                </c:when>
                <c:otherwise>
                    <c:set var="clientesInativos" value="${clientesInativos + 1}"/>
                </c:otherwise>
            </c:choose>
        </c:forEach>

        <header class="entity-header">
            <div>
                <h1>Clientes</h1>
                <p>Gerencie sua base de clientes e mantenha os dados sempre atualizados.</p>
            </div>
            <a href="${pageContext.request.contextPath}/clientes?acao=novo" class="btn btn-primary">
                Novo cliente
            </a>
        </header>

        <c:if test="${not empty erro}">
            <div class="alert alert-erro">${erro}</div>
        </c:if>
        <c:if test="${not empty sucesso}">
            <div class="alert alert-sucesso">${sucesso}</div>
        </c:if>

        <section class="metric-strip">
            <article class="metric-card">
                <span>Total na página</span>
                <strong>${empty clientes ? 0 : fn:length(clientes)}</strong>
                <small>Registros filtrados</small>
            </article>
            <article class="metric-card">
                <span>Ativos</span>
                <strong>${clientesAtivos}</strong>
                <small>Disponíveis nas operações</small>
            </article>
            <article class="metric-card">
                <span>Pendentes</span>
                <strong>0</strong>
                <small>Sem pendências fiscais</small>
            </article>
            <article class="metric-card">
                <span>Inativos</span>
                <strong>${clientesInativos}</strong>
                <small>Fora das operações</small>
            </article>
        </section>

        <form method="get" action="${pageContext.request.contextPath}/clientes" class="list-toolbar">
            <div class="toolbar-search">
                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M10.5 4a6.5 6.5 0 0 1 5.2 10.4l4 4-1.4 1.4-4-4A6.5 6.5 0 1 1 10.5 4Zm0 2a4.5 4.5 0 1 0 0 9 4.5 4.5 0 0 0 0-9Z"/></svg>
                <input type="text" id="filtro" name="filtro"
                       value="${filtro}" class="form-control"
                       placeholder="Buscar por razão social, CNPJ ou cidade...">
                <kbd>⌘ K</kbd>
            </div>
            <button type="submit" class="btn btn-secondary btn-sm">Filtros avançados</button>
            <a href="${pageContext.request.contextPath}/clientes" class="btn btn-secondary btn-sm">Limpar</a>
            <a href="${pageContext.request.contextPath}/clientes" class="btn btn-secondary btn-sm">Visão padrão</a>
        </form>

        <section class="entity-grid">
            <div class="card entity-table-card">
                <div class="table-wrapper">
                    <table class="entity-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Cliente</th>
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
                                                <div class="entity-name">
                                                    <span>${empty c.razaoSocial ? 'CL' : fn:substring(c.razaoSocial,0,1)}</span>
                                                    <div>
                                                        <strong>${c.razaoSocial}</strong>
                                                        <c:if test="${not empty c.nomeFantasia}">
                                                            <small>${c.nomeFantasia}</small>
                                                        </c:if>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${empty c.documentoFiscal}">--</c:when>
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
                                            <td>${empty c.telefone ? '--' : c.telefone}</td>
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
                                            <td class="row-actions">
                                                <a href="${pageContext.request.contextPath}/clientes?acao=editar&id=${c.id}"
                                                   class="icon-link" aria-label="Editar cliente">
                                                    <svg viewBox="0 0 24 24"><path d="M4 17.3V21h3.7L18.8 9.9l-3.7-3.7L4 17.3Zm16.4-10.8a1 1 0 0 0 0-1.4l-1.5-1.5a1 1 0 0 0-1.4 0l-1.2 1.2 3.7 3.7 1.4-1.4Z"/></svg>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/clientes?acao=excluir&id=${c.id}"
                                                   class="icon-link danger"
                                                   data-confirm="Excluir cliente ${c.razaoSocial}?"
                                                   aria-label="Excluir cliente">
                                                    <svg viewBox="0 0 24 24"><path d="M6 7h12l-1 14H7L6 7Zm3-4h6l1 2h4v2H4V5h4l1-2Zm1 6v10h2V9h-2Zm4 0v10h2V9h-2Z"/></svg>
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <div class="table-footer">
                    <span>Mostrando ${empty clientes ? 0 : fn:length(clientes)} clientes</span>
                    <c:if test="${totalPaginas > 1}">
                        <div class="paginacao compact">
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

            <c:forEach var="clienteDestaque" items="${clientes}" begin="0" end="0">
                <aside class="card entity-detail">
                    <div class="detail-person">
                        <span>${empty clienteDestaque.razaoSocial ? 'CL' : fn:substring(clienteDestaque.razaoSocial,0,1)}</span>
                        <div>
                            <h2>${clienteDestaque.razaoSocial}</h2>
                            <c:choose>
                                <c:when test="${clienteDestaque.ativo}"><small class="badge badge-ativo">Ativo</small></c:when>
                                <c:otherwise><small class="badge badge-inativo">Inativo</small></c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="detail-actions">
                        <a href="${pageContext.request.contextPath}/clientes?acao=editar&id=${clienteDestaque.id}">Editar</a>
                        <a href="${pageContext.request.contextPath}/clientes?acao=excluir&id=${clienteDestaque.id}"
                           data-confirm="Excluir cliente ${clienteDestaque.razaoSocial}?">Inativar</a>
                        <a href="${pageContext.request.contextPath}/fretes?filtro=${clienteDestaque.razaoSocial}">Mais ações</a>
                    </div>

                    <dl class="detail-grid">
                        <div><dt>Documento</dt><dd>${clienteDestaque.tipoDocumentoFiscal} ${clienteDestaque.documentoFiscalFormatado}</dd></div>
                        <div><dt>Inscrição estadual</dt><dd>${empty clienteDestaque.inscricaoEst ? '--' : clienteDestaque.inscricaoEst}</dd></div>
                        <div><dt>Telefone</dt><dd>${empty clienteDestaque.telefone ? '--' : clienteDestaque.telefone}</dd></div>
                        <div><dt>E-mail</dt><dd>${empty clienteDestaque.email ? '--' : clienteDestaque.email}</dd></div>
                        <div><dt>Município/UF</dt><dd>${clienteDestaque.municipio}/${clienteDestaque.uf}</dd></div>
                    </dl>

                    <div class="activity-card compact-card">
                        <div class="card-heading">
                            <h2>Atividades recentes</h2>
                            <a href="${pageContext.request.contextPath}/fretes?filtro=${clienteDestaque.razaoSocial}">Ver todas</a>
                        </div>
                        <div class="activity-list">
                            <span class="activity-item">
                                <i class="activity-icon blue"></i>
                                <span><strong>Cadastro criado</strong><small>Usuário: Administrador</small></span>
                                <time>Hoje</time>
                            </span>
                            <span class="activity-item">
                                <i class="activity-icon green"></i>
                                <span><strong>Status alterado para ativo</strong><small>Cliente disponível</small></span>
                                <time>Agora</time>
                            </span>
                        </div>
                    </div>
                </aside>
            </c:forEach>
        </section>
    </main>
</div>
</body>
</html>
