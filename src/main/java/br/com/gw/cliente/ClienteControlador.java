package br.com.gw.cliente;

import br.com.gw.Enums.TipoCliente;
import br.com.gw.nucleo.exception.NegocioException;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;


@WebServlet("/clientes")
@MultipartConfig(maxFileSize = 2 * 1024 * 1024, maxRequestSize = 3 * 1024 * 1024)
public class ClienteControlador extends HttpServlet {

    private final ClienteBO bo = new ClienteBO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String acao = req.getParameter("acao");

        if ("logo".equals(acao)) {
            enviarLogo(req, resp);
            return;
        }

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

        Cliente c = new Cliente();

        try {
            c = montarClienteDoRequest(req);
            processarLogoDoRequest(req, c);
            bo.salvar(c);
            String msg = c.getId() == 0
                ? "Cliente+cadastrado+com+sucesso."
                : "Cliente+atualizado+com+sucesso.";
            resp.sendRedirect(req.getContextPath() + "/clientes?sucesso=" + msg);

        } catch (IllegalStateException e) {
            encaminharFormularioComErro(req, resp, c,
                "A logo deve ter no máximo 2 MB.");
        } catch (NegocioException e) {
            encaminharFormularioComErro(req, resp, c, e.getMessage());
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

    private void enviarLogo(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        int id = parseInt(req.getParameter("id"));
        if (id <= 0) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        try {
            Cliente logo = bo.buscarLogo(id);
            byte[] dados = logo.getLogoDados();
            resp.setContentType(logo.getLogoContentType());
            resp.setContentLength(dados.length);
            resp.setHeader("Cache-Control", "private, max-age=86400");
            resp.setHeader("X-Content-Type-Options", "nosniff");
            String nome = logo.getLogoNomeArquivo() == null ? "logo-cliente" : logo.getLogoNomeArquivo();
            resp.setHeader("Content-Disposition", "inline; filename=\"" + nome.replace("\"", "") + "\"");
            resp.getOutputStream().write(dados);
        } catch (NegocioException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
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

    private void processarLogoDoRequest(HttpServletRequest req, Cliente c)
            throws IOException, ServletException {

        c.setRemoverLogo("on".equals(req.getParameter("removerLogo")));
        if (c.isRemoverLogo()) {
            c.setLogoAlterada(true);
            return;
        }

        Part logo = req.getPart("logoArquivo");
        if (logo == null || logo.getSize() == 0) return;

        c.setLogoAlterada(true);
        c.setLogoNomeArquivo(normalizarNomeArquivo(logo.getSubmittedFileName()));
        c.setLogoContentType(normalizarContentType(logo.getContentType()));
        c.setLogoDados(lerBytes(logo));
    }

    private byte[] lerBytes(Part part) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try (InputStream in = part.getInputStream()) {
            byte[] buffer = new byte[8192];
            int lidos;
            while ((lidos = in.read(buffer)) != -1) {
                out.write(buffer, 0, lidos);
            }
        }
        return out.toByteArray();
    }

    private String normalizarNomeArquivo(String nome) {
        if (nome == null || nome.trim().isEmpty()) return "logo-cliente";
        String limpo = nome.replace("\\", "/");
        int barra = limpo.lastIndexOf('/');
        if (barra >= 0) limpo = limpo.substring(barra + 1);
        limpo = limpo.replaceAll("[\\r\\n\"]", "").trim();
        return limpo.length() > 150 ? limpo.substring(0, 150) : limpo;
    }

    private String normalizarContentType(String contentType) {
        return contentType == null ? null : contentType.toLowerCase();
    }

    private void encaminharFormularioComErro(HttpServletRequest req, HttpServletResponse resp,
                                             Cliente c, String erro)
            throws ServletException, IOException {
        if (c.getId() > 0 && !c.isLogoAlterada()) {
            recarregarLogoExistente(c);
        } else if (c.isLogoAlterada()) {
            c.setLogoNomeArquivo(null);
            c.setLogoContentType(null);
            c.setLogoDados(null);
        }
        req.setAttribute("erro", erro);
        req.setAttribute("cliente", c);
        req.getRequestDispatcher("/jsp/clientes/FormCliente.jsp").forward(req, resp);
    }

    private void recarregarLogoExistente(Cliente c) {
        try {
            Cliente atual = bo.buscarPorId(c.getId());
            c.setLogoNomeArquivo(atual.getLogoNomeArquivo());
            c.setLogoContentType(atual.getLogoContentType());
        } catch (NegocioException ignored) {
            // Se o recarregamento falhar, o formulário continua com os dados digitados.
        }
    }

    private int parseInt(String s) {
        try { return s == null ? 0 : Integer.parseInt(s.trim()); }
        catch (NumberFormatException e) { return 0; }
    }
}
