<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Novo Frete – GW Fretes</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/validacoes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/componentes.css">
</head>
<body>
<%@ include file="/jsp/NavBar.jsp" %>
<div class="container">

    <div class="page-header">
        <h1>Emitir Frete</h1>
        <a href="${pageContext.request.contextPath}/fretes" class="btn btn-secondary">&larr; Voltar</a>
    </div>

    <c:if test="${not empty erro}">
        <div class="alert alert-erro" role="alert">${erro}</div>
    </c:if>

    <div class="card">
        <form method="post" action="${pageContext.request.contextPath}/fretes" novalidate
              id="form-frete">
            <input type="hidden" name="acao" value="emitir">

            <%-- ================================================
                 PARTES (Remetente, Destinatário, Motorista, Veículo)
                 ================================================ --%>
            <h3 class="secao-titulo">Partes</h3>

            <div class="form-row cols-2">
                <div class="form-group">
                    <label for="idRemetente">Remetente <span class="obrigatorio">*</span></label>
                    <select id="idRemetente" name="idRemetente" class="form-control">
                        <option value="">Selecione o remetente...</option>
                        <c:forEach var="c" items="${clientes}">
                            <option value="${c.id}"
                                <c:if test="${frete.idRemetente == c.id}">selected</c:if>>
                                ${c.razaoSocial}
                                <c:if test="${not empty c.cnpj}"> — ${c.cnpj}</c:if>
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label for="idDestinatario">Destinatário <span class="obrigatorio">*</span></label>
                    <select id="idDestinatario" name="idDestinatario" class="form-control">
                        <option value="">Selecione o destinatário...</option>
                        <c:forEach var="c" items="${clientes}">
                            <option value="${c.id}"
                                <c:if test="${frete.idDestinatario == c.id}">selected</c:if>>
                                ${c.razaoSocial}
                                <c:if test="${not empty c.cnpj}"> — ${c.cnpj}</c:if>
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
                            <option value="${m.id}"
                                <c:if test="${frete.idMotorista == m.id}">selected</c:if>>
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
                            <option value="${v.id}"
                                <c:if test="${frete.idVeiculo == v.id}">selected</c:if>>
                                ${v.placa} — ${v.tipo.descricao}
                                <c:if test="${not empty v.capacidadeKg}">
                                    (${v.capacidadeKg} kg)
                                </c:if>
                            </option>
                        </c:forEach>
                    </select>
                    <small class="campo-hint">Somente veículos Disponíveis são listados.</small>
                </div>
            </div>

            <%-- ================================================
                 ROTA
                 ================================================ --%>
            <h3 class="secao-titulo">Rota</h3>

            <div class="form-row cols-2">
                <div class="form-group">
                    <label for="municipioOrigem">Município de Origem <span class="obrigatorio">*</span></label>
                    <input type="text" id="municipioOrigem" name="municipioOrigem"
                           value="${frete.municipioOrigem}" class="form-control" maxlength="80"
                           placeholder="Recife">
                </div>
                <div class="form-group">
                    <label for="ufOrigem">UF Origem <span class="obrigatorio">*</span></label>
                    <input type="text" id="ufOrigem" name="ufOrigem"
                           value="${frete.ufOrigem}" class="form-control"
                           maxlength="2" placeholder="PE" style="text-transform:uppercase">
                </div>
            </div>

            <div class="form-row cols-2">
                <div class="form-group">
                    <label for="municipioDestino">Município de Destino <span class="obrigatorio">*</span></label>
                    <input type="text" id="municipioDestino" name="municipioDestino"
                           value="${frete.municipioDestino}" class="form-control" maxlength="80"
                           placeholder="São Paulo">
                </div>
                <div class="form-group">
                    <label for="ufDestino">UF Destino <span class="obrigatorio">*</span></label>
                    <input type="text" id="ufDestino" name="ufDestino"
                           value="${frete.ufDestino}" class="form-control"
                           maxlength="2" placeholder="SP" style="text-transform:uppercase">
                </div>
            </div>

            <%-- ================================================
                 CARGA
                 ================================================ --%>
            <h3 class="secao-titulo">Carga</h3>

            <div class="form-row cols-1">
                <div class="form-group">
                    <label for="descricaoCarga">Descrição da Carga</label>
                    <input type="text" id="descricaoCarga" name="descricaoCarga"
                           value="${frete.descricaoCarga}" class="form-control" maxlength="200"
                           placeholder="Eletrônicos, alimentos, etc.">
                </div>
            </div>

            <div class="form-row cols-2">
                <div class="form-group">
                    <label for="pesoKg">Peso (kg)</label>
                    <input type="number" id="pesoKg" name="pesoKg"
                           value="${frete.pesoKg}" class="form-control"
                           min="0" step="0.01" placeholder="1500" inputmode="decimal">
                </div>
                <div class="form-group">
                    <label for="volumes">Volumes</label>
                    <input type="number" id="volumes" name="volumes"
                           value="${frete.volumes}" class="form-control"
                           min="0" step="1" placeholder="10" inputmode="numeric">
                </div>
            </div>

            <%-- ================================================
                 VALORES FINANCEIROS
                 ================================================ --%>
            <h3 class="secao-titulo">Valores</h3>

            <div class="form-row cols-2">
                <div class="form-group">
                    <label for="valorFrete">Valor do Frete (R$) <span class="obrigatorio">*</span></label>
                    <input type="number" id="valorFrete" name="valorFrete"
                           value="${frete.valorFrete}" class="form-control"
                           min="0.01" step="0.01" placeholder="5000.00"
                           inputmode="decimal">
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
                           value="${frete.aliquotaIcms}" class="form-control"
                           min="0" max="100" step="0.01" placeholder="12.00"
                           inputmode="decimal">
                    <small class="campo-hint">Valor calculado automaticamente.</small>
                </div>
                <div class="form-group">
                    <label for="aliquotaIbs">Alíquota IBS (%) <span class="campo-hint-inline">Diferencial B</span></label>
                    <input type="number" id="aliquotaIbs" name="aliquotaIbs"
                           value="${frete.aliquotaIbs}" class="form-control"
                           min="0" max="100" step="0.01" placeholder="3.60"
                           inputmode="decimal">
                </div>
                <div class="form-group">
                    <label for="aliquotaCbs">Alíquota CBS (%) <span class="campo-hint-inline">Diferencial B</span></label>
                    <input type="number" id="aliquotaCbs" name="aliquotaCbs"
                           value="${frete.aliquotaCbs}" class="form-control"
                           min="0" max="100" step="0.01" placeholder="0.90"
                           inputmode="decimal">
                </div>
            </div>

            <%-- Preview de valores calculados --%>
            <div class="info-calculada" id="preview-valores" style="display:none">
                <strong>Preview de valores:</strong>
                <span id="preview-icms"></span>
                <span id="preview-ibs"></span>
                <span id="preview-cbs"></span>
                <span id="preview-total"></span>
            </div>

            <%-- ================================================
                 DADOS DO REACT (Calculadora Fiscal — Diferencial C)
                 ================================================ --%>
            <input type="hidden" id="uf-origem-hidden"  value="">
            <input type="hidden" id="uf-destino-hidden" value="">
            <div id="calculadora-fiscal" class="mt-16"></div>

            <div class="form-group" style="margin-top:16px;">
                <label for="observacao">Observações</label>
                <textarea id="observacao" name="observacao" class="form-control"
                          rows="3" maxlength="1000"
                          placeholder="Informações adicionais...">${frete.observacao}</textarea>
            </div>

            <div class="form-acoes">
                <button type="submit" class="btn btn-primary">
                    <span class="btn-icon">✓</span> Emitir Frete
                </button>
                <a href="${pageContext.request.contextPath}/fretes" class="btn btn-secondary">
                    Cancelar
                </a>
            </div>
        </form>
    </div>
