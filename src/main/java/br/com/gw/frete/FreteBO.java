package br.com.gw.frete;

import br.com.gw.Enums.CategoriaCNH;
import br.com.gw.Enums.StatusFrete;
import br.com.gw.Enums.StatusFiscal;
import br.com.gw.Enums.StatusMotorista;
import br.com.gw.Enums.StatusVeiculo;
import br.com.gw.Enums.TipoDestinatario;
import br.com.gw.Enums.TipoOcorrencia;
import br.com.gw.Enums.TipoOperacao;
import br.com.gw.cliente.Cliente;
import br.com.gw.cliente.ClienteDAO;
import br.com.gw.motorista.Motorista;
import br.com.gw.motorista.MotoristaDAO;
import br.com.gw.nucleo.utils.ConexaoUtil;
import br.com.gw.nucleo.exception.CadastroException;
import br.com.gw.nucleo.exception.FreteException;
import br.com.gw.nucleo.exception.NegocioException;
import br.com.gw.nucleo.utils.GeradorNumeroFrete;
import br.com.gw.veiculos.Veiculo;
import br.com.gw.veiculos.VeiculoDAO;

import java.math.BigDecimal;
import java.text.Normalizer;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.EnumSet;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Logger;

/**
 * Regras de negócio de frete.
 *
 * MÁQUINA DE ESTADOS:
 *  EMITIDO → SAIDA_CONFIRMADA → EM_TRANSITO → ENTREGUE
 *                                           → NAO_ENTREGUE
 *  Qualquer estado aberto → CANCELADO (com motivo)
 */
public class FreteBO {

    private static final Logger      LOG            = Logger.getLogger(FreteBO.class.getName());
    private static final int         TAMANHO_PAGINA = 10;

    /** Peso máximo razoável por manifesto de carga (200 t). */
    private static final BigDecimal  PESO_MAXIMO_KG = new BigDecimal("200000");

    /** Antecedência máxima para data prevista de entrega: 1 ano. */
    private static final int         MAX_DIAS_PREV_ENTREGA = 365;

    /** UFs brasileiras aceitas para origem, destino e ocorrências. */
    private static final Set<String> UFS_VALIDAS = Collections.unmodifiableSet(
        new HashSet<>(Arrays.asList(
            "AC","AL","AP","AM","BA","CE","DF","ES","GO","MA",
            "MT","MS","MG","PA","PB","PR","PE","PI","RJ","RN",
            "RS","RO","RR","SC","SP","SE","TO"
        ))
    );

    private final FreteDAO     dao      = new FreteDAO();
    private final MotoristaDAO motoDAO  = new MotoristaDAO();
    private final VeiculoDAO   veicDAO  = new VeiculoDAO();
    private final ClienteDAO   cliDAO   = new ClienteDAO();

    /** Transições de status permitidas: chave = status atual, valor = próximos válidos. */
    private static final java.util.Map<StatusFrete, Set<StatusFrete>> TRANSICOES;
    static {
        TRANSICOES = new java.util.EnumMap<>(StatusFrete.class);
        TRANSICOES.put(StatusFrete.EMITIDO,
            EnumSet.of(StatusFrete.SAIDA_CONFIRMADA, StatusFrete.CANCELADO));
        TRANSICOES.put(StatusFrete.SAIDA_CONFIRMADA,
            EnumSet.of(StatusFrete.EM_TRANSITO, StatusFrete.CANCELADO));
        TRANSICOES.put(StatusFrete.EM_TRANSITO,
            EnumSet.of(StatusFrete.ENTREGUE, StatusFrete.NAO_ENTREGUE, StatusFrete.CANCELADO));
        TRANSICOES.put(StatusFrete.ENTREGUE,     EnumSet.noneOf(StatusFrete.class));
        TRANSICOES.put(StatusFrete.NAO_ENTREGUE, EnumSet.noneOf(StatusFrete.class));
        TRANSICOES.put(StatusFrete.CANCELADO,    EnumSet.noneOf(StatusFrete.class));
    }

    /* =========================================================
       LISTAGEM
       ========================================================= */

