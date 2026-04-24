<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${empty cliente.id || cliente.id == 0 ? 'Novo Cliente' : 'Editar Cliente'} – FiscalMove FMS</title>
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
            ${empty cliente.id || cliente.id == 0 ? 'Novo Cliente' : 'Editar Cliente'}
        </div>
        <div class="topbar-actions">
            <a href="${pageContext.request.contextPath}/clientes" class="btn btn-secondary btn-sm">&larr; Voltar</a>
        </div>
    </div>

    <div class="container">

        <c:if test="${not empty erro}">
            <div class="alert alert-erro">${erro}</div>
        </c:if>

        <div class="card">
            <form method="post" action="${pageContext.request.contextPath}/clientes">
                <input type="hidden" name="id" value="${cliente.id}">

                <h3 style="margin-bottom:16px;font-family:'Rajdhani',sans-serif;font-size:1rem;
                           font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:.5px;">
                    Dados Principais
                </h3>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="razaoSocial">Razão Social *</label>
                        <input type="text" id="razaoSocial" name="razaoSocial"
                               value="${cliente.razaoSocial}" class="form-control"
                               required maxlength="100">
                    </div>
                    <div class="form-group">
                        <label for="nomeFantasia">Nome Fantasia</label>
                        <input type="text" id="nomeFantasia" name="nomeFantasia"
                               value="${cliente.nomeFantasia}" class="form-control" maxlength="100">
                    </div>
                </div>

                <div class="form-row cols-3">
                    <div class="form-group">
                        <label for="cnpj">CNPJ *</label>
                        <input type="text" id="cnpj" name="cnpj"
                               value="${cliente.cnpj}" class="form-control"
                               maxlength="18" placeholder="00.000.000/0000-00"
                               data-mask="cnpj" required>
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

                <hr class="divider">
                <h3 style="margin-bottom:16px;font-family:'Rajdhani',sans-serif;font-size:1rem;
                           font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:.5px;">
                    Endereço
                </h3>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="logradouro">Logradouro *</label>
                        <input type="text" id="logradouro" name="logradouro"
                               value="${cliente.logradouro}" class="form-control"
                               maxlength="80" required>
                    </div>
                    <div class="form-group">
                        <label for="numeroEnd">Número *</label>
                        <input type="text" id="numeroEnd" name="numeroEnd"
                               value="${cliente.numeroEnd}" class="form-control"
                               maxlength="10" required>
                    </div>
                </div>

                <div class="form-row cols-3">
                    <div class="form-group">
                        <label for="complemento">Complemento</label>
                        <input type="text" id="complemento" name="complemento"
                               value="${cliente.complemento}" class="form-control" maxlength="120">
                    </div>
                    <div class="form-group">
                        <label for="bairro">Bairro *</label>
                        <input type="text" id="bairro" name="bairro"
                               value="${cliente.bairro}" class="form-control"
                               maxlength="60" required>
                    </div>
                    <div class="form-group">
                        <label for="cep">CEP *</label>
                        <input type="text" id="cep" name="cep"
                               value="${cliente.cep}" class="form-control"
                               maxlength="9" placeholder="00000-000"
                               data-mask="cep" required>
                    </div>
                </div>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="municipio">Município *</label>
                        <input type="text" id="municipio" name="municipio"
                               value="${cliente.municipio}" class="form-control"
                               maxlength="80" required>
                    </div>
                    <div class="form-group">
                        <label for="uf">UF *</label>
                        <input type="text" id="uf" name="uf"
                               value="${cliente.uf}" class="form-control"
                               maxlength="2" placeholder="PE"
                               style="text-transform:uppercase" required>
                    </div>
                </div>

                <hr class="divider">
                <h3 style="margin-bottom:16px;font-family:'Rajdhani',sans-serif;font-size:1rem;
                           font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:.5px;">
                    Contato
                </h3>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="telefone">Telefone *</label>
                        <input type="text" id="telefone" name="telefone"
                               value="${cliente.telefone}" class="form-control"
                               maxlength="15" placeholder="(81) 99999-0000"
                               data-mask="telefone" required>
                    </div>
                    <div class="form-group">
                        <label for="email">E-mail</label>
                        <input type="email" id="email" name="email"
                               value="${cliente.email}" class="form-control" maxlength="100">
                    </div>
                </div>

                <div class="form-group" style="margin-top:8px;">
                    <label style="display:flex;align-items:center;gap:8px;cursor:pointer;
                                  font-size:.85rem;color:var(--text-muted);text-transform:none;letter-spacing:0;">
                        <input type="checkbox" name="ativo" value="on"
                            <c:if test="${empty cliente || cliente.ativo}">checked</c:if>>
                        Cliente ativo
                    </label>
                </div>

                <div style="display:flex;gap:10px;margin-top:24px;">
                    <button type="submit" class="btn btn-primary">Salvar</button>
                    <a href="${pageContext.request.contextPath}/clientes" class="btn btn-secondary">Cancelar</a>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>