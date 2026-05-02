package br.com.gw.relatorio;

import br.com.gw.nucleo.exception.CadastroException;
import br.com.gw.nucleo.exception.NegocioException;
import br.com.gw.nucleo.login.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller da área de relatórios.
 * Recebe filtros da tela, chama o BO e devolve PDFs JasperReports para visualização/impressão.
 */
@WebServlet("/relatorios")
public class RelatorioControlador extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(RelatorioControlador.class.getName());

    private final RelatorioBO bo = new RelatorioBO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String acao = emptyToNull(req.getParameter("acao"));

        try {
            if (acao == null) {
                catalogo(req, resp);
                return;
            }

            switch (acao) {
                case "fretesAbertos":
                    gerarFretesAbertos(req, resp);
                    break;
                case "romaneioCarga":
                    gerarRomaneio(req, resp);
                    break;
                case "documentoFrete":
                    gerarDocumentoFrete(req, resp);
                    break;
                case "fretesCliente":
                    gerarFretesCliente(req, resp);
                    break;
                case "ocorrenciasPeriodo":
                    gerarOcorrenciasPeriodo(req, resp);
                    break;
                case "desempenhoMotoristas":
                    gerarDesempenhoMotoristas(req, resp);
                    break;
                default:
                    catalogo(req, resp);
                    break;
            }
        } catch (NegocioException e) {
            tratarErro(req, resp, e.getMessage());
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "Erro inesperado em /relatorios.", e);
            tratarErro(req, resp, "Erro inesperado ao gerar relatório. Tente novamente.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        doGet(req, resp);
    }

    private void catalogo(HttpServletRequest req, HttpServletResponse resp)
            throws NegocioException, ServletException, IOException {
        prepararCatalogo(req);
        req.getRequestDispatcher("/jsp/relatorios/relatorios.jsp").forward(req, resp);
    }

    private void gerarFretesAbertos(HttpServletRequest req, HttpServletResponse resp)
            throws NegocioException, IOException {
        byte[] pdf = bo.gerarFretesEmAberto(getUsuarioLogado(req));
        enviarPdf(resp, pdf, "fretes-em-aberto.pdf");
    }

    private void gerarRomaneio(HttpServletRequest req, HttpServletResponse resp)
            throws NegocioException, IOException {
        int idMotorista = parsInt(req.getParameter("idMotorista"));
        LocalDate data = parseData(req.getParameter("dataRomaneio"));

        byte[] pdf = bo.gerarRomaneio(idMotorista, data, getUsuarioLogado(req));
        enviarPdf(resp, pdf, "romaneio-carga-" + data + ".pdf");
    }

    private void gerarDocumentoFrete(HttpServletRequest req, HttpServletResponse resp)
            throws NegocioException, IOException {
        int idFrete = parsInt(req.getParameter("idFrete"));

        byte[] pdf = bo.gerarDocumentoFrete(idFrete, getUsuarioLogado(req));
        enviarPdf(resp, pdf, "documento-frete-" + idFrete + ".pdf");
    }

    private void gerarFretesCliente(HttpServletRequest req, HttpServletResponse resp)
            throws NegocioException, IOException {
        int idCliente = parsInt(req.getParameter("idCliente"));
        LocalDate dataInicio = parseData(req.getParameter("dataInicio"));
        LocalDate dataFim = parseData(req.getParameter("dataFim"));

        byte[] pdf = bo.gerarFretesPorCliente(
            idCliente, dataInicio, dataFim, getUsuarioLogado(req));
        enviarPdf(resp, pdf, "fretes-cliente-" + idCliente + ".pdf");
    }

    private void gerarOcorrenciasPeriodo(HttpServletRequest req, HttpServletResponse resp)
            throws NegocioException, IOException {
        LocalDate dataInicio = parseData(req.getParameter("dataInicio"));
        LocalDate dataFim = parseData(req.getParameter("dataFim"));

        byte[] pdf = bo.gerarOcorrenciasPorPeriodo(
            dataInicio, dataFim, getUsuarioLogado(req));
        enviarPdf(resp, pdf, "ocorrencias-" + dataInicio + "-" + dataFim + ".pdf");
    }

    private void gerarDesempenhoMotoristas(HttpServletRequest req, HttpServletResponse resp)
            throws NegocioException, IOException {
        LocalDate dataInicio = parseData(req.getParameter("dataInicio"));
        LocalDate dataFim = parseData(req.getParameter("dataFim"));

        byte[] pdf = bo.gerarDesempenhoMotoristas(
            dataInicio, dataFim, getUsuarioLogado(req));
        enviarPdf(resp, pdf, "desempenho-motoristas-" + dataInicio + "-" + dataFim + ".pdf");
    }

    private void prepararCatalogo(HttpServletRequest req) throws NegocioException {
        req.setAttribute("clientes", bo.listarClientesParaFiltro());
        req.setAttribute("motoristas", bo.listarMotoristasParaFiltro());
        req.setAttribute("fretesRelatorio", bo.listarFretesParaFiltro());
        req.setAttribute("dataHoje", LocalDate.now().toString());
    }

    private void tratarErro(HttpServletRequest req, HttpServletResponse resp, String mensagem)
            throws ServletException, IOException {
        req.setAttribute("erro", mensagem);
        try {
            prepararCatalogo(req);
        } catch (NegocioException e) {
            LOG.log(Level.SEVERE, "Erro ao recarregar catálogo de relatórios.", e);
            req.setAttribute("erro", mensagem + " Também não foi possível recarregar os filtros.");
        }
        req.getRequestDispatcher("/jsp/relatorios/relatorios.jsp").forward(req, resp);
    }

    private void enviarPdf(HttpServletResponse resp, byte[] pdf, String nomeArquivo)
            throws IOException {
        resp.reset();
        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition", "inline; filename=\"" + nomeArquivo + "\"");
        resp.setContentLength(pdf.length);
        resp.getOutputStream().write(pdf);
        resp.getOutputStream().flush();
    }

    private String getUsuarioLogado(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return "sistema";

        Object usuario = session.getAttribute("usuarioLogado");
        if (usuario instanceof Usuario) {
            Usuario u = (Usuario) usuario;
            return u.getNome() != null ? u.getNome() : u.getLogin();
        }
        return usuario != null ? String.valueOf(usuario) : "sistema";
    }

    private LocalDate parseData(String valor) throws CadastroException {
        if (valor == null || valor.trim().isEmpty()) {
            return null;
        }
        try {
            return LocalDate.parse(valor.trim());
        } catch (DateTimeParseException e) {
            throw new CadastroException("Data informada inválida. Use o formato AAAA-MM-DD.");
        }
    }

    private int parsInt(String valor) {
        if (valor == null || valor.trim().isEmpty()) return 0;
        try {
            return Integer.parseInt(valor.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String emptyToNull(String valor) {
        return valor != null && !valor.trim().isEmpty() ? valor.trim() : null;
    }
}