    public List<Frete> listar(String filtro, String statusFiltro,
                               int pagina) throws NegocioException {
        try {
            int p = pagina < 1 ? 1 : pagina;
            return dao.listar(filtro, statusFiltro, p, TAMANHO_PAGINA);
        } catch (SQLException e) {
            LOG.severe("Erro ao listar fretes: " + e.getMessage());
            throw new NegocioException("Erro ao carregar a lista de fretes.", e);
        }
    }

    public int totalPaginas(String filtro, String statusFiltro) throws NegocioException {
        try {
            int total = dao.contarTotal(filtro, statusFiltro);
            return (int) Math.ceil((double) total / TAMANHO_PAGINA);
        } catch (SQLException e) {
            LOG.severe("Erro ao contar fretes: " + e.getMessage());
            throw new NegocioException("Erro ao calcular paginação.", e);
        }
    }

    public Frete buscarPorId(int id) throws NegocioException {
        try {
            Frete f = dao.buscarPorId(id);
            if (f == null)
                throw new CadastroException("Frete não encontrado (id=" + id + ").");
            return f;
        } catch (SQLException e) {
            LOG.severe("Erro ao buscar frete id=" + id + ": " + e.getMessage());
            throw new NegocioException("Erro ao buscar frete.", e);
        }
    }

    public List<OcorrenciaFrete> listarOcorrencias(int idFrete) throws NegocioException {
        try {
            return dao.listarOcorrencias(idFrete);
        } catch (SQLException e) {
            LOG.severe("Erro ao listar ocorrências do frete " + idFrete + ": " + e.getMessage());
            throw new NegocioException("Erro ao carregar ocorrências do frete.", e);
        }
    }

    /* =========================================================
       EMISSÃO DE FRETE (INSERT com validações completas)
       ========================================================= */

    /**
     * Emite um novo frete.
     *
     * Regras verificadas:
     *  1. Campos obrigatórios (inclui UF válida e descricaoCarga)
     *  2. Datas consistentes (não passado; máximo 1 ano à frente)
     *  3. Valores monetários positivos; peso dentro do limite
     *  4. Motorista ATIVO e CNH válida
     *  5. Veículo DISPONIVEL (status D)
     *  6. Veículo sem outro frete ativo em aberto
     *  7. Motorista sem outro frete ativo em aberto
     *  8. Peso da carga não ultrapassa capacidade do veículo
     *
     * Transação JDBC: número gerado + INSERT frete em atomicidade.
     */
    public void emitir(Frete f, String usuario) throws NegocioException {
        validarCamposObrigatorios(f);
        validarDatas(f);
        validarValores(f);
        prepararDadosOperacionaisEFiscais(f);
        validarMotorista(f.getIdMotorista(), 0);
        validarVeiculo(f.getIdVeiculo(), 0);
        validarCompatibilidadeMotoristaVeiculo(f.getIdMotorista(), f.getIdVeiculo());
        validarPesoVsVeiculo(f);

        f.setStatus(StatusFrete.EMITIDO);
        f.setDataEmissao(LocalDate.now());
        f.setCreatedBy(usuario);

        Connection conn = null;
        try {
            conn = ConexaoUtil.getConexao();
            conn.setAutoCommit(false);

            // Número gerado dentro da transação — sequence atômica
            f.setNumero(GeradorNumeroFrete.gerar(conn));

            int idGerado = dao.inserir(f, conn);
            f.setId(idGerado);

            conn.commit();

        } catch (SQLException e) {
            rollback(conn);
            LOG.severe("Erro ao emitir frete: " + e.getMessage());
            throw new NegocioException("Erro ao registrar o frete. Tente novamente.", e);
        } finally {
            fecharConexao(conn);
        }
    }

    /* =========================================================
       FLUXO DE STATUS
       ========================================================= */

