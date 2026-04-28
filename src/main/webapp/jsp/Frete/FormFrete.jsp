<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Novo Frete – FiscalMove FMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Exo+2:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/validacoes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/componentes.css">
</head>
<body>
<%@ include file="/jsp/NavBar.jsp" %>

<div class="main-wrapper">

    <%-- Topbar padronizada --%>
    <div class="topbar">
        <div class="topbar-title">Emitir Frete</div>
        <div class="topbar-actions">
            <a href="${pageContext.request.contextPath}/fretes" class="btn btn-secondary">&larr; Voltar</a>
        </div>
    </div>

    <div class="container">

        <c:if test="${not empty erro}">
            <div class="alert alert-erro" role="alert">${erro}</div>
        </c:if>

        <div class="card">
            <form method="post" action="${pageContext.request.contextPath}/fretes" novalidate id="form-frete">
                <input type="hidden" name="acao" value="emitir">

                <h3 class="secao-titulo">Partes</h3>
                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="idRemetente">Remetente <span class="obrigatorio">*</span></label>
                        <select id="idRemetente" name="idRemetente" class="form-control">
                            <option value="">Selecione o remetente...</option>
                            <c:forEach var="c" items="${clientes}">
                                <option value="${c.id}" <c:if test="${frete.idRemetente == c.id}">selected</c:if>>
                                    ${c.razaoSocial}<c:if test="${not empty c.cnpj}"> — ${c.cnpj}</c:if>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="idDestinatario">Destinatário <span class="obrigatorio">*</span></label>
                        <select id="idDestinatario" name="idDestinatario" class="form-control">
                            <option value="">Selecione o destinatário...</option>
                            <c:forEach var="c" items="${clientes}">
                                <option value="${c.id}" <c:if test="${frete.idDestinatario == c.id}">selected</c:if>>
                                    ${c.razaoSocial}<c:if test="${not empty c.cnpj}"> — ${c.cnpj}</c:if>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="idMotorista">Motorista <span class="obrigatorio">*</span></label>
                        <select id="idMotorista" name="idMotorista" class="form-control">
                            <option value="">Selecione o motorista...</option>
                            <c:forEach var="m" items="${motoristas}">
                                <option value="${m.id}" <c:if test="${frete.idMotorista == m.id}">selected</c:if>>
                                    ${m.nome} — CPF: ${m.cpf}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="idVeiculo">Veículo <span class="obrigatorio">*</span></label>
                        <select id="idVeiculo" name="idVeiculo" class="form-control">
                            <option value="">Selecione o veículo...</option>
                            <c:forEach var="v" items="${veiculos}">
                                <option value="${v.id}" <c:if test="${frete.idVeiculo == v.id}">selected</c:if>>
                                    ${v.placa} — ${v.tipo.descricao}
                                    <c:if test="${not empty v.capacidadeKg}">(${v.capacidadeKg} kg)</c:if>
                                </option>
                            </c:forEach>
                        </select>
                        <small class="campo-hint">Somente veículos Disponíveis são listados.</small>
                    </div>
                </div>

                <h3 class="secao-titulo">Rota</h3>
                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="municipioOrigem">Município de Origem <span class="obrigatorio">*</span></label>
                        <input type="text" id="municipioOrigem" name="municipioOrigem"
                               value="${frete.municipioOrigem}" class="form-control" maxlength="80">
                    </div>
                    <div class="form-group">
                        <label for="ufOrigem">UF Origem <span class="obrigatorio">*</span></label>
                        <input type="text" id="ufOrigem" name="ufOrigem"
                               value="${frete.ufOrigem}" class="form-control" maxlength="2"
                               style="text-transform:uppercase">
                    </div>
                </div>

                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="municipioDestino">Município de Destino <span class="obrigatorio">*</span></label>
                        <input type="text" id="municipioDestino" name="municipioDestino"
                               value="${frete.municipioDestino}" class="form-control" maxlength="80">
                    </div>
                    <div class="form-group">
                        <label for="ufDestino">UF Destino <span class="obrigatorio">*</span></label>
                        <input type="text" id="ufDestino" name="ufDestino"
                               value="${frete.ufDestino}" class="form-control" maxlength="2"
                               style="text-transform:uppercase">
                    </div>
                </div>

                <h3 class="secao-titulo">Carga</h3>
                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="pesoKg">Peso (kg)</label>
                        <input type="number" id="pesoKg" name="pesoKg"
                               value="${frete.pesoKg}" class="form-control" step="0.01" min="0">
                    </div>
                    <div class="form-group">
                        <label for="volumes">Volumes</label>
                        <input type="number" id="volumes" name="volumes"
                               value="${frete.volumes}" class="form-control" step="1" min="0">
                    </div>
                </div>

                <h3 class="secao-titulo">Valores</h3>
                <div class="form-row cols-2">
                    <div class="form-group">
                        <label for="valorFrete">Valor do Frete (R$) <span class="obrigatorio">*</span></label>
                        <input type="number" id="valorFrete" name="valorFrete"
                               value="${frete.valorFrete}" class="form-control" step="0.01" min="0.01">
                    </div>
                    <div class="form-group">
                        <label for="dataPrevEntrega">Data Prev. Entrega <span class="obrigatorio">*</span></label>
                        <input type="date" id="dataPrevEntrega" name="dataPrevEntrega"
                               value="${frete.dataPrevEntrega}" class="form-control">
                    </div>
                </div>

                <div class="form-row cols-3">
                    <div class="form-group">
                        <label for="aliquotaIcms">Alíquota ICMS (%)</label>
                        <input type="number" id="aliquotaIcms" name="aliquotaIcms"
                               value="${frete.aliquotaIcms}" class="form-control" step="0.01" min="0">
                    </div>
                    <div class="form-group">
                        <label for="aliquotaIbs">Alíquota IBS (%)</label>
                        <input type="number" id="aliquotaIbs" name="aliquotaIbs"
                               value="${frete.aliquotaIbs}" class="form-control" step="0.01" min="0">
                    </div>
                    <div class="form-group">
                        <label for="aliquotaCbs">Alíquota CBS (%)</label>
                        <input type="number" id="aliquotaCbs" name="aliquotaCbs"
                               value="${frete.aliquotaCbs}" class="form-control" step="0.01" min="0">
                    </div>
                </div>

                <div class="info-calculada" id="preview-valores" style="display:none">
                    <strong>Preview de valores:</strong>
                    <span id="preview-icms"></span>
                    <span id="preview-ibs"></span>
                    <span id="preview-cbs"></span>
                    <span id="preview-total"></span>
                </div>

                <div class="form-group" style="margin-top:16px;">
                    <label for="observacao">Observações</label>
                    <textarea id="observacao" name="observacao" class="form-control" rows="3">${frete.observacao}</textarea>
                </div>

                <div class="form-acoes">
                    <button type="submit" class="btn btn-primary">✓ Emitir Frete</button>
                    <a href="${pageContext.request.contextPath}/fretes" class="btn btn-secondary">Cancelar</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
