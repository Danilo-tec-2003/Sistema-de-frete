package br.com.gw.relatorio;

import br.com.gw.cliente.Cliente;
import br.com.gw.cliente.ClienteDAO;
import br.com.gw.motorista.Motorista;
import br.com.gw.motorista.MotoristaDAO;
import br.com.gw.nucleo.exception.CadastroException;
import br.com.gw.nucleo.exception.NegocioException;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JasperCompileManager;
import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.JasperReport;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Regras de negócio da etapa de relatórios.
 * Valida filtros, calcula totais e gera PDFs a partir dos templates JasperReports.
 */
public class RelatorioBO {

    private static final Logger LOG = Logger.getLogger(RelatorioBO.class.getName());
    private static final int LIMITE_SELECT_FRETES = 200;
    private static final int LIMITE_SELECT_MOTORISTAS = 500;
    private static final int LIMITE_SELECT_CLIENTES = 500;

    private static final DateTimeFormatter FMT_DATA =
        DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter FMT_DATA_HORA =
        DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final RelatorioDAO dao = new RelatorioDAO();
    private final ClienteDAO clienteDAO = new ClienteDAO();
    private final MotoristaDAO motoristaDAO = new MotoristaDAO();

    public byte[] gerarFretesEmAberto(String usuario) throws NegocioException {
        try {
            List<FreteAbertoRelatorio> fretes = dao.listarFretesEmAberto();

            Map<String, Object> params = parametrosBase(usuario);
            params.put("TITULO", "Fretes em aberto");
            params.put("SUBTITULO", "Fretes emitidos, com saida confirmada ou em transito");
            params.put("TOTAL_REGISTROS", fretes.size());

            return gerarPdf("fretes_abertos.jrxml", fretes, params);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Erro ao consultar fretes em aberto para relatório.", e);
            throw new NegocioException("Erro ao gerar relatório de fretes em aberto.", e);
        }
    }

    public byte[] gerarRomaneio(int idMotorista, LocalDate dataOperacao, String usuario)
            throws NegocioException {
        validarRomaneio(idMotorista, dataOperacao);

        try {
            RomaneioCabecalho cabecalho = dao.buscarCabecalhoRomaneio(idMotorista, dataOperacao);
            if (cabecalho == null) {
                throw new CadastroException("Motorista não encontrado para gerar o romaneio.");
            }

            List<RomaneioCargaRelatorio> linhas = dao.listarRomaneio(idMotorista, dataOperacao);
            BigDecimal totalPeso = BigDecimal.ZERO;
            int totalVolumes = 0;
            BigDecimal totalValor = BigDecimal.ZERO;

            for (RomaneioCargaRelatorio linha : linhas) {
                if (linha.getPesoKg() != null) {
                    totalPeso = totalPeso.add(linha.getPesoKg());
                }
                if (linha.getVolumes() != null) {
                    totalVolumes += linha.getVolumes();
                }
                if (linha.getValorTotal() != null) {
                    totalValor = totalValor.add(linha.getValorTotal());
                }
            }

            Map<String, Object> params = parametrosBase(usuario);
            params.put("TITULO", "Romaneio de carga");
            params.put("MOTORISTA_NOME", cabecalho.getMotoristaNome());
            params.put("MOTORISTA_CPF", cabecalho.getMotoristaCpf());
            params.put("MOTORISTA_CNH", cabecalho.getMotoristaCnh());
            params.put("VEICULO_PLACAS", cabecalho.getVeiculoPlacas());
            params.put("DATA_ROMANEIO", dataOperacao.format(FMT_DATA));
            params.put("TOTAL_FRETES", linhas.size());
            params.put("TOTAL_PESO", totalPeso);
            params.put("TOTAL_VOLUMES", totalVolumes);
            params.put("TOTAL_VALOR", totalValor);

            return gerarPdf("romaneio_carga.jrxml", linhas, params);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Erro ao consultar dados do romaneio.", e);
            throw new NegocioException("Erro ao gerar romaneio de carga.", e);
        }
    }