    public void confirmarSaida(int idFrete, String municipioSaida,
                                String ufSaida, String usuario) throws NegocioException {
        Connection conn = null;
        try {
            conn = ConexaoUtil.getConexao();
            conn.setAutoCommit(false);

            Frete f = dao.buscarPorIdComConn(idFrete, conn);
            if (f == null)
                throw new CadastroException("Frete não encontrado (id=" + idFrete + ").");

            validarTransicao(f.getStatus(), StatusFrete.SAIDA_CONFIRMADA);

            LocalDateTime agora = LocalDateTime.now();
            dao.confirmarSaida(idFrete, agora, usuario, conn);
            dao.atualizarStatusVeiculo(f.getIdVeiculo(), StatusVeiculo.EM_VIAGEM, conn);

            OcorrenciaFrete oc = new OcorrenciaFrete();
            oc.setIdFrete(idFrete);
            oc.setTipo(TipoOcorrencia.SAIDA_PATIO);
            oc.setDataHora(agora);
            oc.setMunicipio(municipioSaida);
            oc.setUf(ufSaida);
            oc.setCreatedBy(usuario);
            dao.inserirOcorrencia(oc, conn);

            conn.commit();

        } catch (CadastroException | FreteException e) {
            rollback(conn);
            throw e;
        } catch (SQLException e) {
            rollback(conn);
            LOG.severe("Erro ao confirmar saída do frete " + idFrete + ": " + e.getMessage());
            throw new NegocioException("Erro ao confirmar saída do frete. Tente novamente.", e);
        } finally {
            fecharConexao(conn);
        }
    }

    public void iniciarTransito(int idFrete, String municipioAtual,
                                 String ufAtual, String usuario) throws NegocioException {
        Connection conn = null;
        try {
            conn = ConexaoUtil.getConexao();
            conn.setAutoCommit(false);

            Frete f = dao.buscarPorIdComConn(idFrete, conn);
            if (f == null)
                throw new CadastroException("Frete não encontrado (id=" + idFrete + ").");

            validarTransicao(f.getStatus(), StatusFrete.EM_TRANSITO);

            dao.iniciarTransito(idFrete, usuario, conn);

            OcorrenciaFrete oc = new OcorrenciaFrete();
            oc.setIdFrete(idFrete);
            oc.setTipo(TipoOcorrencia.EM_ROTA);
            oc.setDataHora(LocalDateTime.now());
            oc.setMunicipio(municipioAtual);
            oc.setUf(ufAtual);
            oc.setCreatedBy(usuario);
            dao.inserirOcorrencia(oc, conn);

            conn.commit();

        } catch (CadastroException | FreteException e) {
            rollback(conn);
            throw e;
        } catch (SQLException e) {
            rollback(conn);
            LOG.severe("Erro ao iniciar trânsito do frete " + idFrete + ": " + e.getMessage());
            throw new NegocioException("Erro ao iniciar trânsito. Tente novamente.", e);
        } finally {
            fecharConexao(conn);
        }
    }

    public void registrarEntrega(int idFrete, String nomeRecebedor,
                                  String documentoRecebedor, String municipio,
                                  String uf, String usuario) throws NegocioException {
        if (nomeRecebedor == null || nomeRecebedor.trim().isEmpty())
            throw new CadastroException("Nome do recebedor é obrigatório para registrar a entrega.");
        if (documentoRecebedor == null || documentoRecebedor.trim().isEmpty())
            throw new CadastroException("Documento do recebedor é obrigatório para registrar a entrega.");

        Connection conn = null;
        try {
            conn = ConexaoUtil.getConexao();
            conn.setAutoCommit(false);

            Frete f = dao.buscarPorIdComConn(idFrete, conn);
            if (f == null)
                throw new CadastroException("Frete não encontrado (id=" + idFrete + ").");

            validarTransicao(f.getStatus(), StatusFrete.ENTREGUE);

            LocalDateTime agora = LocalDateTime.now();
            dao.finalizarEntrega(idFrete, StatusFrete.ENTREGUE, agora, usuario, conn);
            dao.atualizarStatusVeiculo(f.getIdVeiculo(), StatusVeiculo.DISPONIVEL, conn);

            OcorrenciaFrete oc = new OcorrenciaFrete();
            oc.setIdFrete(idFrete);
            oc.setTipo(TipoOcorrencia.ENTREGA_REALIZADA);
            oc.setDataHora(agora);
            oc.setMunicipio(municipio);
            oc.setUf(uf);
            oc.setNomeRecebedor(nomeRecebedor.trim());
            oc.setDocumentoRecebedor(documentoRecebedor.trim());
            oc.setCreatedBy(usuario);
            dao.inserirOcorrencia(oc, conn);

            conn.commit();

        } catch (CadastroException | FreteException e) {
            rollback(conn);
            throw e;
        } catch (SQLException e) {
            rollback(conn);
            LOG.severe("Erro ao registrar entrega do frete " + idFrete + ": " + e.getMessage());
            throw new NegocioException("Erro ao registrar entrega. Tente novamente.", e);
        } finally {
            fecharConexao(conn);
        }
    }

