<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>${empty cliente.id || cliente.id == 0 ? 'Novo Cliente' : 'Editar Cliente'} – GW Fretes</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/jsp/NavBar.jsp" %>
<div class="container">

    <div class="page-header">
        <h1>${empty cliente.id || cliente.id == 0 ? 'Novo Cliente' : 'Editar Cliente'}</h1>
        <a href="${pageContext.request.contextPath}/clientes" class="btn btn-secondary">
            &larr; Voltar
        </a>
    </div>

    <c:if test="${not empty erro}">
        <div class="alert alert-erro">${erro}</div>
    </c:if>

    <div class="card">
        <form method="post" action="${pageContext.request.contextPath}/clientes">
            <input type="hidden" name="id" value="${cliente.id}">

            <h3 style="margin-bottom:16px;font-size:15px;color:#555;">Dados Principais</h3>

            <div class="form-row cols-2">
                <div class="form-group">
                    <label for="razaoSocial">Razão Social *</label>
                    <input type="text" id="razaoSocial" name="razaoSocial"
                           value="${cliente.razaoSocial}" class="form-control" required maxlength="100">
                </div>
                <div class="form-group">
                    <label for="nomeFantasia">Nome Fantasia</label>
                    <input type="text" id="nomeFantasia" name="nomeFantasia"
                           value="${cliente.nomeFantasia}" class="form-control" maxlength="100">
                </div>
            </div>

            <div class="form-row cols-3">
                <div class="form-group">
                    <label for="cnpj">CNPJ</label>
                    <input type="text" id="cnpj" name="cnpj"
                           value="${cliente.cnpj}" class="form-control"
                           maxlength="18" placeholder="00.000.000/0000-00">
                </div>
                <div class="form-group">
                    <label for="inscricaoEst">Inscrição Estadual</label>
                    <input type="text" id="inscricaoEst" name="inscricaoEst"
                           value="${cliente.inscricaoEst}" class="form-control" maxlength="20">
                </div>
                <div class="form-group">
                    <label for="tipo">Tipo *</label>
                    <select id="tipo" name="tipo" class="form-control" required>
                        <option value="">Selecione...</option>
                        <c:forEach var="t" items="${tipos}">
                            <option value="${t.codigo}"
                                <c:if test="${cliente.tipo == t}">selected</c:if>>
                                ${t.descricao}
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <h3 style="margin:20px 0 16px;font-size:15px;color:#555;">Endereço</h3>

            <div class="form-row cols-2">
                <div class="form-group">
                    <label for="logradouro">Logradouro</label>
                    <input type="text" id="logradouro" name="logradouro"
                           value="${cliente.logradouro}" class="form-control" maxlength="80">
                </div>
                <div class="form-group">
                    <label for="numeroEnd">Número</label>
                    <input type="text" id="numeroEnd" name="numeroEnd"
                           value="${cliente.numeroEnd}" class="form-control" maxlength="10">
                </div>
            </div>

            <div class="form-row cols-3">
                <div class="form-group">
                    <label for="complemento">Complemento</label>
                    <input type="text" id="complemento" name="complemento"
                           value="${cliente.complemento}" class="form-control" maxlength="120">
                </div>
                <div class="form-group">
                    <label for="bairro">Bairro</label>
                    <input type="text" id="bairro" name="bairro"
                           value="${cliente.bairro}" class="form-control" maxlength="60">
                </div>
                <div class="form-group">
                    <label for="cep">CEP</label>
                    <input type="text" id="cep" name="cep"
                           value="${cliente.cep}" class="form-control"
                           maxlength="9" placeholder="00000-000">
                </div>
            </div>

            <div class="form-row cols-2">
                <div class="form-group">
                    <label for="municipio">Município</label>
                    <input type="text" id="municipio" name="municipio"
                           value="${cliente.municipio}" class="form-control" maxlength="80">
                </div>
                <div class="form-group">
                    <label for="uf">UF</label>
                    <input type="text" id="uf" name="uf"
                           value="${cliente.uf}" class="form-control"
                           maxlength="2" placeholder="PE" style="text-transform:uppercase">
                </div>
            </div>

            <h3 style="margin:20px 0 16px;font-size:15px;color:#555;">Contato</h3>

            <div class="form-row cols-2">
                <div class="form-group">
                    <label for="telefone">Telefone</label>
                    <input type="text" id="telefone" name="telefone"
                           value="${cliente.telefone}" class="form-control"
                           maxlength="15" placeholder="(81) 99999-0000">
                </div>
                <div class="form-group">
                    <label for="email">E-mail</label>
                    <input type="email" id="email" name="email"
                           value="${cliente.email}" class="form-control" maxlength="100">
                </div>
            </div>

            <div class="form-group" style="margin-top:8px;">
                <label>
                    <input type="checkbox" name="ativo" value="on"
                        <c:if test="${empty cliente || cliente.ativo}">checked</c:if>>
                    &nbsp;Cliente ativo
                </label>
            </div>

            <div style="display:flex;gap:10px;margin-top:20px;">
                <button type="submit" class="btn btn-primary">Salvar</button>
                <a href="${pageContext.request.contextPath}/clientes" class="btn btn-secondary">Cancelar</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>