package br.com.gw.nucleo.login;

import br.com.gw.nucleo.exception.NegocioException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controla o fluxo de login e logout.
 * GET  /login  → exibe login.jsp
 * POST /login  → autentica; redireciona para home ou volta ao login com erro
 * GET  /logout → invalida sessão e redireciona para login
 */
@WebServlet(urlPatterns = {"/login", "/logout"})
public class LoginControlador extends HttpServlet {

    private final LoginBO loginBO = new LoginBO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String uri = req.getRequestURI();

        if (uri.endsWith("/logout")) {
            HttpSession session = req.getSession(false);
            if (session != null) session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Se já está logado, vai direto para home
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("usuarioLogado") != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String login = req.getParameter("login");
        String senha = req.getParameter("senha");

        try {
            Usuario usuario = loginBO.autenticar(login, senha);

            HttpSession session = req.getSession(true);
            session.setAttribute("usuarioLogado", usuario);
            session.setMaxInactiveInterval(30 * 60); // 30 min

            resp.sendRedirect(req.getContextPath() + "/home");

        } catch (NegocioException e) {
            req.setAttribute("erro", e.getMessage());
            req.setAttribute("loginDigitado", login);
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
}