    public void registrarNaoEntrega(int idFrete, String motivo,
                                     String municipio, String uf,
                                     String usuario) throws NegocioException {
        if (motivo == null || motivo.trim().isEmpty())
            throw new CadastroException("O motivo da não entrega é obrigatório.");

        Connection conn = null;
        try {
            conn = ConexaoUtil.getConexao();
            conn.setAutoCommit(false);

            Frete f = dao.buscarPorIdComConn(idFrete, conn);
            if (f == null)
                throw new CadastroException("Frete não encontrado (id=" + idFrete + ").");

            validarTransicao(f.getStatus(), StatusFrete.NAO_ENTREGUE);

            LocalDateTime agora = LocalDateTime.now();
            dao.finalizarEntrega(idFrete, StatusFrete.NAO_ENTREGUE, agora, usuario, conn);
            dao.atualizarStatusVeiculo(f.getIdVeiculo(), StatusVeiculo.DISPONIVEL, conn);

            OcorrenciaFrete oc = new OcorrenciaFrete();
            oc.setIdFrete(idFrete);
            oc.setTipo(TipoOcorrencia.TENTATIVA_ENTREGA);
            oc.setDataHora(agora);
            oc.setMunicipio(municipio);
            oc.setUf(uf);
            oc.setDescricao(motivo.trim());
            oc.setCreatedBy(usuario);
            dao.inserirOcorrencia(oc, conn);

            conn.commit();

        } catch (CadastroException | FreteException e) {
            rollback(conn);
            throw e;
        } catch (SQLException e) {
            rollback(conn);
            LOG.severe("Erro ao registrar não entrega do frete " + idFrete + ": " + e.getMessage());
            throw new NegocioException("Erro ao registrar não entrega. Tente novamente.", e);
        } finally {
            fecharConexao(conn);
        }
    }

    public void cancelar(int idFrete, String motivo, String usuario) throws NegocioException {
        if (motivo == null || motivo.trim().isEmpty())
            throw new CadastroException("Informe o motivo do cancelamento.");

        Connection conn = null;
        try {
            conn = ConexaoUtil.getConexao();
            conn.setAutoCommit(false);

            Frete f = dao.buscarPorIdComConn(idFrete, conn);
            if (f == null)
                throw new CadastroException("Frete não encontrado (id=" + idFrete + ").");

            validarTransicao(f.getStatus(), StatusFrete.CANCELADO);

            dao.cancelar(idFrete, motivo, usuario, conn);

            if (f.getStatus() == StatusFrete.SAIDA_CONFIRMADA
                    || f.getStatus() == StatusFrete.EM_TRANSITO) {
                dao.atualizarStatusVeiculo(f.getIdVeiculo(), StatusVeiculo.DISPONIVEL, conn);
            }

            conn.commit();

        } catch (CadastroException | FreteException e) {
            rollback(conn);
            throw e;
        } catch (SQLException e) {
            rollback(conn);
            LOG.severe("Erro ao cancelar frete " + idFrete + ": " + e.getMessage());
            throw new NegocioException("Erro ao cancelar o frete. Tente novamente.", e);
        } finally {
            fecharConexao(conn);
        }
    }

    /* =========================================================
       OCORRÊNCIAS AVULSAS
       ========================================================= */

