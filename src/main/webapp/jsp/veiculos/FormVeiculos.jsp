<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${empty veiculo.id || veiculo.id == 0 ? 'Novo Veículo' : 'Editar Veículo'} – FiscalMove FMS</title>
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
            ${empty veiculo.id || veiculo.id == 0 ? 'Novo Veículo' : 'Editar Veículo'}
        </div>
        <div class="topbar-actions">
            <a href="${pageContext.request.contextPath}/veiculos" class="btn btn-secondary btn-sm">&larr; Voltar</a>
        </div>
    </div>

    <div class="container">

        <c:if test="${not empty erro}">
            <div class="alert alert-erro">${erro}</div>
        </c:if>

        <div class="card">
            <form method="post" action="${pageContext.request.contextPath}/veiculos">
                <input type="hidden" name="id" value="${veiculo.id}">

                <h3 style="margin-bottom:16px;font-family:'Rajdhani',sans-serif;font-size:1rem;
                           font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:.5px;">
                    Identificação
                </h3>

                <div class="form-row cols-3">
                    <div class="form-group">
                        <label for="placa">Placa *</label>
                        <input type="text" id="placa" name="placa"
                               value="${veiculo.placa}" class="form-control"
                               maxlength="8" placeholder="ABC1D23"
                               data-mask="placa" data-validate="placa" required
                               style="text-transform:uppercase">
                    </div>
                    <div class="form-group">
                        <label for="rntrc">RNTRC *</label>
                        <input type="text" id="rntrc" name="rntrc"
                               value="${veiculo.rntrc}" class="form-control"
                               maxlength="15" required data-allow="alphanum">
                    </div>
                    <div class="form-group">
                        <label for="anoFabricacao">Ano de Fabricação *</label>
                        <input type="text" id="anoFabricacao" name="anoFabricacao"
                               value="${veiculo.anoFabricacao}" class="form-control"
                               placeholder="2021" data-mask="ano" required maxlength="4">
                    </div>
                </div>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="tipo">Tipo *</label>
                        <select id="tipo" name="tipo" class="form-control" required>
                            <option value="">Selecione...</option>
                            <c:forEach var="t" items="${tipos}">
                                <option value="${t.codigo}"
                                    <c:if test="${veiculo.tipo == t}">selected</c:if>>
                                    ${t.descricao}
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
                                    <c:if test="${veiculo.status == s}">selected</c:if>>
                                    ${s.descricao}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <hr class="divider">
                <h3 style="margin-bottom:16px;font-family:'Rajdhani',sans-serif;font-size:1rem;
                           font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:.5px;">
                    Capacidade
                </h3>

                <div class="form-row cols-3">
                    <div class="form-group">
                        <label for="taraKg">Tara (kg) *</label>
                        <input type="text" id="taraKg" name="taraKg"
                               value="${veiculo.taraKg}" class="form-control"
                               placeholder="8.000,00" data-mask="decimal" data-max-digits="9" required>
                    </div>
                    <div class="form-group">
                        <label for="capacidadeKg">Capacidade de Carga (kg) *</label>
                        <input type="text" id="capacidadeKg" name="capacidadeKg"
                               value="${veiculo.capacidadeKg}" class="form-control"
                               placeholder="14.000,00" data-mask="decimal" data-max-digits="9" required>
                    </div>
                    <div class="form-group">
                        <label for="volumeM3">Volume (m³) *</label>
                        <input type="text" id="volumeM3" name="volumeM3"
                               value="${veiculo.volumeM3}" class="form-control"
                               placeholder="90,00" data-mask="decimal" data-max-digits="6" required>
                    </div>
                </div>

                <div style="display:flex;gap:10px;margin-top:24px;">
                    <button type="submit" class="btn btn-primary">Salvar</button>
                    <a href="${pageContext.request.contextPath}/veiculos" class="btn btn-secondary">Cancelar</a>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>
