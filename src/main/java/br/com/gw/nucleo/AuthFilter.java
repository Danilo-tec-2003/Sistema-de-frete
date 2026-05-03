package br.com.gw.nucleo;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Filtro de autenticação.
 * Intercepta /* e redireciona para /login caso não haja sessão ativa.
 * Libera: /login, /css/, /js/, /img/ e recursos estáticos.
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig cfg) {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        String ctx = req.getContextPath();

        // Recursos que nunca exigem autenticação
        if (isRecursoPublico(uri, ctx)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        boolean autenticado = (session != null && session.getAttribute("usuarioLogado") != null);

        if (autenticado) {
            chain.doFilter(request, response);
        } else {
            resp.sendRedirect(ctx + "/login");
        }
    }

    private boolean isRecursoPublico(String uri, String ctx) {
        return uri.equals(ctx + "/login")
            || uri.equals(ctx + "/cadastroUsuario")
            || uri.startsWith(ctx + "/css/")
            || uri.startsWith(ctx + "/js/")
            || uri.startsWith(ctx + "/img/")
            || uri.endsWith(".ico");
    }

    @Override
    public void destroy() {}
}
