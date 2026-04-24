<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>${empty veiculo.id || veiculo.id == 0 ? 'Novo Veículo' : 'Editar Veículo'} – GW Fretes</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
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
                    <input type="text" id="placa" name="placa"
                           value="${veiculo.placa}" class="form-control" required
                           maxlength="8" placeholder="ABC1D23"
                           style="text-transform:uppercase">
                </div>
                <div class="form-group">
                    <label for="rntrc">RNTRC</label>
                    <input type="text" id="rntrc" name="rntrc"
                           value="${veiculo.rntrc}" class="form-control" maxlength="15">
                </div>
                <div class="form-group">
                    <label for="anoFabricacao">Ano de Fabricação</label>
                    <input type="number" id="anoFabricacao" name="anoFabricacao"
                           value="${veiculo.anoFabricacao}" class="form-control"
                           min="1950" max="2027" placeholder="2021">
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
                        <c:forEach var="s" items="${statusList}">
                            <option value="${s.codigo}"
                                <c:if test="${veiculo.status == s}">selected</c:if>
                                <c:if test="${empty veiculo && s.codigo.equals('D')}">selected</c:if>>
                                ${s.descricao}
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <h3 style="margin:20px 0 16px;font-size:15px;color:#555;">Capacidade</h3>

            <div class="form-row cols-3">
                <div class="form-group">
                    <label for="taraKg">Tara (kg)</label>
                    <input type="number" id="taraKg" name="taraKg"
                           value="${veiculo.taraKg}" class="form-control"
                           min="0" step="0.01" placeholder="8000">
                </div>
                <div class="form-group">
                    <label for="capacidadeKg">Capacidade de Carga (kg)</label>
                    <input type="number" id="capacidadeKg" name="capacidadeKg"
                           value="${veiculo.capacidadeKg}" class="form-control"
                           min="0" step="0.01" placeholder="14000">
                </div>
                <div class="form-group">
                    <label for="volumeM3">Volume (m³)</label>
                    <input type="number" id="volumeM3" name="volumeM3"
                           value="${veiculo.volumeM3}" class="form-control"
                           min="0" step="0.001" placeholder="90.0">
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