    public byte[] gerarDocumentoFrete(int idFrete, String usuario) throws NegocioException {
        if (idFrete <= 0) {
            throw new CadastroException("Selecione um frete para gerar o documento.");
        }

        try {
            DocumentoFreteRelatorio documento = dao.buscarDocumentoFrete(idFrete);
            if (documento == null) {
                throw new CadastroException("Frete não encontrado para gerar o documento.");
            }

            Map<String, Object> params = parametrosBase(usuario);
            params.put("TITULO", "Documento de frete");

            return gerarPdf(
                "documento_frete.jrxml",
                Collections.singletonList(documento),
                params);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Erro ao consultar documento de frete.", e);
            throw new NegocioException("Erro ao gerar documento do frete.", e);
        }
    }

    public byte[] gerarFretesPorCliente(int idCliente, LocalDate dataInicio,
            LocalDate dataFim, String usuario) throws NegocioException {
        validarClientePeriodo(idCliente, dataInicio, dataFim);

        try {
            Cliente cliente = clienteDAO.buscarPorId(idCliente);
            if (cliente == null) {
                throw new CadastroException("Cliente não encontrado para gerar o relatório.");
            }

            List<FreteClienteRelatorio> fretes =
                dao.listarFretesPorCliente(idCliente, dataInicio, dataFim);

            BigDecimal totalValor = BigDecimal.ZERO;
            for (FreteClienteRelatorio linha : fretes) {
                if (linha.getValorTotal() != null) {
                    totalValor = totalValor.add(linha.getValorTotal());
                }
            }

            Map<String, Object> params = parametrosBase(usuario);
            params.put("TITULO", "Fretes por cliente");
            params.put("CLIENTE_NOME", cliente.getRazaoSocial());
            params.put("PERIODO", periodo(dataInicio, dataFim));
            params.put("TOTAL_FRETES", fretes.size());
            params.put("TOTAL_VALOR", totalValor);

            return gerarPdf("fretes_cliente.jrxml", fretes, params);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Erro ao consultar fretes por cliente.", e);
            throw new NegocioException("Erro ao gerar relatório de fretes por cliente.", e);
        }
    }

    public byte[] gerarOcorrenciasPorPeriodo(LocalDate dataInicio, LocalDate dataFim,
            String usuario) throws NegocioException {
        validarPeriodo(dataInicio, dataFim);

        try {
            List<OcorrenciaPeriodoRelatorio> ocorrencias =
                dao.listarOcorrenciasPorPeriodo(dataInicio, dataFim);

            Map<String, Object> params = parametrosBase(usuario);
            params.put("TITULO", "Ocorrências por período");
            params.put("PERIODO", periodo(dataInicio, dataFim));
            params.put("TOTAL_OCORRENCIAS", ocorrencias.size());

            return gerarPdf("ocorrencias_periodo.jrxml", ocorrencias, params);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Erro ao consultar ocorrências por período.", e);
            throw new NegocioException("Erro ao gerar relatório de ocorrências.", e);
        }
    }

    public byte[] gerarDesempenhoMotoristas(LocalDate dataInicio, LocalDate dataFim,
            String usuario) throws NegocioException {
        validarPeriodo(dataInicio, dataFim);

        try {
            List<DesempenhoMotoristaRelatorio> linhas =
                dao.listarDesempenhoMotoristas(dataInicio, dataFim);

            int totalEntregas = 0;
            int totalNoPrazo = 0;
            BigDecimal totalValor = BigDecimal.ZERO;

            for (DesempenhoMotoristaRelatorio linha : linhas) {
                if (linha.getEntregas() != null) {
                    totalEntregas += linha.getEntregas();
                }
                if (linha.getEntregasNoPrazo() != null) {
                    totalNoPrazo += linha.getEntregasNoPrazo();
                }
                if (linha.getValorTotal() != null) {
                    totalValor = totalValor.add(linha.getValorTotal());
                }
            }

            Map<String, Object> params = parametrosBase(usuario);
            params.put("TITULO", "Desempenho de motoristas");
            params.put("PERIODO", periodo(dataInicio, dataFim));
            params.put("TOTAL_ENTREGAS", totalEntregas);
            params.put("TOTAL_NO_PRAZO", totalNoPrazo);
            params.put("TOTAL_VALOR", totalValor);

            return gerarPdf("desempenho_motoristas.jrxml", linhas, params);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Erro ao consultar desempenho de motoristas.", e);
            throw new NegocioException("Erro ao gerar relatório de desempenho de motoristas.", e);
        }
    }

