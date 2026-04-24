<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>${empty veiculo.id || veiculo.id == 0 ? 'Novo Veículo' : 'Editar Veículo'} – GW Fretes</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/imask@7.6.1/dist/imask.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/masks.js" defer></script>
</head>
<body>
<%@ include file="/jsp/NavBar.jsp" %>
<div class="container">

    <div class="page-header">
        <h1>${empty veiculo.id || veiculo.id == 0 ? 'Novo Veículo' : 'Editar Veículo'}</h1>
        <a href="${pageContext.request.contextPath}/veiculos" class="btn btn-secondary">&larr; Voltar</a>
    </div>

    <c:if test="${not empty erro}">
        <div class="alert alert-erro">${erro}</div>
    </c:if>

    <div class="card">
        <form method="post" action="${pageContext.request.contextPath}/veiculos">
            <input type="hidden" name="id" value="${veiculo.id}">

            <h3 style="margin-bottom:16px;font-size:15px;color:#555;">Identificação</h3>

            <div class="form-row cols-3">
                <div class="form-group">
                    <label for="placa">Placa *</label>
                    <%-- type="text" obrigatório — IMask não funciona com type="number" --%>
                    <input type="text" id="placa" name="placa"
                           value="${veiculo.placa}" class="form-control"
                           maxlength="8" placeholder="ABC1D23"
                           data-mask="placa" required
                           style="text-transform:uppercase">
                </div>
                <div class="form-group">
                    <label for="rntrc">RNTRC *</label>
                    <input type="text" id="rntrc" name="rntrc"
                           value="${veiculo.rntrc}" class="form-control"
                           maxlength="15" required>
                </div>
                <div class="form-group">
                    <label for="anoFabricacao">Ano de Fabricação *</label>
                    <%-- type="text" + data-mask="ano" — evita conflito com IMask --%>
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

            <h3 style="margin:20px 0 16px;font-size:15px;color:#555;">Capacidade</h3>

            <div class="form-row cols-3">
                <div class="form-group">
                    <label for="taraKg">Tara (kg) *</label>
                    <%-- type="text" obrigatório — IMask não funciona com type="number" --%>
                    <input type="text" id="taraKg" name="taraKg"
                           value="${veiculo.taraKg}" class="form-control"
                           placeholder="8.000,00" data-mask="decimal" required>
                </div>
                <div class="form-group">
                    <label for="capacidadeKg">Capacidade de Carga (kg) *</label>
                    <input type="text" id="capacidadeKg" name="capacidadeKg"
                           value="${veiculo.capacidadeKg}" class="form-control"
                           placeholder="14.000,00" data-mask="decimal" required>
                </div>
                <div class="form-group">
                    <label for="volumeM3">Volume (m³) *</label>
                    <input type="text" id="volumeM3" name="volumeM3"
                           value="${veiculo.volumeM3}" class="form-control"
                           placeholder="90,00" data-mask="decimal" required>
                </div>
            </div>

            <div style="display:flex;gap:10px;margin-top:20px;">
                <button type="submit" class="btn btn-primary">Salvar</button>
                <a href="${pageContext.request.contextPath}/veiculos" class="btn btn-secondary">Cancelar</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>