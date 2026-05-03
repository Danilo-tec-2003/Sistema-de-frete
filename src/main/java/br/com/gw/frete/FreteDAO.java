package br.com.gw.frete;

import br.com.gw.Enums.CategoriaCNH;
import br.com.gw.Enums.StatusFrete;
import br.com.gw.Enums.StatusFiscal;
import br.com.gw.Enums.StatusVeiculo;
import br.com.gw.Enums.TipoDestinatario;
import br.com.gw.Enums.TipoOcorrencia;
import br.com.gw.Enums.TipoOperacao;
import br.com.gw.Enums.TipoVeiculo;
import br.com.gw.cliente.Cliente;
import br.com.gw.motorista.Motorista;
import br.com.gw.nucleo.utils.ConexaoUtil;
import br.com.gw.veiculos.Veiculo;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Acesso a dados do frete.
 *
 * Convenções:
 *  - Métodos que recebem Connection explícito participam de transações gerenciadas pelo BO.
 *  - Métodos sem Connection abrem e fecham a própria conexão (operações simples de leitura).
 *  - Nunca se expõe SQLException fora deste pacote — quem chama trata no BO.
 */
public class FreteDAO {

    /* =========================================================
       INSERIR
       ========================================================= */

    /**
     * Insere o frete e retorna o ID gerado.
     * Chamado dentro de transação pelo FreteBO — não abre/fecha conn aqui.
     */
    public int inserir(Frete f, Connection conn) throws SQLException {
        final String sql =
            "INSERT INTO frete (" +
            "  numero, id_remetente, id_destinatario, id_motorista, id_veiculo, " +
            "  municipio_origem, uf_origem, municipio_destino, uf_destino, " +
            "  descricao_carga, peso_kg, volumes, " +
            "  valor_frete, aliquota_icms, valor_icms, " +
            "  aliquota_ibs, valor_ibs, aliquota_cbs, valor_cbs, " +
            "  valor_total, status, data_emissao, data_prev_entrega, " +
            "  tipo_operacao, tipo_destinatario, cfop, motivo_cfop, " +
            "  status_fiscal, regra_fiscal_aplicada, total_tributos, valor_total_estimado, " +
            "  observacao, created_by, updated_by" +
            ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) " +
            "RETURNING idfrete";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            ps.setString    (i++, f.getNumero());
            ps.setInt       (i++, f.getIdRemetente());
            ps.setInt       (i++, f.getIdDestinatario());
            ps.setInt       (i++, f.getIdMotorista());
            ps.setInt       (i++, f.getIdVeiculo());
            ps.setString    (i++, f.getMunicipioOrigem());
            ps.setString    (i++, f.getUfOrigem());
            ps.setString    (i++, f.getMunicipioDestino());
            ps.setString    (i++, f.getUfDestino());
            ps.setString    (i++, f.getDescricaoCarga());
            setBigDecimalNullable(ps, i++, f.getPesoKg());
            setIntNullable      (ps, i++, f.getVolumes());
            ps.setBigDecimal(i++, f.getValorFrete());
            ps.setBigDecimal(i++, f.getAliquotaIcms());
            ps.setBigDecimal(i++, f.getValorIcms());
            ps.setBigDecimal(i++, f.getAliquotaIbs());
            ps.setBigDecimal(i++, f.getValorIbs());
            ps.setBigDecimal(i++, f.getAliquotaCbs());
            ps.setBigDecimal(i++, f.getValorCbs());
            ps.setBigDecimal(i++, f.getValorTotal());
            ps.setString    (i++, String.valueOf(f.getStatus().getCodigo()));
            ps.setDate      (i++, Date.valueOf(f.getDataEmissao()));
            ps.setDate      (i++, Date.valueOf(f.getDataPrevEntrega()));
            ps.setString    (i++, f.getTipoOperacao() == null ? null : f.getTipoOperacao().name());
            ps.setString    (i++, f.getTipoDestinatario() == null ? null : f.getTipoDestinatario().name());
            ps.setString    (i++, f.getCfop());
            ps.setString    (i++, f.getMotivoCfop());
            ps.setString    (i++, f.getStatusFiscal() == null ? StatusFiscal.PENDENTE.name() : f.getStatusFiscal().name());
            ps.setString    (i++, f.getRegraFiscalAplicada());
            ps.setBigDecimal(i++, f.getTotalTributos());
            ps.setBigDecimal(i++, f.getValorTotalEstimado());
            ps.setString    (i++, f.getObservacao());
            ps.setString    (i++, f.getCreatedBy());
            ps.setString    (i  , f.getCreatedBy());   // updated_by = created_by na inserção

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
                throw new SQLException("Nenhum ID retornado na inserção do frete.");
            }
        }
    }

    /* =========================================================
       ATUALIZAR STATUS
       ========================================================= */

    /** Atualiza apenas o status e updated_by (uso geral). */
    public void atualizarStatus(int idFrete, StatusFrete novoStatus,
                                 String usuario, Connection conn) throws SQLException {
        final String sql =
            "UPDATE frete SET status=?, updated_at=NOW(), updated_by=? WHERE idfrete=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, String.valueOf(novoStatus.getCodigo()));
            ps.setString(2, usuario);
            ps.setInt   (3, idFrete);
            ps.executeUpdate();
        }
    }

    /** Confirma saída: grava status S e data_saida na mesma operação. */
    public void confirmarSaida(int idFrete, LocalDateTime dataSaida,
                                String usuario, Connection conn) throws SQLException {
        final String sql =
            "UPDATE frete SET status='S', data_saida=?, updated_at=NOW(), updated_by=? " +
            "WHERE idfrete=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(dataSaida));
            ps.setString   (2, usuario);
            ps.setInt      (3, idFrete);
            ps.executeUpdate();
        }
    }

    /** Registra o início do trânsito (status T). */
    public void iniciarTransito(int idFrete, String usuario, Connection conn) throws SQLException {
        atualizarStatus(idFrete, StatusFrete.EM_TRANSITO, usuario, conn);
    }

    /** Finaliza o frete (ENTREGUE ou NAO_ENTREGUE) gravando data_entrega. */
    public void finalizarEntrega(int idFrete, StatusFrete status, LocalDateTime dataEntrega,
                                  String usuario, Connection conn) throws SQLException {
        final String sql =
            "UPDATE frete SET status=?, data_entrega=?, updated_at=NOW(), updated_by=? " +
            "WHERE idfrete=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString   (1, String.valueOf(status.getCodigo()));
            ps.setTimestamp(2, Timestamp.valueOf(dataEntrega));
            ps.setString   (3, usuario);
            ps.setInt      (4, idFrete);
            ps.executeUpdate();
        }
    }

    /** Cancela o frete. */
    public void cancelar(int idFrete, String motivo, String usuario,
                          Connection conn) throws SQLException {
        final String sql =
            "UPDATE frete SET status='C', observacao=COALESCE(observacao||E'\\n','') || ?, " +
            "updated_at=NOW(), updated_by=? WHERE idfrete=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "CANCELADO: " + motivo);
            ps.setString(2, usuario);
            ps.setInt   (3, idFrete);
            ps.executeUpdate();
        }
    }

    /* =========================================================
       ATUALIZAR STATUS DO VEÍCULO (dentro das transações do BO)
       ========================================================= */

    public void atualizarStatusVeiculo(int idVeiculo, StatusVeiculo novoStatus,
                                        Connection conn) throws SQLException {
        final String sql = "UPDATE veiculo SET status=?, updated_at=NOW() WHERE idveiculo=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, String.valueOf(novoStatus.getCodigo()));
            ps.setInt   (2, idVeiculo);
            ps.executeUpdate();
        }
    }

    /* =========================================================
       CONSULTAS
       ========================================================= */

    public Frete buscarPorId(int id) throws SQLException {
        final String sql =
            "SELECT f.*, " +
            "  rem.razao_social  AS remetente_nome,  rem.cnpj  AS remetente_cnpj, " +
            "  dest.razao_social AS destinatario_nome, dest.cnpj AS destinatario_cnpj, " +
            "  m.nome AS motorista_nome, m.cpf AS motorista_cpf, m.cnh_categoria, m.cnh_validade, " +
            "  v.placa AS veiculo_placa, v.tipo AS veiculo_tipo, v.capacidade_kg AS veiculo_capacidade_kg " +
            "FROM frete f " +
            "JOIN cliente   rem  ON f.id_remetente    = rem.idcliente " +
            "JOIN cliente   dest ON f.id_destinatario = dest.idcliente " +
            "JOIN motorista m    ON f.id_motorista    = m.idmotorista " +
            "JOIN veiculo   v    ON f.id_veiculo      = v.idveiculo " +
            "WHERE f.idfrete = ?";

        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapearCompleto(rs);
                return null;
            }
        }
    }

    public Frete buscarPorIdComConn(int id, Connection conn) throws SQLException {
        final String sql = "SELECT * FROM frete WHERE idfrete = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapearSimples(rs);
                return null;
            }
        }
    }

    /** Listagem paginada com join para exibição. */
    public List<Frete> listar(String filtro, String statusFiltro,
                               int pagina, int tamanhoPagina) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT f.idfrete, f.numero, f.status, " +
            "  f.municipio_origem, f.uf_origem, f.municipio_destino, f.uf_destino, " +
            "  f.valor_frete, f.valor_total, f.data_emissao, f.data_prev_entrega, " +
            "  f.data_saida, f.data_entrega, f.peso_kg, " +
            "  rem.razao_social  AS remetente_nome, " +
            "  dest.razao_social AS destinatario_nome, " +
            "  m.nome AS motorista_nome, " +
            "  v.placa AS veiculo_placa " +
            "FROM frete f " +
            "JOIN cliente   rem  ON f.id_remetente    = rem.idcliente " +
            "JOIN cliente   dest ON f.id_destinatario = dest.idcliente " +
            "JOIN motorista m    ON f.id_motorista    = m.idmotorista " +
            "JOIN veiculo   v    ON f.id_veiculo      = v.idveiculo " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (filtro != null && !filtro.trim().isEmpty()) {
            sql.append("AND (f.numero ILIKE ? OR rem.razao_social ILIKE ? " +
                       "     OR dest.razao_social ILIKE ? OR m.nome ILIKE ? OR v.placa ILIKE ?) ");
            String like = "%" + filtro.trim() + "%";
            for (int i = 0; i < 5; i++) params.add(like);
        }

        if (statusFiltro != null && !statusFiltro.isEmpty()) {
            sql.append("AND f.status = ? ");
            params.add(statusFiltro);
        }

        sql.append("ORDER BY f.idfrete DESC ");
        sql.append("LIMIT ? OFFSET ?");
        params.add(tamanhoPagina);
        params.add((pagina - 1) * tamanhoPagina);

        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                List<Frete> lista = new ArrayList<>();
                while (rs.next()) lista.add(mapearListagem(rs));
                return lista;
            }
        }
    }

    public int contarTotal(String filtro, String statusFiltro) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM frete f " +
            "JOIN cliente rem  ON f.id_remetente    = rem.idcliente " +
            "JOIN cliente dest ON f.id_destinatario = dest.idcliente " +
            "JOIN motorista m  ON f.id_motorista    = m.idmotorista " +
            "JOIN veiculo   v  ON f.id_veiculo      = v.idveiculo " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (filtro != null && !filtro.trim().isEmpty()) {
            sql.append("AND (f.numero ILIKE ? OR rem.razao_social ILIKE ? " +
                       "     OR dest.razao_social ILIKE ? OR m.nome ILIKE ? OR v.placa ILIKE ?) ");
            String like = "%" + filtro.trim() + "%";
            for (int i = 0; i < 5; i++) params.add(like);
        }

        if (statusFiltro != null && !statusFiltro.isEmpty()) {
            sql.append("AND f.status = ? ");
            params.add(statusFiltro);
        }

        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public int contarAtrasados() throws SQLException {
        final String sql =
            "SELECT COUNT(*) FROM frete " +
            "WHERE status IN ('E','S','T','N') AND data_prev_entrega < CURRENT_DATE";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public int contarEntreguesHoje() throws SQLException {
        final String sql =
            "SELECT COUNT(*) FROM frete " +
            "WHERE status = 'R' AND data_entrega::date = CURRENT_DATE";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /** Verifica se o veículo tem frete ativo (status E, S ou T). */
    public boolean veiculoTemFreteAtivo(int idVeiculo, int excluirIdFrete) throws SQLException {
        final String sql =
            "SELECT 1 FROM frete WHERE id_veiculo=? AND status IN ('E','S','T') " +
            "AND idfrete <> ? LIMIT 1";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idVeiculo);
            ps.setInt(2, excluirIdFrete);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    /** Verifica se o motorista tem frete ativo. */
    public boolean motoristaTemFreteAtivo(int idMotorista, int excluirIdFrete) throws SQLException {
        final String sql =
            "SELECT 1 FROM frete WHERE id_motorista=? AND status IN ('E','S','T') " +
            "AND idfrete <> ? LIMIT 1";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idMotorista);
            ps.setInt(2, excluirIdFrete);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    /* =========================================================
       OCORRÊNCIAS
       ========================================================= */

    public void inserirOcorrencia(OcorrenciaFrete o, Connection conn) throws SQLException {
        final String sql =
            "INSERT INTO ocorrencia_frete " +
            "  (id_frete, tipo, data_hora, municipio, uf, descricao, " +
            "   nome_recebedor, documento_recebedor, created_by) " +
            "VALUES (?,?,?,?,?,?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt      (1, o.getIdFrete());
            ps.setString   (2, String.valueOf(o.getTipo().getCodigo()));
            ps.setTimestamp(3, Timestamp.valueOf(
                o.getDataHora() != null ? o.getDataHora() : LocalDateTime.now()));
            ps.setString   (4, o.getMunicipio());
            ps.setString   (5, o.getUf());
            ps.setString   (6, o.getDescricao());
            ps.setString   (7, o.getNomeRecebedor());
            ps.setString   (8, o.getDocumentoRecebedor());
            ps.setString   (9, o.getCreatedBy());
            ps.executeUpdate();
        }
    }

    public List<OcorrenciaFrete> listarOcorrencias(int idFrete) throws SQLException {
        final String sql =
            "SELECT * FROM ocorrencia_frete WHERE id_frete=? ORDER BY data_hora ASC";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idFrete);
            try (ResultSet rs = ps.executeQuery()) {
                List<OcorrenciaFrete> lista = new ArrayList<>();
                while (rs.next()) lista.add(mapearOcorrencia(rs));
                return lista;
            }
        }
    }

    /* =========================================================
       MAPEADORES
       ========================================================= */

    /** Mapeamento completo com joins (para detalhe). */
    private Frete mapearCompleto(ResultSet rs) throws SQLException {
        Frete f = mapearSimples(rs);

        Cliente rem = new Cliente();
        rem.setId(rs.getInt("id_remetente"));
        rem.setRazaoSocial(rs.getString("remetente_nome"));
        rem.setCnpj(rs.getString("remetente_cnpj"));
        f.setRemetente(rem);

        Cliente dest = new Cliente();
        dest.setId(rs.getInt("id_destinatario"));
        dest.setRazaoSocial(rs.getString("destinatario_nome"));
        dest.setCnpj(rs.getString("destinatario_cnpj"));
        f.setDestinatario(dest);

        Motorista m = new Motorista();
        m.setId(rs.getInt("id_motorista"));
        m.setNome(rs.getString("motorista_nome"));
        m.setCpf(rs.getString("motorista_cpf"));
        String cnhCat = rs.getString("cnh_categoria");
        if (cnhCat != null) m.setCnhCategoria(CategoriaCNH.fromCodigo(cnhCat));
        Date cnhVal = rs.getDate("cnh_validade");
        if (cnhVal != null) m.setCnhValidade(cnhVal.toLocalDate());
        f.setMotorista(m);

        Veiculo v = new Veiculo();
        v.setId(rs.getInt("id_veiculo"));
        v.setPlaca(rs.getString("veiculo_placa"));
        String veiculoTipo = rs.getString("veiculo_tipo");
        if (veiculoTipo != null) v.setTipo(TipoVeiculo.fromCodigo(veiculoTipo));
        v.setCapacidadeKg(rs.getBigDecimal("veiculo_capacidade_kg"));
        f.setVeiculo(v);

        return f;
    }

    /** Mapeamento para listagem (sem joins extras). */
    private Frete mapearListagem(ResultSet rs) throws SQLException {
        Frete f = new Frete();
        f.setId    (rs.getInt   ("idfrete"));
        f.setNumero(rs.getString("numero"));
        f.setStatus(StatusFrete.fromCodigo(rs.getString("status")));
        f.setMunicipioOrigem (rs.getString("municipio_origem"));
        f.setUfOrigem        (rs.getString("uf_origem"));
        f.setMunicipioDestino(rs.getString("municipio_destino"));
        f.setUfDestino       (rs.getString("uf_destino"));
        f.setValorFrete(rs.getBigDecimal("valor_frete"));
        f.setValorTotal(rs.getBigDecimal("valor_total"));

        Date de = rs.getDate("data_emissao");
        if (de != null) f.setDataEmissao(de.toLocalDate());
        Date dp = rs.getDate("data_prev_entrega");
        if (dp != null) f.setDataPrevEntrega(dp.toLocalDate());

        Timestamp ts = rs.getTimestamp("data_saida");
        if (ts != null) f.setDataSaida(ts.toLocalDateTime());
        Timestamp te = rs.getTimestamp("data_entrega");
        if (te != null) f.setDataEntrega(te.toLocalDateTime());

        BigDecimal peso = rs.getBigDecimal("peso_kg");
        if (peso != null) f.setPesoKg(peso);

        Cliente rem  = new Cliente(); rem.setRazaoSocial(rs.getString("remetente_nome"));
        Cliente dest = new Cliente(); dest.setRazaoSocial(rs.getString("destinatario_nome"));
        Motorista m  = new Motorista(); m.setNome(rs.getString("motorista_nome"));
        Veiculo v    = new Veiculo();   v.setPlaca(rs.getString("veiculo_placa"));

        f.setRemetente(rem);
        f.setDestinatario(dest);
        f.setMotorista(m);
        f.setVeiculo(v);
        return f;
    }

    /** Mapeamento base sem joins. */
    private Frete mapearSimples(ResultSet rs) throws SQLException {
        Frete f = new Frete();
        f.setId           (rs.getInt   ("idfrete"));
        f.setNumero       (rs.getString("numero"));
        f.setStatus       (StatusFrete.fromCodigo(rs.getString("status")));
        f.setIdRemetente  (rs.getInt("id_remetente"));
        f.setIdDestinatario(rs.getInt("id_destinatario"));
        f.setIdMotorista  (rs.getInt("id_motorista"));
        f.setIdVeiculo    (rs.getInt("id_veiculo"));
        f.setMunicipioOrigem (rs.getString("municipio_origem"));
        f.setUfOrigem        (rs.getString("uf_origem"));
        f.setMunicipioDestino(rs.getString("municipio_destino"));
        f.setUfDestino       (rs.getString("uf_destino"));
        f.setDescricaoCarga  (rs.getString("descricao_carga"));
        f.setObservacao      (rs.getString("observacao"));
        f.setValorFrete  (getBDNotNull(rs, "valor_frete"));
        f.setAliquotaIcms(getBDNotNull(rs, "aliquota_icms"));
        f.setValorIcms   (getBDNotNull(rs, "valor_icms"));
        f.setValorTotal  (getBDNotNull(rs, "valor_total"));

        // IBS/CBS — Diferencial B (podem ser null em instalações sem a coluna)
        try { f.setAliquotaIbs(getBDNotNull(rs, "aliquota_ibs")); } catch (SQLException ignored) {}
        try { f.setValorIbs   (getBDNotNull(rs, "valor_ibs"));    } catch (SQLException ignored) {}
        try { f.setAliquotaCbs(getBDNotNull(rs, "aliquota_cbs")); } catch (SQLException ignored) {}
        try { f.setValorCbs   (getBDNotNull(rs, "valor_cbs"));    } catch (SQLException ignored) {}
        try { f.setTotalTributos(getBDNotNull(rs, "total_tributos")); } catch (SQLException ignored) {}
        try { f.setValorTotalEstimado(getBDNotNull(rs, "valor_total_estimado")); } catch (SQLException ignored) {}

        try {
            String tipoOperacao = rs.getString("tipo_operacao");
            if (tipoOperacao != null) f.setTipoOperacao(TipoOperacao.valueOf(tipoOperacao));
        } catch (SQLException | IllegalArgumentException ignored) {}
        try {
            String tipoDestinatario = rs.getString("tipo_destinatario");
            if (tipoDestinatario != null) f.setTipoDestinatario(TipoDestinatario.valueOf(tipoDestinatario));
        } catch (SQLException | IllegalArgumentException ignored) {}
        try {
            String statusFiscal = rs.getString("status_fiscal");
            if (statusFiscal != null) f.setStatusFiscal(StatusFiscal.valueOf(statusFiscal));
        } catch (SQLException | IllegalArgumentException ignored) {}
        try { f.setCfop(rs.getString("cfop")); } catch (SQLException ignored) {}
        try { f.setMotivoCfop(rs.getString("motivo_cfop")); } catch (SQLException ignored) {}
        try { f.setRegraFiscalAplicada(rs.getString("regra_fiscal_aplicada")); } catch (SQLException ignored) {}

        BigDecimal peso = rs.getBigDecimal("peso_kg");
        if (peso != null) f.setPesoKg(peso);

        int vol = rs.getInt("volumes");
        if (!rs.wasNull()) f.setVolumes(vol);

        Date de = rs.getDate("data_emissao");
        if (de != null) f.setDataEmissao(de.toLocalDate());
        Date dp = rs.getDate("data_prev_entrega");
        if (dp != null) f.setDataPrevEntrega(dp.toLocalDate());

        Timestamp ts = rs.getTimestamp("data_saida");
        if (ts != null) f.setDataSaida(ts.toLocalDateTime());
        Timestamp te = rs.getTimestamp("data_entrega");
        if (te != null) f.setDataEntrega(te.toLocalDateTime());

        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) f.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) f.setUpdatedAt(ua.toLocalDateTime());

        f.setCreatedBy(rs.getString("created_by"));
        f.setUpdatedBy(rs.getString("updated_by"));
        return f;
    }

    private OcorrenciaFrete mapearOcorrencia(ResultSet rs) throws SQLException {
        OcorrenciaFrete o = new OcorrenciaFrete();
        o.setId      (rs.getInt("idocorrencia"));
        o.setIdFrete (rs.getInt("id_frete"));
        o.setTipo    (TipoOcorrencia.fromCodigo(rs.getString("tipo")));
        o.setMunicipio  (rs.getString("municipio"));
        o.setUf         (rs.getString("uf"));
        o.setDescricao  (rs.getString("descricao"));
        o.setNomeRecebedor      (rs.getString("nome_recebedor"));
        o.setDocumentoRecebedor (rs.getString("documento_recebedor"));
        o.setCreatedBy  (rs.getString("created_by"));

        Timestamp dh = rs.getTimestamp("data_hora");
        if (dh != null) o.setDataHora(dh.toLocalDateTime());
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) o.setCreatedAt(ca.toLocalDateTime());
        return o;
    }

    /* ---- helpers ---- */

    private BigDecimal getBDNotNull(ResultSet rs, String col) throws SQLException {
        BigDecimal v = rs.getBigDecimal(col);
        return v != null ? v : BigDecimal.ZERO;
    }

    private void setBigDecimalNullable(PreparedStatement ps, int idx, BigDecimal v)
            throws SQLException {
        if (v != null) ps.setBigDecimal(idx, v);
        else           ps.setNull(idx, Types.NUMERIC);
    }

    private void setIntNullable(PreparedStatement ps, int idx, Integer v)
            throws SQLException {
        if (v != null) ps.setInt(idx, v);
        else           ps.setNull(idx, Types.INTEGER);
    }
}
