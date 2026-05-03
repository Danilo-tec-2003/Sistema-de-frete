<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${empty motorista.id || motorista.id == 0 ? 'Novo Motorista' : 'Editar Motorista'} – FiscalMove FMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Exo+2:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/imask@7.6.1/dist/imask.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/masks.js" defer></script>
</head>
<body>
<%@ include file="/jsp/NavBar.jsp" %>
<div class="main-wrapper">

    <div class="topbar">
        <div class="topbar-title">
            ${empty motorista.id || motorista.id == 0 ? 'Novo Motorista' : 'Editar Motorista'}
        </div>
        <div class="topbar-actions">
            <a href="${pageContext.request.contextPath}/motoristas" class="btn btn-secondary btn-sm">&larr; Voltar</a>
        </div>
    </div>

    <div class="container">

        <c:if test="${not empty erro}">
            <div class="alert alert-erro">${erro}</div>
        </c:if>

        <div class="card">
            <form method="post" action="${pageContext.request.contextPath}/motoristas">
                <input type="hidden" name="id" value="${motorista.id}">

                <h3 style="margin-bottom:16px;font-family:'Rajdhani',sans-serif;font-size:1rem;
                           font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:.5px;">
                    Dados Pessoais
                </h3>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="nome">Nome Completo *</label>
                        <input type="text" id="nome" name="nome"
                               value="${motorista.nome}" class="form-control"
                               required maxlength="100" data-allow="person-name">
                    </div>
                    <div class="form-group">
                        <label for="cpf">CPF *</label>
                        <input type="text" id="cpf" name="cpf"
                               value="${motorista.cpf}" class="form-control"
                               required maxlength="14" placeholder="000.000.000-00"
                               data-mask="cpf" data-validate="cpf">
                    </div>
                </div>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="dataNascimento">Data de Nascimento *</label>
                        <input type="date" id="dataNascimento" name="dataNascimento"
                               value="${motorista.dataNascimento}" class="form-control"
                               required max="${maxDataNascimento}">
                    </div>
                    <div class="form-group">
                        <label for="telefone">Telefone *</label>
                        <input type="text" id="telefone" name="telefone"
                               value="${motorista.telefone}" class="form-control"
                               maxlength="15" placeholder="(81) 99999-0000"
                               required data-mask="telefone" data-validate="telefone">
                    </div>
                </div>

                <hr class="divider">
                <h3 style="margin-bottom:16px;font-family:'Rajdhani',sans-serif;font-size:1rem;
                           font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:.5px;">
                    CNH
                </h3>

                <div class="form-row cols-3">
                    <div class="form-group">
                        <label for="cnhNumero">Número da CNH *</label>
                        <input type="text" id="cnhNumero" name="cnhNumero"
                               value="${motorista.cnhNumero}" class="form-control"
                               required maxlength="11" inputmode="numeric"
                               placeholder="00000000000"
                               data-mask="cnh" data-validate="cnh">
                        <small class="campo-hint">Informe somente os 11 dígitos da CNH.</small>
                    </div>
                    <div class="form-group">
                        <label for="cnhCategoria">Categoria *</label>
                        <select id="cnhCategoria" name="cnhCategoria" class="form-control" required>
                            <option value="">Selecione...</option>
                            <c:forEach var="cat" items="${categorias}">
                                <option value="${cat.codigo}"
                                    <c:if test="${motorista.cnhCategoria == cat}">selected</c:if>>
                                    ${cat.descricao}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="cnhValidade">Validade *</label>
                        <input type="date" id="cnhValidade" name="cnhValidade"
                               value="${motorista.cnhValidade}" class="form-control"
                               min="${minCnhValidade}" required>
                        <small class="campo-hint">Motorista ativo com CNH vencida não pode ser usado em fretes.</small>
                    </div>
                </div>

                <hr class="divider">
                <h3 style="margin-bottom:16px;font-family:'Rajdhani',sans-serif;font-size:1rem;
                           font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:.5px;">
                    Vínculo e Status
                </h3>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="tipoVinculo">Tipo de Vínculo *</label>
                        <select id="tipoVinculo" name="tipoVinculo" class="form-control" required>
                            <option value="">Selecione...</option>
                            <c:forEach var="v" items="${vinculos}">
                                <option value="${v.codigo}"
                                    <c:if test="${motorista.tipoVinculo == v}">selected</c:if>>
                                    ${v.descricao}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="status">Status *</label>
                        <select id="status" name="status" class="form-control" required>
                            <option value="">Selecione...</option>
                            <c:forEach var="s" items="${statusList}">
                                <option value="${s.codigo}"
                                    <c:if test="${motorista.status == s}">selected</c:if>>
                                    ${s.descricao}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div style="display:flex;gap:10px;margin-top:24px;">
                    <button type="submit" class="btn btn-primary">Salvar</button>
                    <a href="${pageContext.request.contextPath}/motoristas" class="btn btn-secondary">Cancelar</a>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>
