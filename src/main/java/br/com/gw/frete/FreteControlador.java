package br.com.gw.frete;

import br.com.gw.Enums.StatusFrete;
import br.com.gw.Enums.TipoOcorrencia;
import br.com.gw.cliente.Cliente;
import br.com.gw.cliente.ClienteDAO;
import br.com.gw.motorfiscal.TaxSimulationResponse;
import br.com.gw.motorista.Motorista;
import br.com.gw.motorista.MotoristaDAO;
import br.com.gw.nucleo.exception.CadastroException;
import br.com.gw.nucleo.exception.NegocioException;
import br.com.gw.veiculos.Veiculo;
import br.com.gw.veiculos.VeiculoDAO;
import com.google.gson.Gson;

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
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controlador de fretes.
 *
 * Mapeamento de ações (parâmetro GET "acao"):
 *  (nenhuma)        → listagem paginada
 *  novo             → formulário de emissão em branco
 *  detalhe          → página de detalhe com histórico de ocorrências + botões de status
 *  emitir   (POST)  → salva novo frete
 *  saida    (POST)  → confirma saída
 *  transito (POST)  → inicia trânsito
 *  entrega  (POST)  → registra entrega
 *  naoEntrega(POST) → registra não entrega
 *  cancelar (POST)  → cancela o frete
 *  ocorrencia(POST) → registra ocorrência avulsa
 *  previewFiscal(POST) → calcula uma prévia fiscal sem salvar frete
 *  calcularFiscal(POST) → calcula impostos no Motor Fiscal
 */