</div>

<script>
/* Preview de valores calculados — inline, sem dependência do módulo */
(function () {
    const frete   = document.getElementById('valorFrete');
    const aIcms   = document.getElementById('aliquotaIcms');
    const aIbs    = document.getElementById('aliquotaIbs');
    const aCbs    = document.getElementById('aliquotaCbs');
    const preview = document.getElementById('preview-valores');

    const fmt = (v) => 'R$ ' + v.toFixed(2).replace('.', ',');

    function calcular() {
        const vf = parseFloat(frete.value)   || 0;
        const qi = parseFloat(aIcms.value)   || 0;
        const qb = parseFloat(aIbs.value)    || 0;
        const qc = parseFloat(aCbs.value)    || 0;

        if (vf <= 0) { preview.style.display = 'none'; return; }

        const icms  = +(vf * qi / 100).toFixed(2);
        const ibs   = +(vf * qb / 100).toFixed(2);
        const cbs   = +(vf * qc / 100).toFixed(2);
        const total = +(vf + icms + ibs + cbs).toFixed(2);

        document.getElementById('preview-icms').textContent  =
            qi > 0 ? ` ICMS: ${fmt(icms)}` : '';
        document.getElementById('preview-ibs').textContent   =
            qb > 0 ? ` | IBS: ${fmt(ibs)}`  : '';
        document.getElementById('preview-cbs').textContent   =
            qc > 0 ? ` | CBS: ${fmt(cbs)}`  : '';
        document.getElementById('preview-total').textContent =
            ` | Total: ${fmt(total)}`;
        preview.style.display = 'block';
    }

    [frete, aIcms, aIbs, aCbs].forEach(el => el.addEventListener('input', calcular));

    /* Sincroniza UF com os campos ocultos para o React */
    document.getElementById('ufOrigem').addEventListener('input', function () {
        document.getElementById('uf-origem-hidden').value = this.value.toUpperCase();
    });
    document.getElementById('ufDestino').addEventListener('input', function () {
        document.getElementById('uf-destino-hidden').value = this.value.toUpperCase();
    });

    /* Validação do formulário */
    document.getElementById('form-frete').addEventListener('submit', function (e) {
        let valido = true;
        const erros = [];

        if (!document.getElementById('idRemetente').value)
            { erros.push('Selecione o Remetente.'); valido = false; }
        if (!document.getElementById('idDestinatario').value)
            { erros.push('Selecione o Destinatário.'); valido = false; }
        if (document.getElementById('idRemetente').value
                && document.getElementById('idRemetente').value
                    === document.getElementById('idDestinatario').value)
            { erros.push('Remetente e Destinatário não podem ser iguais.'); valido = false; }
        if (!document.getElementById('idMotorista').value)
            { erros.push('Selecione o Motorista.'); valido = false; }
        if (!document.getElementById('idVeiculo').value)
            { erros.push('Selecione o Veículo.'); valido = false; }
        if (!document.getElementById('municipioOrigem').value.trim())
            { erros.push('Informe o Município de Origem.'); valido = false; }
        if (!document.getElementById('municipioDestino').value.trim())
            { erros.push('Informe o Município de Destino.'); valido = false; }
        if (!document.getElementById('dataPrevEntrega').value)
            { erros.push('Informe a Data Prevista de Entrega.'); valido = false; }

        const vf = parseFloat(document.getElementById('valorFrete').value);
        if (!vf || vf <= 0) { erros.push('O Valor do Frete deve ser maior que zero.'); valido = false; }

        if (!valido) {
            e.preventDefault();
            alert(erros.join('\n'));
        }
    });
})();
</script>
<script type="module" src="${pageContext.request.contextPath}/js/validacoes.js"></script>
</body>
</html>