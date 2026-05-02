package br.com.gw.cliente;

import br.com.gw.Enums.TipoCliente;
import br.com.gw.nucleo.exception.NegocioException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;


@WebServlet("/clientes")
public class ClienteControlador extends HttpServlet {

    private final ClienteBO bo = new ClienteBO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String acao = req.getParameter("acao");

        if ("novo".equals(acao)) {
            req.getRequestDispatcher("/jsp/clientes/FormCliente.jsp").forward(req, resp);
            return;
        }

        if ("editar".equals(acao)) {
            int id = parseInt(req.getParameter("id"));
            try {
                Cliente c = bo.buscarPorId(id);
                req.setAttribute("cliente", c);
                req.getRequestDispatcher("/jsp/clientes/FormCliente.jsp").forward(req, resp);
            } catch (NegocioException e) {
                req.setAttribute("erro", e.getMessage());
                listarComErro(req, resp);
            }
            return;
        }

        if ("excluir".equals(acao)) {
            int id = parseInt(req.getParameter("id"));
            try {
                bo.excluir(id);
                resp.sendRedirect(req.getContextPath()
                    + "/clientes?sucesso=Cliente+exclu%C3%ADdo+com+sucesso.");
            } catch (NegocioException e) {
                req.setAttribute("erro", e.getMessage());
                listarComErro(req, resp);
            }
            return;
        }

        listarComErro(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        Cliente c = montarClienteDoRequest(req);

        try {
            bo.salvar(c);
            String msg = c.getId() == 0
                ? "Cliente+cadastrado+com+sucesso."
                : "Cliente+atualizado+com+sucesso.";
            resp.sendRedirect(req.getContextPath() + "/clientes?sucesso=" + msg);

        } catch (NegocioException e) {
            req.setAttribute("erro",    e.getMessage());
            req.setAttribute("cliente", c);
            req.getRequestDispatcher("/jsp/clientes/FormCliente.jsp").forward(req, resp);
        }
    }

    private void listarComErro(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String filtro  = req.getParameter("filtro");
        int    pagina  = parseInt(req.getParameter("pagina"));
        if (pagina < 1) pagina = 1;

        try {
            req.setAttribute("clientes",    bo.listar(filtro, pagina));
            req.setAttribute("totalPaginas",bo.totalPaginas(filtro));
            req.setAttribute("paginaAtual", pagina);
            req.setAttribute("filtro",      filtro);
            req.setAttribute("sucesso",     req.getParameter("sucesso"));
        } catch (NegocioException e) {
            req.setAttribute("erro", e.getMessage());
        }
        req.getRequestDispatcher("/jsp/clientes/listarClientes.jsp").forward(req, resp);
    }

    private Cliente montarClienteDoRequest(HttpServletRequest req) {
        Cliente c = new Cliente();
        c.setId(parseInt(req.getParameter("id")));
        c.setRazaoSocial(req.getParameter("razaoSocial"));
        c.setNomeFantasia(req.getParameter("nomeFantasia"));
        c.setCnpj(req.getParameter("cnpj"));
        c.setInscricaoEst(req.getParameter("inscricaoEst"));
        c.setTipo(TipoCliente.AMBOS);

        c.setLogradouro(req.getParameter("logradouro"));
        c.setNumeroEnd(req.getParameter("numeroEnd"));
        c.setComplemento(req.getParameter("complemento"));
        c.setBairro(req.getParameter("bairro"));
        c.setMunicipio(req.getParameter("municipio"));
        c.setUf(req.getParameter("uf"));
        c.setCep(req.getParameter("cep"));
        c.setTelefone(req.getParameter("telefone"));
        c.setEmail(req.getParameter("email"));
        c.setAtivo("on".equals(req.getParameter("ativo")) || "true".equals(req.getParameter("ativo")));
        return c;
    }

    private int parseInt(String s) {
        try { return s == null ? 0 : Integer.parseInt(s.trim()); }
        catch (NumberFormatException e) { return 0; }
    }
}
