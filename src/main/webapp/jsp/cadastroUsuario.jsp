<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>GW Transportes – Criar Conta</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #1a2035; min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .card-login { width: 420px; border-radius: 12px; box-shadow: 0 8px 32px rgba(0,0,0,.4); }
        .brand { color: #f5a623; font-weight: 700; font-size: 1.6rem; letter-spacing: 1px; }
    </style>
</head>
<body>
<div class="card card-login p-4">
    <div class="text-center mb-4">
        <p class="brand">GW TRANSPORTES</p>
        <small class="text-muted">Criar nova conta</small>
    </div>

    <% if (request.getAttribute("erro") != null) { %>
    <div class="alert alert-danger py-2">
        <%= request.getAttribute("erro") %>
    </div>
    <% } %>

    <form action="${pageContext.request.contextPath}/cadastroUsuario" method="post">

        <div class="mb-3">
            <label class="form-label fw-semibold">Nome completo</label>
            <input type="text" name="nome" class="form-control" required autofocus
                   value="${nome}">
        </div>

        <div class="mb-3">
            <label class="form-label fw-semibold">Login</label>
            <input type="text" name="login" class="form-control" required
                   minlength="4" placeholder="mínimo 4 caracteres"
                   value="${login}">
        </div>

        <div class="mb-3">
            <label class="form-label fw-semibold">Senha</label>
            <input type="password" name="senha" class="form-control" required
                   minlength="6" placeholder="mínimo 6 caracteres">
        </div>

        <div class="mb-4">
            <label class="form-label fw-semibold">Confirmar senha</label>
            <input type="password" name="confirmaSenha" class="form-control" required>
        </div>

        <button type="submit" class="btn btn-warning w-100 fw-bold mb-3">Criar conta</button>

        <div class="text-center">
            <small>Já tem conta?
                <a href="${pageContext.request.contextPath}/login">Fazer login</a>
            </small>
        </div>
    </form>
</div>
</body>
</html>