@WebServlet("/fretes")
public class FreteControlador extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(FreteControlador.class.getName());
    private static final int HTTP_UNPROCESSABLE_ENTITY = 422;

    /** Limite máximo de registros para os selects do formulário. */
    private static final int LIMITE_SELECT = 500;

    private final FreteBO      bo         = new FreteBO();
    private final ClienteDAO   clienteDAO = new ClienteDAO();
    private final MotoristaDAO motoDAO    = new MotoristaDAO();
    private final VeiculoDAO   veicDAO    = new VeiculoDAO();
    private final Gson         gson       = new Gson();

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
                    case "novo":    formNovo(req, resp);  break;
                    case "detalhe": detalhe(req, resp);   break;
                    default:        listar(req, resp);
                }
            }
        } catch (NegocioException e) {
            tratarErro(req, resp, e.getMessage(), "/jsp/Frete/listarFretes.jsp");
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "Erro inesperado no GET /fretes.", e);
            tratarErro(req, resp, mensagemErroInesperado(e), "/jsp/Frete/listarFretes.jsp");
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
                case "emitir":     emitir(req, resp, usuario);           break;
                case "saida":      confirmarSaida(req, resp, usuario);   break;
                case "transito":   iniciarTransito(req, resp, usuario);  break;
                case "entrega":    registrarEntrega(req, resp, usuario); break;
                case "naoEntrega": registrarNaoEntrega(req, resp, usuario); break;
                case "cancelar":   cancelar(req, resp, usuario);         break;
                case "ocorrencia": ocorrencia(req, resp, usuario);       break;
                case "previewFiscal": previewFiscal(req, resp);          break;
                case "calcularFiscal": calcularFiscal(req, resp, usuario); break;
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
                // Repopula o frete com os dados digitados — evita retrabalho do usuário
                req.setAttribute("frete", montarFreteDoRequest(req));
                try { carregarDadosFormulario(req); } catch (Exception ex) {
                    LOG.severe("Erro ao recarregar formulário: " + ex.getMessage());
                }
                req.getRequestDispatcher("/jsp/Frete/FormFrete.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "Erro inesperado no POST /fretes acao=" + acao + ".", e);
            tratarErro(req, resp, mensagemErroInesperado(e), "/jsp/Frete/listarFretes.jsp");
        }
    }

    /* =========================================================
       HANDLERS — GET
       ========================================================= */

    private void listar(HttpServletRequest req, HttpServletResponse resp)
            throws NegocioException, ServletException, IOException {

        String filtro       = emptyToNull(req.getParameter("filtro"));
        String statusFiltro = normalizarStatusFiltro(req.getParameter("statusFiltro"));
        int pagina = Math.max(1, parsInt(req.getParameter("pagina")));

        List<Frete> fretes = bo.listar(filtro, statusFiltro, pagina);
        int totalPaginas   = bo.totalPaginas(filtro, statusFiltro);

        req.setAttribute("fretes",       fretes);
        req.setAttribute("filtro",       filtro);
        req.setAttribute("statusFiltro", statusFiltro);
        req.setAttribute("statusList",   StatusFrete.values());
        req.setAttribute("paginaAtual",  pagina);
        req.setAttribute("totalPaginas", totalPaginas);
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
        req.setAttribute("frete",           frete);
        req.setAttribute("ocorrencias",     ocorrencias);
        req.setAttribute("tiposOcorrencia", TipoOcorrencia.values());
        req.setAttribute("statusFrete",     StatusFrete.values());
    }

    /* =========================================================
       HANDLERS — POST
       ========================================================= */

    private void emitir(HttpServletRequest req, HttpServletResponse resp, String usuario)
            throws NegocioException, ServletException, IOException {

        Frete f = montarFreteDoRequest(req);
        bo.emitir(f, usuario);

        setarSucesso(req, "Frete " + f.getNumero() + " emitido com sucesso! "
            + "Rota: " + f.getRota());
        resp.sendRedirect(req.getContextPath() + "/fretes?acao=detalhe&id=" + f.getId());
    }

    private void previewFiscal(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        try {
            Frete frete = montarFreteDoRequest(req);
            TaxSimulationResponse response = bo.previsualizarFiscal(frete);
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write(gson.toJson(response));
        } catch (NegocioException e) {
            resp.setStatus(HTTP_UNPROCESSABLE_ENTITY);
            Map<String, Object> error = new LinkedHashMap<>();
            error.put("code", "FISCAL_PREVIEW_ERROR");
            error.put("message", e.getMessage());
            resp.getWriter().write(gson.toJson(error));
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "Erro inesperado no preview fiscal.", e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            Map<String, Object> error = new LinkedHashMap<>();
            error.put("code", "INTERNAL_ERROR");
            error.put("message", "Erro inesperado ao calcular prévia fiscal.");
            resp.getWriter().write(gson.toJson(error));
        }
    }

    private void calcularFiscal(HttpServletRequest req, HttpServletResponse resp, String usuario)
            throws NegocioException, ServletException, IOException {

        int idFrete = parsInt(req.getParameter("idFrete"));
        if (idFrete <= 0) {
            throw new CadastroException("Frete inválido para cálculo fiscal.");
        }

        bo.calcularFiscal(idFrete, usuario);

        setarSucesso(req, "Resumo fiscal calculado pelo Motor Fiscal.");
        resp.sendRedirect(req.getContextPath() + "/fretes?acao=detalhe&id=" + idFrete);
    }

    private void confirmarSaida(HttpServletRequest req, HttpServletResponse resp, String usuario)
            throws NegocioException, ServletException, IOException {

        int    idFrete        = parsInt(req.getParameter("idFrete"));
        String municipioSaida = emptyToNull(req.getParameter("municipioSaida"));
        String ufSaida        = emptyToNull(req.getParameter("ufSaida"));

        if (municipioSaida == null)
            throw new CadastroException("Informe o Município de Saída.");
        if (ufSaida == null)
            throw new CadastroException("Informe a UF de Saída.");

        bo.confirmarSaida(idFrete, municipioSaida, ufSaida.toUpperCase(), usuario);

        setarSucesso(req, "Saída confirmada com sucesso!");
        resp.sendRedirect(req.getContextPath() + "/fretes?acao=detalhe&id=" + idFrete);
    }

    private void iniciarTransito(HttpServletRequest req, HttpServletResponse resp, String usuario)
            throws NegocioException, ServletException, IOException {

        int    idFrete   = parsInt(req.getParameter("idFrete"));
        String municipio = emptyToNull(req.getParameter("municipioAtual"));
        String uf        = emptyToNull(req.getParameter("ufAtual"));

        bo.iniciarTransito(idFrete,
            municipio,
            uf != null ? uf.toUpperCase() : null,
            usuario);

        setarSucesso(req, "Trânsito iniciado com sucesso!");
        resp.sendRedirect(req.getContextPath() + "/fretes?acao=detalhe&id=" + idFrete);
    }

    private void registrarEntrega(HttpServletRequest req, HttpServletResponse resp, String usuario)
            throws NegocioException, ServletException, IOException {

        int    idFrete   = parsInt(req.getParameter("idFrete"));
        String recebedor = emptyToNull(req.getParameter("nomeRecebedor"));
        String documento = emptyToNull(req.getParameter("documentoRecebedor"));
        String municipio = emptyToNull(req.getParameter("municipioEntrega"));
        String uf        = emptyToNull(req.getParameter("ufEntrega"));

        bo.registrarEntrega(idFrete, recebedor, documento,
            municipio,
            uf != null ? uf.toUpperCase() : null,
            usuario);

        setarSucesso(req, "Entrega registrada com sucesso!");
        resp.sendRedirect(req.getContextPath() + "/fretes?acao=detalhe&id=" + idFrete);
    }

    private void registrarNaoEntrega(HttpServletRequest req, HttpServletResponse resp, String usuario)
            throws NegocioException, ServletException, IOException {

        int    idFrete   = parsInt(req.getParameter("idFrete"));
        String motivo    = emptyToNull(req.getParameter("motivoNaoEntrega"));
        String municipio = emptyToNull(req.getParameter("municipioAtual"));
        String uf        = emptyToNull(req.getParameter("ufAtual"));

        bo.registrarNaoEntrega(idFrete, motivo,
            municipio,
            uf != null ? uf.toUpperCase() : null,
            usuario);

        setarSucesso(req, "Não entrega registrada.");
        resp.sendRedirect(req.getContextPath() + "/fretes?acao=detalhe&id=" + idFrete);
    }

    private void cancelar(HttpServletRequest req, HttpServletResponse resp, String usuario)
            throws NegocioException, ServletException, IOException {

        int    idFrete = parsInt(req.getParameter("idFrete"));
        String motivo  = emptyToNull(req.getParameter("motivoCancelamento"));

        bo.cancelar(idFrete, motivo, usuario);

        setarSucesso(req, "Frete cancelado.");
        resp.sendRedirect(req.getContextPath() + "/fretes?acao=detalhe&id=" + idFrete);
    }

    private void ocorrencia(HttpServletRequest req, HttpServletResponse resp, String usuario)
            throws NegocioException, ServletException, IOException {

        int idFrete = parsInt(req.getParameter("idFrete"));

        OcorrenciaFrete oc = new OcorrenciaFrete();
        oc.setIdFrete(idFrete);

        String tipoCod = emptyToNull(req.getParameter("tipoOcorrencia"));
        if (tipoCod != null) {
            try {
                oc.setTipo(TipoOcorrencia.fromCodigo(tipoCod));
            } catch (IllegalArgumentException e) {
                throw new CadastroException("Tipo de ocorrência inválido. Selecione uma opção da lista.");
            }
        }

        oc.setMunicipio          (emptyToNull(req.getParameter("municipio")));
        String ufOc = emptyToNull(req.getParameter("uf"));
        oc.setUf                 (ufOc != null ? ufOc.toUpperCase() : null);
        oc.setDescricao          (emptyToNull(req.getParameter("descricao")));
        oc.setNomeRecebedor      (emptyToNull(req.getParameter("nomeRecebedor")));
        oc.setDocumentoRecebedor (emptyToNull(req.getParameter("documentoRecebedor")));

        bo.registrarOcorrencia(oc, usuario);

        setarSucesso(req, "Ocorrência registrada com sucesso!");
        resp.sendRedirect(req.getContextPath() + "/fretes?acao=detalhe&id=" + idFrete);
    }

    /* =========================================================
       HELPERS
       ========================================================= */

    private Frete montarFreteDoRequest(HttpServletRequest req) {
        Frete f = new Frete();
        f.setIdRemetente   (parsInt(req.getParameter("idRemetente")));
        f.setIdDestinatario(parsInt(req.getParameter("idDestinatario")));
        f.setIdMotorista   (parsInt(req.getParameter("idMotorista")));
        f.setIdVeiculo     (parsInt(req.getParameter("idVeiculo")));

        f.setMunicipioOrigem (emptyToNull(req.getParameter("municipioOrigem")));
        f.setUfOrigem        (toUpper(req.getParameter("ufOrigem")));
        f.setMunicipioDestino(emptyToNull(req.getParameter("municipioDestino")));
        f.setUfDestino       (toUpper(req.getParameter("ufDestino")));
        f.setDescricaoCarga  (emptyToNull(req.getParameter("descricaoCarga")));
        f.setObservacao      (emptyToNull(req.getParameter("observacao")));
        f.setPesoKg          (parseBD(req.getParameter("pesoKg")));
        f.setVolumes         (parsIntNull(req.getParameter("volumes")));
        f.setValorFrete      (parseBDOrZero(req.getParameter("valorFrete")));

        String dp = req.getParameter("dataPrevEntrega");
        f.setDataPrevEntrega(parseLocalDate(dp));

        return f;
    }

    private void carregarDadosFormulario(HttpServletRequest req) throws SQLException {
        List<Cliente>   clientes   = clienteDAO.listarAtivos();
        List<Motorista> motoristas = motoDAO.listarDisponiveisParaFrete();
        List<Veiculo>   veiculos   = veicDAO.listarDisponiveis(null, 1, LIMITE_SELECT);
        req.setAttribute("clientes",   clientes);
        req.setAttribute("motoristas", motoristas);
        req.setAttribute("veiculos",   veiculos);
        if (motoristas.isEmpty()) {
            req.setAttribute("avisoMotoristas",
                "Nenhum motorista está disponível para novo frete no momento. "
              + "Verifique se há fretes em aberto, CNHs vencidas ou motoristas suspensos.");
        }
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

    /* ---- parsers ---- */

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

    /** Aceita números em formato brasileiro ou decimal técnico. */
    private BigDecimal parseBD(String v) {
        if (v == null || v.trim().isEmpty()) return null;
        try {
            String s = v.trim();
            s = s.replace("R$", "")
                 .replace("kg", "")
                 .replace("%", "")
                 .replaceAll("[^0-9,\\.\\-]", "");
            if (s.contains(",")) {
                // Formato brasileiro: remove pontos de milhar, troca vírgula decimal por ponto
                s = s.replace(".", "").replace(",", ".");
            } else if (s.matches("\\d{1,3}(\\.\\d{3})+")) {
                // "15.000" sem casas decimais deve ser 15000, não 15.000
                s = s.replace(".", "");
            }
            return new BigDecimal(s);
        } catch (NumberFormatException e) {
            LOG.fine("Valor numérico inválido ignorado: '" + v + "'");
            return null;
        }
    }

    private BigDecimal parseBDOrZero(String v) {
        BigDecimal bd = parseBD(v);
        return bd != null ? bd : BigDecimal.ZERO;
    }

    /** Aceita datas em yyyy-MM-dd ou dd/MM/yyyy; o BO valida a obrigatoriedade. */
    private LocalDate parseLocalDate(String v) {
        if (v == null || v.trim().isEmpty()) return null;
        String s = v.trim();
        // Formato padrão do input type="date" no HTML
        try { return LocalDate.parse(s, DateTimeFormatter.ISO_LOCAL_DATE); }
        catch (DateTimeParseException ignored) {}
        // Formato brasileiro digitado manualmente
        try { return LocalDate.parse(s, DateTimeFormatter.ofPattern("dd/MM/yyyy")); }
        catch (DateTimeParseException ignored) {}
        LOG.warning("Data em formato não reconhecido ignorada: '" + v + "'");
        return null;
    }

    private String emptyToNull(String v) {
        return (v != null && !v.trim().isEmpty()) ? v.trim() : null;
    }

    private String toUpper(String v) {
        String s = emptyToNull(v);
        return s != null ? s.toUpperCase() : null;
    }

    private String normalizarStatusFiltro(String valor) {
        String s = emptyToNull(valor);
        if (s == null || "TODOS".equalsIgnoreCase(s)) return null;

        try {
            if (s.length() == 1) {
                return String.valueOf(StatusFrete.fromCodigo(s).getCodigo());
            }
            return String.valueOf(StatusFrete.valueOf(s.toUpperCase()).getCodigo());
        } catch (IllegalArgumentException e) {
            LOG.warning("Filtro de status inválido ignorado: " + valor);
            return null;
        }
    }

    private String mensagemErroInesperado(Exception e) {
        return "Erro inesperado. Tente novamente.";
    }
}