    public void registrarOcorrencia(OcorrenciaFrete oc, String usuario) throws NegocioException {
        validarOcorrencia(oc);

        Connection conn = null;
        try {
            conn = ConexaoUtil.getConexao();
            conn.setAutoCommit(false);

            Frete f = dao.buscarPorIdComConn(oc.getIdFrete(), conn);
            if (f == null)
                throw new CadastroException("Frete não encontrado.");

            if (!f.isAberto())
                throw new FreteException(
                    "Não é possível registrar ocorrência em frete com status "
                    + f.getStatus().getDescricao() + ".");

            if (oc.getDataHora() == null) oc.setDataHora(LocalDateTime.now());
            oc.setCreatedBy(usuario);
            dao.inserirOcorrencia(oc, conn);

            conn.commit();

        } catch (CadastroException | FreteException e) {
            rollback(conn);
            throw e;
        } catch (SQLException e) {
            rollback(conn);
            LOG.severe("Erro ao registrar ocorrência: " + e.getMessage());
            throw new NegocioException("Erro ao registrar ocorrência. Tente novamente.", e);
        } finally {
            fecharConexao(conn);
        }
    }

    /* =========================================================
       VALIDAÇÕES PRIVADAS
       ========================================================= */

    private void validarCamposObrigatorios(Frete f) throws CadastroException {
        if (f.getIdRemetente() == 0)
            throw new CadastroException("Selecione o Remetente.");
        if (f.getIdDestinatario() == 0)
            throw new CadastroException("Selecione o Destinatário.");
        if (f.getIdRemetente() == f.getIdDestinatario())
            throw new CadastroException(
                "Remetente e Destinatário não podem ser o mesmo cliente.");
        if (f.getIdMotorista() == 0)
            throw new CadastroException("Selecione o Motorista.");
        if (f.getIdVeiculo() == 0)
            throw new CadastroException("Selecione o Veículo.");

        // Origem
        if (f.getMunicipioOrigem() == null || f.getMunicipioOrigem().trim().isEmpty())
            throw new CadastroException("O Município de Origem é obrigatório.");
        if (f.getUfOrigem() == null || f.getUfOrigem().trim().isEmpty())
            throw new CadastroException("A UF de Origem é obrigatória.");
        if (f.getUfOrigem().trim().length() != 2)
            throw new CadastroException("UF de Origem inválida — informe exatamente 2 letras.");
        if (!UFS_VALIDAS.contains(f.getUfOrigem().trim().toUpperCase()))
            throw new CadastroException(
                "UF de Origem inválida: \"" + f.getUfOrigem() + "\". "
                + "Use a sigla oficial do estado (ex: SP, RJ, MG).");

        // Destino
        if (f.getMunicipioDestino() == null || f.getMunicipioDestino().trim().isEmpty())
            throw new CadastroException("O Município de Destino é obrigatório.");
        if (f.getUfDestino() == null || f.getUfDestino().trim().isEmpty())
            throw new CadastroException("A UF de Destino é obrigatória.");
        if (f.getUfDestino().trim().length() != 2)
            throw new CadastroException("UF de Destino inválida — informe exatamente 2 letras.");
        if (!UFS_VALIDAS.contains(f.getUfDestino().trim().toUpperCase()))
            throw new CadastroException(
                "UF de Destino inválida: \"" + f.getUfDestino() + "\". "
                + "Use a sigla oficial do estado (ex: SP, RJ, MG).");

        if (f.getDescricaoCarga() == null || f.getDescricaoCarga().trim().isEmpty())
            throw new CadastroException(
                "A Descrição da Carga é obrigatória. "
                + "Descreva o tipo de mercadoria transportada.");

        if (f.getDataPrevEntrega() == null)
            throw new CadastroException("A Data Prevista de Entrega é obrigatória.");
        if (f.getValorFrete() == null || f.getValorFrete().compareTo(BigDecimal.ZERO) <= 0)
            throw new CadastroException("O Valor do Frete deve ser maior que zero.");
    }

    private void validarDatas(Frete f) throws CadastroException {
        LocalDate hoje = LocalDate.now();

        if (f.getDataPrevEntrega() != null) {
            if (f.getDataPrevEntrega().isBefore(hoje))
                throw new CadastroException(
                    "A Data Prevista de Entrega não pode ser anterior à data de hoje ("
                    + hoje.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"))
                    + ").");

            LocalDate limiteMaximo = hoje.plusDays(MAX_DIAS_PREV_ENTREGA);
            if (f.getDataPrevEntrega().isAfter(limiteMaximo))
                throw new CadastroException(
                    "A Data Prevista de Entrega não pode ultrapassar 1 ano a partir de hoje. "
                    + "Se a data estiver correta, entre em contato com o suporte.");
        }
    }

