package br.com.gw.veiculos;

import br.com.gw.Enums.StatusVeiculo;
import br.com.gw.Enums.TipoVeiculo;
import br.com.gw.nucleo.exception.NegocioException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;

@WebServlet("/veiculos")
public class VeiculoControlador extends HttpServlet {

    private final VeiculoBO bo = new VeiculoBO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String acao = req.getParameter("acao");

        if ("novo".equals(acao)) {
            req.setAttribute("tipos",      TipoVeiculo.values());
            req.setAttribute("statusList", StatusVeiculo.values());
            req.getRequestDispatcher("/jsp/veiculos/FormVeiculos.jsp").forward(req, resp);
            return;
        }

        if ("editar".equals(acao)) {
            int id = parseInt(req.getParameter("id"));
            try {
                req.setAttribute("veiculo",    bo.buscarPorId(id));
                req.setAttribute("tipos",      TipoVeiculo.values());
                req.setAttribute("statusList", StatusVeiculo.values());
                req.getRequestDispatcher("/jsp/veiculos/FormVeiculos.jsp").forward(req, resp);
            } catch (NegocioException e) {
                req.setAttribute("erro", e.getMessage());
                listar(req, resp);
            }
            return;
        }

        if ("excluir".equals(acao)) {
            int id = parseInt(req.getParameter("id"));
            try {
                bo.excluir(id);
                resp.sendRedirect(req.getContextPath()
                    + "/veiculos?sucesso=Ve%C3%ADculo+exclu%C3%ADdo+com+sucesso.");
            } catch (NegocioException e) {
                req.setAttribute("erro", e.getMessage());
                listar(req, resp);
            }
            return;
        }

        listar(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        Veiculo v = montarDoRequest(req);

        try {
            bo.salvar(v);
            String msg = v.getId() == 0
                ? "Ve%C3%ADculo+cadastrado+com+sucesso."
                : "Ve%C3%ADculo+atualizado+com+sucesso.";
            resp.sendRedirect(req.getContextPath() + "/veiculos?sucesso=" + msg);
        } catch (NegocioException e) {
            req.setAttribute("erro",       e.getMessage());
            req.setAttribute("veiculo",    v);
            req.setAttribute("tipos",      TipoVeiculo.values());
            req.setAttribute("statusList", StatusVeiculo.values());
            req.getRequestDispatcher("/jsp/veiculos/FormVeiculos.jsp").forward(req, resp);
        }
    }

    private void listar(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String filtro = req.getParameter("filtro");
        int pagina = Math.max(1, parseInt(req.getParameter("pagina")));
        try {
            req.setAttribute("veiculos",     bo.listar(filtro, pagina));
            req.setAttribute("totalPaginas", bo.totalPaginas(filtro));
            req.setAttribute("paginaAtual",  pagina);
            req.setAttribute("filtro",       filtro);
            req.setAttribute("sucesso",      req.getParameter("sucesso"));
        } catch (NegocioException e) {
            req.setAttribute("erro", e.getMessage());
        }
        req.getRequestDispatcher("/jsp/veiculos/listarVeiculos.jsp").forward(req, resp);
    }

    private Veiculo montarDoRequest(HttpServletRequest req) {
        Veiculo v = new Veiculo();
        v.setId(parseInt(req.getParameter("id")));
        v.setPlaca(req.getParameter("placa"));
        v.setRntrc(req.getParameter("rntrc"));

        String ano = req.getParameter("anoFabricacao");
        if (ano != null && !ano.isEmpty()) {
            try { v.setAnoFabricacao(Integer.parseInt(ano.trim())); }
            catch (NumberFormatException ignored) {}
        }

        String tipo = req.getParameter("tipo");
        if (tipo != null && !tipo.isEmpty()) v.setTipo(TipoVeiculo.fromCodigo(tipo));

        v.setTaraKg(parseBD(req.getParameter("taraKg")));
        v.setCapacidadeKg(parseBD(req.getParameter("capacidadeKg")));
        v.setVolumeM3(parseBD(req.getParameter("volumeM3")));

        String stat = req.getParameter("status");
        if (stat != null && !stat.isEmpty()) v.setStatus(StatusVeiculo.fromCodigo(stat));

        return v;
    }

    private int parseInt(String s) {
        try { return s == null ? 0 : Integer.parseInt(s.trim()); }
        catch (NumberFormatException e) { return 0; }
    }

    private BigDecimal parseBD(String s) {
        try {
            if (s == null || s.trim().isEmpty()) return null;
            // remove pontos de milhar, troca vírgula decimal por ponto
            String limpo = s.trim().replaceAll("\\.", "").replace(",", ".");
            return new BigDecimal(limpo);
        } catch (NumberFormatException e) { return null; }
    }
}