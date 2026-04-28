package br.com.gw.frete;

import br.com.gw.Enums.StatusFrete;
import br.com.gw.Enums.TipoOcorrencia;
import br.com.gw.cliente.Cliente;
import br.com.gw.cliente.ClienteDAO;
import br.com.gw.motorista.Motorista;
import br.com.gw.motorista.MotoristaDAO;
import br.com.gw.nucleo.exception.NegocioException;
import br.com.gw.veiculos.Veiculo;
import br.com.gw.veiculos.VeiculoDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.logging.Logger;

/**
 * Controlador de fretes.
 *
 * Mapeamento de ações (parâmetro GET "acao"):
 *  (nenhuma)       → listagem paginada
 *  novo            → formulário de emissão em branco
 *  detalhe         → página de detalhe com histórico de ocorrências + botões de status
 *  emitir   (POST) → salva novo frete
 *  saida    (POST) → confirma saída
 *  transito (POST) → inicia trânsito
 *  entrega  (POST) → registra entrega
 *  naoEntrega(POST)→ registra não entrega
 *  cancelar (POST) → cancela o frete
 *  ocorrencia(POST)→ registra ocorrência avulsa
 */
@WebServlet("/fretes")
public class FreteControlador extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(FreteControlador.class.getName());

    private final FreteBO     bo         = new FreteBO();
    private final ClienteDAO  clienteDAO = new ClienteDAO();
    private final MotoristaDAO motoDAO   = new MotoristaDAO();
    private final VeiculoDAO  veicDAO    = new VeiculoDAO();

    /* =========================================================
       GET — listagem, formulários, detalhe
       ========================================================= */

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String acao = emptyToNull(req.getParameter("acao"));

        try {
            if (acao == null) {
                listar(req, resp);
            } else {
                switch (acao) {
                    case "novo":    formNovo(req, resp);    break;
                    case "detalhe": detalhe(req, resp);     break;
                    default:        listar(req, resp);
                }
            }
        } catch (NegocioException e) {
            tratarErro(req, resp, e.getMessage(), "/jsp/Frete/listarFretes.jsp");
        } catch (Exception e) {
            LOG.severe("Erro inesperado no GET /fretes: " + e.getMessage());
            tratarErro(req, resp, "Erro inesperado. Tente novamente.",
                       "/jsp/Frete/listarFretes.jsp");
        }
    }

    /* =========================================================
       POST — ações de estado
       ========================================================= */

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String acao    = emptyToNull(req.getParameter("acao"));
        String usuario = getUsuarioLogado(req);

        try {
            if (acao == null) {
                resp.sendRedirect(req.getContextPath() + "/fretes");
                return;
            }
            switch (acao) {
                case "emitir":     emitir(req, resp, usuario);      break;
                case "saida":      confirmarSaida(req, resp, usuario); break;
                case "transito":   iniciarTransito(req, resp, usuario); break;
                case "entrega":    registrarEntrega(req, resp, usuario); break;
                case "naoEntrega": registrarNaoEntrega(req, resp, usuario); break;
                case "cancelar":   cancelar(req, resp, usuario);    break;
                case "ocorrencia": ocorrencia(req, resp, usuario);  break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/fretes");
            }
        } catch (NegocioException e) {
            int idFrete = parsInt(req.getParameter("idFrete"));
            if (idFrete > 0) {
                req.setAttribute("erro", e.getMessage());
                detalheComErro(req, resp, idFrete);
            } else {
                req.setAttribute("erro", e.getMessage());
                // CORREÇÃO: montar o frete com os dados do request, não new Frete()
                req.setAttribute("frete", montarFreteDoRequest(req));
                try { carregarDadosFormulario(req); } catch (Exception ex) { /* ignora */ }
                req.getRequestDispatcher("/jsp/Frete/FormFrete.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            LOG.severe("Erro inesperado no POST /fretes acao=" + acao + ": " + e.getMessage());
            tratarErro(req, resp, "Erro inesperado. Tente novamente.",
                       "/jsp/Frete/listarFretes.jsp");
        }
    }

    /* =========================================================
       HANDLERS — GET
       ========================================================= */

    private void listar(HttpServletRequest req, HttpServletResponse resp)
            throws NegocioException, ServletException, IOException {

        String filtro       = emptyToNull(req.getParameter("filtro"));
        String statusFiltro = emptyToNull(req.getParameter("statusFiltro"));
        int pagina = Math.max(1, parsInt(req.getParameter("pagina")));

        List<Frete> fretes  = bo.listar(filtro, statusFiltro, pagina);
        int totalPaginas    = bo.totalPaginas(filtro, statusFiltro);

        req.setAttribute("fretes",        fretes);
        req.setAttribute("filtro",        filtro);
        req.setAttribute("statusFiltro",  statusFiltro);
        req.setAttribute("statusList",    StatusFrete.values());
        req.setAttribute("paginaAtual",   pagina);
        req.setAttribute("totalPaginas",  totalPaginas);
        req.getRequestDispatcher("/jsp/Frete/listarFretes.jsp").forward(req, resp);
    }

    private void formNovo(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            carregarDadosFormulario(req);
            req.setAttribute("frete", new Frete());
            req.getRequestDispatcher("/jsp/Frete/FormFrete.jsp").forward(req, resp);
        } catch (SQLException e) {
            LOG.severe("Erro ao carregar dados para formulário: " + e.getMessage());
            tratarErro(req, resp, "Erro ao carregar dados do formulário.",
                       "/jsp/Frete/listarFretes.jsp");
        }
    }

    private void detalhe(HttpServletRequest req, HttpServletResponse resp)
            throws NegocioException, ServletException, IOException {
        int id = parsInt(req.getParameter("id"));
        if (id == 0) {
            resp.sendRedirect(req.getContextPath() + "/fretes");
            return;
        }
        carregarDetalhe(req, id);
        req.getRequestDispatcher("/jsp/Frete/FreteDetalhe.jsp").forward(req, resp);
    }

    private void detalheComErro(HttpServletRequest req, HttpServletResponse resp, int idFrete)
            throws ServletException, IOException {
        try {
            carregarDetalhe(req, idFrete);
        } catch (NegocioException e) {
            req.setAttribute("erro", e.getMessage());
        }
        req.getRequestDispatcher("/jsp/Frete/FreteDetalhe.jsp").forward(req, resp);
    }

    private void carregarDetalhe(HttpServletRequest req, int idFrete)
            throws NegocioException, ServletException, IOException {
        Frete frete = bo.buscarPorId(idFrete);
        List<OcorrenciaFrete> ocorrencias = bo.listarOcorrencias(idFrete);
        req.setAttribute("frete",       frete);
        req.setAttribute("ocorrencias", ocorrencias);
        req.setAttribute("tiposOcorrencia", TipoOcorrencia.values());
        req.setAttribute("statusFrete", StatusFrete.values());
    }

    /* =========================================================
       HANDLERS — POST
       ========================================================= */

    private void emitir(HttpServletRequest req, HttpServletResponse resp, String usuario)
            throws NegocioException, ServletException, IOException {

        Frete f = montarFreteDoRequest(req);
        bo.emitir(f, usuario);

        req.getSession().setAttribute("sucesso",
            "Frete " + f.getNumero() + " emitido com sucesso!");
        resp.sendRedirect(req.getContextPath() + "/fretes?acao=detalhe&id=" + f.getId());
    }

    private void confirmarSaida(HttpServletRequest req, HttpServletResponse resp, String usuario)
            throws NegocioException, ServletException, IOException {

        int    idFrete       = parsInt(req.getParameter("idFrete"));
        String municipioSaida = req.getParameter("municipioSaida");
        String ufSaida        = req.getParameter("ufSaida");

        if (municipioSaida == null || municipioSaida.trim().isEmpty())
            throw new br.com.gw.nucleo.exception.CadastroException(
                "Informe o Município de Saída.");
        if (ufSaida == null || ufSaida.trim().isEmpty())
            throw new br.com.gw.nucleo.exception.CadastroException(
                "Informe a UF de Saída.");

        bo.confirmarSaida(idFrete, municipioSaida.trim(), ufSaida.trim().toUpperCase(), usuario);

        setarSucesso(req, "Saída confirmada com sucesso!");
        resp.sendRedirect(req.getContextPath() + "/fretes?acao=detalhe&id=" + idFrete);
    }

    private void iniciarTransito(HttpServletRequest req, HttpServletResponse resp, String usuario)
            throws NegocioException, ServletException, IOException {

        int    idFrete   = parsInt(req.getParameter("idFrete"));
        String municipio = req.getParameter("municipioAtual");
        String uf        = req.getParameter("ufAtual");

        bo.iniciarTransito(idFrete,
            municipio != null ? municipio.trim() : null,
            uf        != null ? uf.trim().toUpperCase() : null,
            usuario);

        setarSucesso(req, "Trânsito iniciado com sucesso!");
        resp.sendRedirect(req.getContextPath() + "/fretes?acao=detalhe&id=" + idFrete);
    }

    private void registrarEntrega(HttpServletRequest req, HttpServletResponse resp, String usuario)
            throws NegocioException, ServletException, IOException {

        int    idFrete   = parsInt(req.getParameter("idFrete"));
        String recebedor = req.getParameter("nomeRecebedor");
        String documento = req.getParameter("documentoRecebedor");
        String municipio = req.getParameter("municipioEntrega");
        String uf        = req.getParameter("ufEntrega");

        bo.registrarEntrega(idFrete, recebedor, documento,
            municipio != null ? municipio.trim() : null,
            uf        != null ? uf.trim().toUpperCase() : null,
            usuario);

        setarSucesso(req, "Entrega registrada com sucesso!");
        resp.sendRedirect(req.getContextPath() + "/fretes?acao=detalhe&id=" + idFrete);
    }

    private void registrarNaoEntrega(HttpServletRequest req, HttpServletResponse resp, String usuario)
            throws NegocioException, ServletException, IOException {

        int    idFrete   = parsInt(req.getParameter("idFrete"));
        String motivo    = req.getParameter("motivoNaoEntrega");
        String municipio = req.getParameter("municipioAtual");
        String uf        = req.getParameter("ufAtual");

        bo.registrarNaoEntrega(idFrete, motivo,
            municipio != null ? municipio.trim() : null,
            uf        != null ? uf.trim().toUpperCase() : null,
            usuario);

        setarSucesso(req, "Não entrega registrada.");
        resp.sendRedirect(req.getContextPath() + "/fretes?acao=detalhe&id=" + idFrete);
    }

    private void cancelar(HttpServletRequest req, HttpServletResponse resp, String usuario)
            throws NegocioException, ServletException, IOException {

        int    idFrete = parsInt(req.getParameter("idFrete"));
        String motivo  = req.getParameter("motivoCancelamento");

        bo.cancelar(idFrete, motivo, usuario);

        setarSucesso(req, "Frete cancelado.");
        resp.sendRedirect(req.getContextPath() + "/fretes?acao=detalhe&id=" + idFrete);
    }

    private void ocorrencia(HttpServletRequest req, HttpServletResponse resp, String usuario)
            throws NegocioException, ServletException, IOException {

        int idFrete = parsInt(req.getParameter("idFrete"));

        OcorrenciaFrete oc = new OcorrenciaFrete();
        oc.setIdFrete(idFrete);

        String tipoCod = req.getParameter("tipoOcorrencia");
        if (tipoCod != null && !tipoCod.isEmpty())
            oc.setTipo(TipoOcorrencia.fromCodigo(tipoCod));

        oc.setMunicipio  (emptyToNull(req.getParameter("municipio")));
        oc.setUf         (emptyToNull(req.getParameter("uf")));
        oc.setDescricao  (emptyToNull(req.getParameter("descricao")));
        oc.setNomeRecebedor     (emptyToNull(req.getParameter("nomeRecebedor")));
        oc.setDocumentoRecebedor(emptyToNull(req.getParameter("documentoRecebedor")));

        bo.registrarOcorrencia(oc, usuario);

        setarSucesso(req, "Ocorrência registrada com sucesso!");
        resp.sendRedirect(req.getContextPath() + "/fretes?acao=detalhe&id=" + idFrete);
    }

    /* =========================================================
       HELPERS
       ========================================================= */

    private Frete montarFreteDoRequest(HttpServletRequest req) {
        Frete f = new Frete();
        f.setIdRemetente  (parsInt(req.getParameter("idRemetente")));
        f.setIdDestinatario(parsInt(req.getParameter("idDestinatario")));
        f.setIdMotorista  (parsInt(req.getParameter("idMotorista")));
        f.setIdVeiculo    (parsInt(req.getParameter("idVeiculo")));
        f.setMunicipioOrigem (req.getParameter("municipioOrigem"));
        f.setUfOrigem        (toUpper(req.getParameter("ufOrigem")));
        f.setMunicipioDestino(req.getParameter("municipioDestino"));
        f.setUfDestino       (toUpper(req.getParameter("ufDestino")));
        f.setDescricaoCarga  (emptyToNull(req.getParameter("descricaoCarga")));
        f.setObservacao      (emptyToNull(req.getParameter("observacao")));
        f.setPesoKg          (parseBD(req.getParameter("pesoKg")));
        f.setVolumes         (parsIntNull(req.getParameter("volumes")));
        f.setValorFrete      (parseBDOrZero(req.getParameter("valorFrete")));
        f.setAliquotaIcms    (parseBDOrZero(req.getParameter("aliquotaIcms")));
        f.setAliquotaIbs     (parseBDOrZero(req.getParameter("aliquotaIbs")));
        f.setAliquotaCbs     (parseBDOrZero(req.getParameter("aliquotaCbs")));

        String dp = req.getParameter("dataPrevEntrega");
        if (dp != null && !dp.isEmpty()) {
            try { f.setDataPrevEntrega(LocalDate.parse(dp)); }
            catch (DateTimeParseException ignored) {}
        }
        return f;
    }

    private void carregarDadosFormulario(HttpServletRequest req) throws SQLException {
        List<Cliente>   clientes   = clienteDAO.listarAtivos();
        List<Motorista> motoristas = motoDAO.listarAtivos();
        List<Veiculo>   veiculos   = veicDAO.listarDisponiveis(null, 1, 10); // Adjust arguments as needed
        req.setAttribute("clientes",   clientes);
        req.setAttribute("motoristas", motoristas);
        req.setAttribute("veiculos",   veiculos);
    }

    private void tratarErro(HttpServletRequest req, HttpServletResponse resp,
                             String msg, String jspPath)
            throws ServletException, IOException {
        req.setAttribute("erro", msg);
        req.getRequestDispatcher(jspPath).forward(req, resp);
    }

    private void setarSucesso(HttpServletRequest req, String msg) {
        req.getSession().setAttribute("sucesso", msg);
    }

    private String getUsuarioLogado(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return "sistema";
        Object u = session.getAttribute("usuarioLogado");
        return u != null ? u.toString() : "sistema";
    }

    private int parsInt(String v) {
        if (v == null || v.trim().isEmpty()) return 0;
        try { return Integer.parseInt(v.trim()); }
        catch (NumberFormatException e) { return 0; }
    }

    private Integer parsIntNull(String v) {
        if (v == null || v.trim().isEmpty()) return null;
        try { return Integer.parseInt(v.trim()); }
        catch (NumberFormatException e) { return null; }
    }

    private BigDecimal parseBD(String v) {
        if (v == null || v.trim().isEmpty()) return null;
        try { return new BigDecimal(v.trim().replace(",", ".")); }
        catch (NumberFormatException e) { return null; }
    }

    private BigDecimal parseBDOrZero(String v) {
        BigDecimal bd = parseBD(v);
        return bd != null ? bd : BigDecimal.ZERO;
    }

    private String emptyToNull(String v) {
        return (v != null && !v.trim().isEmpty()) ? v.trim() : null;
    }

    private String toUpper(String v) {
        return v != null ? v.trim().toUpperCase() : null;
    }
}