    private void validarValores(Frete f) throws CadastroException {
        if (f.getPesoKg() == null)
            throw new CadastroException("O Peso da Carga é obrigatório.");

        if (f.getPesoKg().compareTo(BigDecimal.ZERO) <= 0)
            throw new CadastroException("O Peso da Carga deve ser maior que zero.");

        if (f.getPesoKg().compareTo(PESO_MAXIMO_KG) > 0)
            throw new CadastroException(
                "O Peso da Carga informado (" + f.getPesoKg() + " kg) "
                + "excede o limite máximo permitido de "
                + PESO_MAXIMO_KG.toPlainString() + " kg. Verifique os dados.");

        if (f.getVolumes() == null)
            throw new CadastroException("O número de Volumes é obrigatório.");

        if (f.getVolumes() <= 0)
            throw new CadastroException("O número de Volumes deve ser maior que zero.");

        if (f.getAliquotaIcms() != null) {
            if (f.getAliquotaIcms().compareTo(BigDecimal.ZERO) < 0)
                throw new CadastroException("A Alíquota de ICMS não pode ser negativa.");
            if (f.getAliquotaIcms().compareTo(new BigDecimal("100")) > 0)
                throw new CadastroException("A Alíquota de ICMS não pode ultrapassar 100%.");
        }
        if (f.getAliquotaIbs() != null && f.getAliquotaIbs().compareTo(new BigDecimal("100")) > 0)
            throw new CadastroException("A Alíquota de IBS não pode ultrapassar 100%.");
        if (f.getAliquotaCbs() != null && f.getAliquotaCbs().compareTo(new BigDecimal("100")) > 0)
            throw new CadastroException("A Alíquota de CBS não pode ultrapassar 100%.");
    }

