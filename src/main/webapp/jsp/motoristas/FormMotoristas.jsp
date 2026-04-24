<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>${empty motorista.id || motorista.id == 0 ? 'Novo Motorista' : 'Editar Motorista'} – GW Fretes</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/jsp/NavBar.jsp" %>
<div class="container">

    <div class="page-header">
        <h1>${empty motorista.id || motorista.id == 0 ? 'Novo Motorista' : 'Editar Motorista'}</h1>
        <a href="${pageContext.request.contextPath}/motoristas" class="btn btn-secondary">&larr; Voltar</a>
    </div>

    <c:if test="${not empty erro}">
        <div class="alert alert-erro">${erro}</div>
    </c:if>

    <div class="card">
        <form method="post" action="${pageContext.request.contextPath}/motoristas">
            <input type="hidden" name="id" value="${motorista.id}">

            <h3 style="margin-bottom:16px;font-size:15px;color:#555;">Dados Pessoais</h3>

            <div class="form-row cols-2">
                <div class="form-group">
                    <label for="nome">Nome Completo *</label>
                    <input type="text" id="nome" name="nome"
                           value="${motorista.nome}" class="form-control" required maxlength="100">
                </div>
                <div class="form-group">
                    <label for="cpf">CPF *</label>
                    <input type="text" id="cpf" name="cpf"
                           value="${motorista.cpf}" class="form-control"
                           required maxlength="14" placeholder="000.000.000-00">
                </div>
            </div>

            <div class="form-row cols-2">
                <div class="form-group">
                    <label for="dataNascimento">Data de Nascimento</label>
                    <input type="date" id="dataNascimento" name="dataNascimento"
                           value="${motorista.dataNascimento}" class="form-control">
                </div>
                <div class="form-group">
                    <label for="telefone">Telefone</label>
                    <input type="text" id="telefone" name="telefone"
                           value="${motorista.telefone}" class="form-control"
                           maxlength="15" placeholder="(81) 99999-0000">
                </div>
            </div>

            <h3 style="margin:20px 0 16px;font-size:15px;color:#555;">CNH</h3>

            <div class="form-row cols-3">
                <div class="form-group">
                    <label for="cnhNumero">Número da CNH *</label>
                    <input type="text" id="cnhNumero" name="cnhNumero"
                           value="${motorista.cnhNumero}" class="form-control" required maxlength="20">
                </div>
                <div class="form-group">
                    <label for="cnhCategoria">Categoria *</label>
                    <select id="cnhCategoria" name="cnhCategoria" class="form-control" required>
                        <option value="">Selecione...</option>
                        <c:forEach var="cat" items="${categorias}">
                            <option value="${cat.codigo}"
                                <c:if test="${motorista.cnhCategoria == cat}">selected</c:if>>
                                ${cat.codigo}
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label for="cnhValidade">Validade *</label>
                    <input type="date" id="cnhValidade" name="cnhValidade"
                           value="${motorista.cnhValidade}" class="form-control" required>
                </div>
            </div>

            <h3 style="margin:20px 0 16px;font-size:15px;color:#555;">Vínculo e Status</h3>

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
                        <c:forEach var="s" items="${statusList}">
                            <option value="${s.codigo}"
                                <c:if test="${motorista.status == s}">selected</c:if>
                                <c:if test="${empty motorista && s.codigo.equals('A')}">selected</c:if>>
                                ${s.descricao}
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div style="display:flex;gap:10px;margin-top:20px;">
                <button type="submit" class="btn btn-primary">Salvar</button>
                <a href="${pageContext.request.contextPath}/motoristas" class="btn btn-secondary">Cancelar</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