    public List<Motorista> listarMotoristasParaFiltro() throws NegocioException {
        try {
            return motoristaDAO.listar(null, 1, LIMITE_SELECT_MOTORISTAS);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Erro ao listar motoristas para relatórios.", e);
            throw new NegocioException("Erro ao carregar motoristas dos relatórios.", e);
        }
    }

    public List<Cliente> listarClientesParaFiltro() throws NegocioException {
        try {
            return clienteDAO.listar(null, 1, LIMITE_SELECT_CLIENTES);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Erro ao listar clientes para relatórios.", e);
            throw new NegocioException("Erro ao carregar clientes dos relatórios.", e);
        }
    }

    public List<RelatorioFreteOpcao> listarFretesParaFiltro() throws NegocioException {
        try {
            return dao.listarFretesParaSelecao(LIMITE_SELECT_FRETES);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Erro ao listar fretes para relatórios.", e);
            throw new NegocioException("Erro ao carregar fretes dos relatórios.", e);
        }
    }

    private void validarRomaneio(int idMotorista, LocalDate dataOperacao)
            throws CadastroException {
        if (idMotorista <= 0) {
            throw new CadastroException("Selecione o motorista do romaneio.");
        }
        if (dataOperacao == null) {
            throw new CadastroException("Informe a data do romaneio.");
        }
    }

    private void validarClientePeriodo(int idCliente, LocalDate dataInicio,
            LocalDate dataFim) throws CadastroException {
        if (idCliente <= 0) {
            throw new CadastroException("Selecione o cliente do relatório.");
        }
        validarPeriodo(dataInicio, dataFim);
    }

    private void validarPeriodo(LocalDate dataInicio, LocalDate dataFim)
            throws CadastroException {
        if (dataInicio == null) {
            throw new CadastroException("Informe a data inicial do período.");
        }
        if (dataFim == null) {
            throw new CadastroException("Informe a data final do período.");
        }
        if (dataInicio.isAfter(dataFim)) {
            throw new CadastroException("A data inicial não pode ser posterior à data final.");
        }
    }

    private String periodo(LocalDate dataInicio, LocalDate dataFim) {
        return dataInicio.format(FMT_DATA) + " a " + dataFim.format(FMT_DATA);
    }

    private Map<String, Object> parametrosBase(String usuario) {
        Map<String, Object> params = new HashMap<>();
        params.put("DATA_GERACAO", LocalDateTime.now().format(FMT_DATA_HORA));
        params.put("USUARIO", usuario == null || usuario.trim().isEmpty() ? "sistema" : usuario);
        return params;
    }

    /**
     * Compila o JRXML em runtime para facilitar correções do template durante o desenvolvimento.
     * Em produção, os .jasper poderiam ser pré-compilados para ganhar desempenho.
     */
    private byte[] gerarPdf(String arquivoJrxml, Collection<?> dados,
                            Map<String, Object> parametros) throws NegocioException {
        String caminho = "report/" + arquivoJrxml;

        try (InputStream jrxml = Thread.currentThread()
                .getContextClassLoader()
                .getResourceAsStream(caminho)) {

            if (jrxml == null) {
                throw new NegocioException("Modelo de relatório não encontrado: " + caminho);
            }

            JasperReport report = JasperCompileManager.compileReport(jrxml);
            JRBeanCollectionDataSource dataSource = new JRBeanCollectionDataSource(dados);
            JasperPrint print = JasperFillManager.fillReport(report, parametros, dataSource);
            return JasperExportManager.exportReportToPdf(print);

        } catch (JRException | IOException e) {
            LOG.log(Level.SEVERE, "Erro ao compilar/exportar Jasper: " + caminho, e);
            throw new NegocioException("Erro ao montar o PDF do relatório.", e);
        }
    }
}