    private void validarMotorista(int idMotorista, int excluirIdFrete) throws NegocioException {
        try {
            Motorista m = motoDAO.buscarPorId(idMotorista);
            if (m == null)
                throw new CadastroException("Motorista não encontrado.");
            if (m.getStatus() != StatusMotorista.ATIVO)
                throw new FreteException(
                    "O motorista " + m.getNome() + " não está Ativo "
                    + "(status atual: " + m.getStatus().getDescricao() + "). "
                    + "Regularize o cadastro antes de emitir o frete.");
            if (m.getCnhCategoria() == null)
                throw new FreteException(
                    "O motorista " + m.getNome()
                    + " não possui categoria de CNH informada no cadastro.");
            if (m.getCnhValidade() == null)
                throw new FreteException(
                    "O motorista " + m.getNome()
                    + " não possui validade da CNH informada no cadastro.");
            if (m.getCnhValidade().isBefore(LocalDate.now()))
                throw new FreteException(
                    "A CNH do motorista " + m.getNome() + " está vencida desde "
                    + m.getCnhValidade().format(
                        java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"))
                    + ". Regularize antes de emitir o frete.");
            if (m.getCnhValidade() != null
                    && m.getCnhValidade().isBefore(LocalDate.now().plusDays(30))
                    && m.getCnhValidade().isAfter(LocalDate.now())) {
                LOG.warning("CNH do motorista " + m.getNome()
                    + " vence em " + m.getCnhValidade() + " (menos de 30 dias).");
            }
            if (dao.motoristaTemFreteAtivo(idMotorista, excluirIdFrete))
                throw new FreteException(
                    "O motorista " + m.getNome() + " já possui um frete em aberto. "
                    + "Finalize ou cancele o frete anterior antes de emitir um novo.");
        } catch (SQLException e) {
            LOG.severe("Erro ao validar motorista: " + e.getMessage());
            throw new NegocioException("Erro ao validar dados do motorista.", e);
        }
    }

    private void validarCompatibilidadeMotoristaVeiculo(int idMotorista, int idVeiculo)
            throws NegocioException {
        try {
            Motorista m = motoDAO.buscarPorId(idMotorista);
            Veiculo v = veicDAO.buscarPorId(idVeiculo);

            if (m == null || v == null || v.getTipo() == null) return;

            CategoriaCNH cnhMotorista = m.getCnhCategoria();
            CategoriaCNH cnhExigida = v.getTipo().getCnhMinima();

            if (cnhMotorista == null || !cnhMotorista.atende(cnhExigida)) {
                throw new FreteException(
                    "O motorista selecionado não possui categoria de CNH compatível com o veículo. "
                    + "Motorista: " + (cnhMotorista == null ? "não informada" : cnhMotorista.getCodigo())
                    + ". Veículo " + v.getPlaca() + " (" + v.getTipo().getDescricao()
                    + ") exige categoria mínima " + cnhExigida.getCodigo() + ".");
            }
        } catch (SQLException e) {
            LOG.severe("Erro ao validar compatibilidade motorista x veículo: " + e.getMessage());
            throw new NegocioException("Erro ao validar compatibilidade entre motorista e veículo.", e);
        }
    }

    private void validarVeiculo(int idVeiculo, int excluirIdFrete) throws NegocioException {
        try {
            Veiculo v = veicDAO.buscarPorId(idVeiculo);
            if (v == null)
                throw new CadastroException("Veículo não encontrado.");
            if (v.getStatus() != StatusVeiculo.DISPONIVEL)
                throw new FreteException(
                    "O veículo " + v.getPlaca() + " não está Disponível "
                    + "(status atual: " + v.getStatus().getDescricao() + "). "
                    + "Verifique se há outro frete em aberto ou se o veículo está em manutenção.");
            if (dao.veiculoTemFreteAtivo(idVeiculo, excluirIdFrete))
                throw new FreteException(
                    "O veículo " + v.getPlaca() + " já possui um frete ativo em aberto. "
                    + "Finalize ou cancele o frete anterior antes de emitir um novo.");
        } catch (SQLException e) {
            LOG.severe("Erro ao validar veículo: " + e.getMessage());
            throw new NegocioException("Erro ao validar dados do veículo.", e);
        }
    }

    private void validarPesoVsVeiculo(Frete f) throws NegocioException {
        if (f.getPesoKg() == null || f.getPesoKg().compareTo(BigDecimal.ZERO) <= 0) return;
        try {
            Veiculo v = veicDAO.buscarPorId(f.getIdVeiculo());
            if (v == null) return;

            BigDecimal capacidade = v.getCapacidadeKg();
            if (capacidade == null || capacidade.compareTo(BigDecimal.ZERO) <= 0)
                throw new FreteException(
                    "O veículo " + v.getPlaca()
                    + " não possui capacidade de carga válida cadastrada.");

            if (f.getPesoKg().compareTo(capacidade) > 0) {
                throw new FreteException(
                    "O peso da carga excede a capacidade do veículo selecionado. "
                    + "Capacidade: " + capacidade.toPlainString() + " kg. "
                    + "Peso informado: " + f.getPesoKg().toPlainString() + " kg.");
            }
        } catch (SQLException e) {
            LOG.severe("Erro ao verificar capacidade do veículo: " + e.getMessage());
            throw new NegocioException("Erro ao verificar capacidade do veículo.", e);
        }
    }

    private void validarTransicao(StatusFrete atual, StatusFrete destino) throws FreteException {
        Set<StatusFrete> permitidos = TRANSICOES.get(atual);
        if (permitidos == null || !permitidos.contains(destino)) {
            throw new FreteException(
                "Transição de status inválida: " + atual.getDescricao()
                + " → " + destino.getDescricao() + ". "
                + "Verifique o fluxo de status do frete.");
        }
    }

    private void validarOcorrencia(OcorrenciaFrete oc) throws CadastroException {
        if (oc.getIdFrete() == 0)
            throw new CadastroException("ID do frete não informado.");
        if (oc.getTipo() == null)
            throw new CadastroException("Tipo de ocorrência é obrigatório.");

        TipoOcorrencia tipo = oc.getTipo();

        if (tipo.isExigeRecebedor()) {
            if (oc.getNomeRecebedor() == null || oc.getNomeRecebedor().trim().isEmpty())
                throw new CadastroException("Nome do recebedor é obrigatório para "
                    + "ocorrência do tipo '" + tipo.getDescricao() + "'.");
            if (oc.getDocumentoRecebedor() == null || oc.getDocumentoRecebedor().trim().isEmpty())
                throw new CadastroException("Documento do recebedor é obrigatório para "
                    + "ocorrência do tipo '" + tipo.getDescricao() + "'.");
        }

        if (tipo.isExigeDescricao()) {
            if (oc.getDescricao() == null || oc.getDescricao().trim().isEmpty())
                throw new CadastroException(
                    "Descrição é obrigatória para ocorrência do tipo '"
                    + tipo.getDescricao() + "'.");
        }
    }

    /* =========================================================
       PREPARAÇÃO FISCAL
       ========================================================= */

    private void prepararDadosOperacionaisEFiscais(Frete f) throws NegocioException {
        f.setTipoOperacao(calcularTipoOperacao(f));
        f.setTipoDestinatario(inferirTipoDestinatario(f.getIdDestinatario()));

        f.setAliquotaIcms(BigDecimal.ZERO);
        f.setValorIcms(BigDecimal.ZERO);
        f.setAliquotaIbs(BigDecimal.ZERO);
        f.setValorIbs(BigDecimal.ZERO);
        f.setAliquotaCbs(BigDecimal.ZERO);
        f.setValorCbs(BigDecimal.ZERO);
        f.setTotalTributos(BigDecimal.ZERO);
        f.setValorTotal(f.getValorFrete());
        f.setValorTotalEstimado(f.getValorFrete());
        f.setCfop("Não calculado");
        f.setMotivoCfop("Aguardando integração fiscal");
        f.setRegraFiscalAplicada("Aguardando integração");
        f.setStatusFiscal(StatusFiscal.PENDENTE);
    }

    private TipoOperacao calcularTipoOperacao(Frete f) {
        String ufOrigem = normalizarTexto(f.getUfOrigem());
        String ufDestino = normalizarTexto(f.getUfDestino());
        String municipioOrigem = normalizarTexto(f.getMunicipioOrigem());
        String municipioDestino = normalizarTexto(f.getMunicipioDestino());

        if (!ufOrigem.equals(ufDestino)) return TipoOperacao.INTERESTADUAL;
        if (!municipioOrigem.equals(municipioDestino)) return TipoOperacao.ESTADUAL;
        return TipoOperacao.MUNICIPAL;
    }

    private TipoDestinatario inferirTipoDestinatario(int idDestinatario) throws NegocioException {
        try {
            Cliente destinatario = cliDAO.buscarPorId(idDestinatario);
            if (destinatario == null)
                throw new CadastroException("Destinatário não encontrado.");

            String documento = destinatario.getDocumentoFiscal() == null
                ? ""
                : destinatario.getDocumentoFiscal().replaceAll("[^0-9]", "");

            if (documento.length() == 11) return TipoDestinatario.PESSOA_FISICA;
            if (documento.length() == 14) return TipoDestinatario.PESSOA_JURIDICA;

            throw new CadastroException(
                "Documento fiscal do destinatário inválido. Revise o cadastro do cliente.");
        } catch (SQLException e) {
            LOG.severe("Erro ao inferir tipo de destinatário: " + e.getMessage());
            throw new NegocioException("Erro ao validar dados fiscais do destinatário.", e);
        }
    }

    private String normalizarTexto(String valor) {
        if (valor == null) return "";
        String semAcento = Normalizer.normalize(valor.trim(), Normalizer.Form.NFD)
            .replaceAll("\\p{M}", "");
        return semAcento.toUpperCase();
    }

    /* =========================================================
       HELPERS DE TRANSAÇÃO
       ========================================================= */

    private void rollback(Connection conn) {
        if (conn != null) {
            try { conn.rollback(); }
            catch (SQLException ex) { LOG.severe("Falha no rollback: " + ex.getMessage()); }
        }
    }

    private void fecharConexao(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException ex) {
                LOG.severe("Falha ao fechar conexão: " + ex.getMessage());
            }
        }
    }
}
