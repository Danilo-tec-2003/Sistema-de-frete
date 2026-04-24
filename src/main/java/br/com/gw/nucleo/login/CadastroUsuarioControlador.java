package br.com.gw.nucleo.login;
import br.com.gw.nucleo.exception.NegocioException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
// ✅ Adicionar na classe CadastroUsuarioControlador.java
import javax.servlet.annotation.WebServlet;

@WebServlet("/cadastroUsuario")
public class CadastroUsuarioControlador extends HttpServlet {

    private final CadastroUsuarioBO bo = new CadastroUsuarioBO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/jsp/cadastroUsuario.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String nome          = req.getParameter("nome");
        String login         = req.getParameter("login");
        String senha         = req.getParameter("senha");
        String confirmaSenha = req.getParameter("confirmaSenha");

        try {
            bo.cadastrar(nome, login, senha, confirmaSenha);
            // Redireciona para login com flag de sucesso
            resp.sendRedirect(req.getContextPath() + "/login?cadastro=ok");
        } catch (NegocioException e) {
            req.setAttribute("erro", e.getMessage());
            // Devolve os dados para não precisar redigitar
            req.setAttribute("nome",  nome);
            req.setAttribute("login", login);
            req.getRequestDispatcher("/jsp/cadastroUsuario.jsp").forward(req, resp);
        }
    }
}