(function () {
    var freteInput = document.getElementById('valorFrete');
    var aIcms      = document.getElementById('aliquotaIcms');
    var aIbs       = document.getElementById('aliquotaIbs');
    var aCbs       = document.getElementById('aliquotaCbs');
    var preview    = document.getElementById('preview-valores');

    function formatarMoeda(v) {
        return 'R$ ' + v.toFixed(2).replace('.', ',');
    }

    function calcular() {
        var vf = parseFloat(freteInput.value) || 0;
        var qi = parseFloat(aIcms.value)      || 0;
        var qb = parseFloat(aIbs.value)       || 0;
        var qc = parseFloat(aCbs.value)       || 0;

        if (vf <= 0) {
            preview.style.display = 'none';
            return;
        }

        var icms  = +(vf * qi / 100).toFixed(2);
        var ibs   = +(vf * qb / 100).toFixed(2);
        var cbs   = +(vf * qc / 100).toFixed(2);
        var total = +(vf + icms + ibs + cbs).toFixed(2);

        document.getElementById('preview-icms').textContent  = (qi > 0) ? ' ICMS: '  + formatarMoeda(icms)  : '';
        document.getElementById('preview-ibs').textContent   = (qb > 0) ? ' | IBS: ' + formatarMoeda(ibs)   : '';
        document.getElementById('preview-cbs').textContent   = (qc > 0) ? ' | CBS: ' + formatarMoeda(cbs)   : '';
        document.getElementById('preview-total').textContent = ' | Total: ' + formatarMoeda(total);

        preview.style.display = 'block';
    }

    [freteInput, aIcms, aIbs, aCbs].forEach(function (el) {
        if (el) el.addEventListener('input', calcular);
    });

    /* ── Validação completa no submit ── */
    var form = document.getElementById('form-frete');
    if (form) {
        form.addEventListener('submit', function (e) {
            var erros = [];

            /* Selects obrigatórios */
            if (!document.getElementById('idRemetente').value)   erros.push('Remetente');
            if (!document.getElementById('idDestinatario').value) erros.push('Destinatário');
            if (!document.getElementById('idMotorista').value)   erros.push('Motorista');
            if (!document.getElementById('idVeiculo').value)     erros.push('Veículo');

            /* Campos de texto obrigatórios */
            if (!document.getElementById('municipioOrigem').value.trim())  erros.push('Município de Origem');
            if (!document.getElementById('ufOrigem').value.trim())         erros.push('UF Origem');
            if (!document.getElementById('municipioDestino').value.trim()) erros.push('Município de Destino');
            if (!document.getElementById('ufDestino').value.trim())        erros.push('UF Destino');

            /* Valor do frete */
            var vf = parseFloat(document.getElementById('valorFrete').value);
            if (!vf || vf <= 0) erros.push('Valor do Frete (deve ser maior que zero)');

            /* Data de entrega: obrigatória e não pode ser passado */
            var dataEl = document.getElementById('dataPrevEntrega');
            if (!dataEl.value) {
                erros.push('Data Prev. Entrega');
            } else {
                var hoje     = new Date(); hoje.setHours(0, 0, 0, 0);
                var partes   = dataEl.value.split('-');
                var dataInf  = new Date(partes[0], partes[1] - 1, partes[2]);
                if (dataInf < hoje) erros.push('Data Prev. Entrega (não pode ser uma data passada)');
            }

            if (erros.length > 0) {
                e.preventDefault();
                alert('Corrija os seguintes campos obrigatórios:\n\n- ' + erros.join('\n- '));
            }
        });
    }
})();
</script>
<script type="module" src="${pageContext.request.contextPath}/js/validacoes.js"></script>
</body>
</html>