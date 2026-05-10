<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${empty cliente.id || cliente.id == 0 ? 'Novo Cliente' : 'Editar Cliente'} - FiscalMove FMS</title>
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
            ${empty cliente.id || cliente.id == 0 ? 'Novo cliente' : 'Editar cliente'}
        </div>
        <div class="topbar-actions">
            <a href="${pageContext.request.contextPath}/clientes" class="btn btn-secondary btn-sm">Voltar</a>
        </div>
    </div>

    <main class="container form-page">

        <header class="page-intro">
            <a href="${pageContext.request.contextPath}/clientes" class="back-chip" aria-label="Voltar">
                <svg viewBox="0 0 24 24"><path d="m11 5 1.4 1.4L8.8 10H20v2H8.8l3.6 3.6L11 17l-6-6 6-6Z"/></svg>
            </a>
            <div>
                <h1>${empty cliente.id || cliente.id == 0 ? 'Novo cliente' : 'Editar cliente'}</h1>
                <p>Preencha os dados para cadastrar ou atualizar um cliente.</p>
            </div>
        </header>

        <c:if test="${not empty erro}">
            <div class="alert alert-erro">${erro}</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/clientes"
              class="app-form" enctype="multipart/form-data">
            <input type="hidden" name="id" value="${cliente.id}">

            <section class="card form-section">
                <div class="section-title">
                    <span>01</span>
                    <h2>Dados principais</h2>
                    <i></i>
                </div>

                <div class="form-section-grid with-logo">
                    <div class="form-fields">
                        <div class="form-row cols-2">
                            <div class="form-group">
                                <label for="razaoSocial">Razão social *</label>
                                <input type="text" id="razaoSocial" name="razaoSocial"
                                       value="${cliente.razaoSocial}" class="form-control"
                                       required maxlength="100" data-allow="text"
                                       placeholder="Nome da empresa">
                            </div>
                            <div class="form-group">
                                <label for="nomeFantasia">Nome fantasia</label>
                                <input type="text" id="nomeFantasia" name="nomeFantasia"
                                       value="${cliente.nomeFantasia}" class="form-control" maxlength="100"
                                       data-allow="text" placeholder="Nome fantasia (opcional)">
                            </div>
                        </div>

                        <div class="form-row cols-2">
                            <div class="form-group">
                                <label for="cnpj">CPF/CNPJ *</label>
                                <input type="text" id="cnpj" name="cnpj"
                                       value="${cliente.documentoFiscalFormatado}" class="form-control"
                                       maxlength="18" placeholder="00.000.000/0000-00"
                                       data-mask="cpf-cnpj" data-validate="cpf-cnpj" required>
                            </div>
                            <div class="form-group">
                                <label for="inscricaoEst">Inscrição estadual</label>
                                <input type="text" id="inscricaoEst" name="inscricaoEst"
                                       value="${cliente.inscricaoEst}" class="form-control" maxlength="20"
                                       data-allow="alphanum" placeholder="Inscrição estadual (opcional)">
                            </div>
                        </div>
                    </div>

                    <div class="logo-drop">
                        <label for="logoArquivo">Logo</label>
                        <div class="logo-upload" data-logo-drop>
                            <input type="file" id="logoArquivo" name="logoArquivo"
                                   accept="image/png,image/jpeg,image/webp,image/gif">
                            <div class="logo-preview" data-logo-preview>
                                <c:choose>
                                    <c:when test="${not empty cliente && cliente.logoDisponivel && cliente.id > 0}">
                                        <img src="${pageContext.request.contextPath}/clientes?acao=logo&id=${cliente.id}"
                                             alt="Logo de ${cliente.razaoSocial}">
                                    </c:when>
                                    <c:otherwise>
                                        <svg viewBox="0 0 24 24"><path d="M5 20h14a2 2 0 0 0 2-2v-5h-2v5H5v-5H3v5a2 2 0 0 0 2 2Zm7-16 5 5-1.4 1.4L13 7.8V16h-2V7.8l-2.6 2.6L7 9l5-5Z"/></svg>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <strong data-logo-title>
                                <c:choose>
                                    <c:when test="${not empty cliente && cliente.logoDisponivel}">Trocar logo</c:when>
                                    <c:otherwise>Enviar logo</c:otherwise>
                                </c:choose>
                            </strong>
                            <small data-logo-help>PNG, JPG, WEBP ou GIF até 2 MB</small>
                        </div>
                        <c:if test="${not empty cliente && cliente.logoDisponivel && cliente.id > 0}">
                            <label class="logo-remove">
                                <input type="checkbox" name="removerLogo" value="on">
                                <span>Remover logo atual</span>
                            </label>
                        </c:if>
                    </div>
                </div>
            </section>

            <section class="card form-section">
                <div class="section-title">
                    <span>02</span>
                    <h2>Endereço</h2>
                    <i></i>
                </div>

                <div class="form-row cols-address">
                    <div class="form-group span-2">
                        <label for="logradouro">Logradouro *</label>
                        <input type="text" id="logradouro" name="logradouro"
                               value="${cliente.logradouro}" class="form-control"
                               maxlength="80" required data-allow="text"
                               placeholder="Rua, avenida, etc.">
                    </div>
                    <div class="form-group">
                        <label for="numeroEnd">Número *</label>
                        <input type="text" id="numeroEnd" name="numeroEnd"
                               value="${cliente.numeroEnd}" class="form-control"
                               maxlength="10" required data-allow="alphanum" placeholder="Nº">
                    </div>
                </div>

                <div class="form-row cols-3">
                    <div class="form-group">
                        <label for="complemento">Complemento</label>
                        <input type="text" id="complemento" name="complemento"
                               value="${cliente.complemento}" class="form-control" maxlength="120"
                               data-allow="text" placeholder="Complemento (opcional)">
                    </div>
                    <div class="form-group">
                        <label for="bairro">Bairro *</label>
                        <input type="text" id="bairro" name="bairro"
                               value="${cliente.bairro}" class="form-control"
                               maxlength="60" required data-allow="text" placeholder="Bairro">
                    </div>
                    <div class="form-group">
                        <label for="cep">CEP *</label>
                        <input type="text" id="cep" name="cep"
                               value="${cliente.cep}" class="form-control"
                               maxlength="9" placeholder="00000-000"
                               data-mask="cep" data-validate="cep" data-viacep="cliente" required>
                    </div>
                </div>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="municipio">Município *</label>
                        <input type="text" id="municipio" name="municipio"
                               value="${cliente.municipio}" class="form-control"
                               maxlength="80" required data-allow="city" placeholder="Selecione o município">
                    </div>
                    <div class="form-group">
                        <label for="uf">UF *</label>
                        <input type="text" id="uf" name="uf"
                               value="${cliente.uf}" class="form-control"
                               maxlength="2" placeholder="UF"
                               style="text-transform:uppercase" required
                               data-mask="uf" data-validate="uf">
                    </div>
                </div>
            </section>

            <section class="card form-section">
                <div class="section-title">
                    <span>03</span>
                    <h2>Contato</h2>
                    <i></i>
                </div>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="telefone">Telefone *</label>
                        <input type="text" id="telefone" name="telefone"
                               value="${cliente.telefone}" class="form-control"
                               maxlength="15" placeholder="(00) 00000-0000"
                               data-mask="telefone" data-validate="telefone" required>
                    </div>
                    <div class="form-group">
                        <label for="email">E-mail</label>
                        <input type="email" id="email" name="email"
                               value="${cliente.email}" class="form-control" maxlength="100"
                               data-validate="email" placeholder="email@exemplo.com">
                    </div>
                </div>

                <div class="form-section-footer">
                    <label class="switch-line">
                        <input type="checkbox" name="ativo" value="on"
                            <c:if test="${empty cliente || cliente.ativo}">checked</c:if>>
                        <span></span>
                        <strong>Cliente ativo</strong>
                        <small>Clientes inativos não aparecerão nas operações.</small>
                    </label>
                </div>
            </section>

            <div class="form-footer-bar">
                <a href="${pageContext.request.contextPath}/clientes" class="btn btn-secondary">Cancelar</a>
                <button type="submit" class="btn btn-primary">Salvar cliente</button>
            </div>
        </form>
    </main>
</div>
<script>
(function () {
    var input = document.getElementById('logoArquivo');
    var preview = document.querySelector('[data-logo-preview]');
    var title = document.querySelector('[data-logo-title]');
    var help = document.querySelector('[data-logo-help]');
    if (!input || !preview) return;

    input.addEventListener('change', function () {
        var file = input.files && input.files[0];
        if (!file) return;

        if (title) title.textContent = file.name;
        if (help) help.textContent = 'Pronto para salvar';

        var reader = new FileReader();
        reader.onload = function (event) {
            preview.innerHTML = '<img src="' + event.target.result + '" alt="">';
        };
        reader.readAsDataURL(file);
    });
})();
</script>
</body>
</html>
