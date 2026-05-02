package br.com.gw.relatorio;

import br.com.gw.Enums.StatusFrete;
import br.com.gw.Enums.TipoVeiculo;
import br.com.gw.Enums.TipoOcorrencia;
import br.com.gw.nucleo.utils.ConexaoUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO exclusivo dos relatórios.
 * Mantém todas as consultas SQL fora do Controller/BO e entrega objetos prontos para o Jasper.
 */
public class RelatorioDAO {

    private static final DateTimeFormatter FMT_DATA =
        DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter FMT_DATA_HORA =
        DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    public List<FreteAbertoRelatorio> listarFretesEmAberto() throws SQLException {
        final String sql =
            "SELECT f.numero, f.status, f.data_prev_entrega, " +
            "       rem.razao_social AS remetente, dest.razao_social AS destinatario, " +
            "       m.nome AS motorista, v.placa, " +
            "       f.municipio_destino, f.uf_destino, f.valor_total, " +
            "       GREATEST(0, CURRENT_DATE - f.data_prev_entrega) AS dias_atraso " +
            "FROM frete f " +
            "JOIN cliente rem ON f.id_remetente = rem.idcliente " +
            "JOIN cliente dest ON f.id_destinatario = dest.idcliente " +
            "JOIN motorista m ON f.id_motorista = m.idmotorista " +
            "JOIN veiculo v ON f.id_veiculo = v.idveiculo " +
            "WHERE f.status IN ('E','S','T') " +
            "ORDER BY dias_atraso DESC, f.data_prev_entrega ASC, f.numero ASC";

        List<FreteAbertoRelatorio> lista = new ArrayList<>();
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                FreteAbertoRelatorio linha = new FreteAbertoRelatorio();
                linha.setNumero(rs.getString("numero"));
                linha.setNomeRemetente(rs.getString("remetente"));
                linha.setNomeDestinatario(rs.getString("destinatario"));
                linha.setNomeMotorista(rs.getString("motorista"));
                linha.setDestino(local(rs.getString("municipio_destino"), rs.getString("uf_destino")));
                linha.setDataPrevista(formatarData(rs.getDate("data_prev_entrega")));
                linha.setDiasAtraso(rs.getInt("dias_atraso"));
                linha.setStatusDescricao(StatusFrete.fromCodigo(rs.getString("status")).getDescricao());
                linha.setPlaca(rs.getString("placa"));
                linha.setValorTotal(getBigDecimal(rs, "valor_total"));
                lista.add(linha);
            }
        }
        return lista;
    }

    public List<RomaneioCargaRelatorio> listarRomaneio(int idMotorista, LocalDate dataOperacao)
            throws SQLException {
        final String sql =
            "SELECT f.numero, rem.razao_social AS remetente, dest.razao_social AS destinatario, " +
            "       f.municipio_destino, f.uf_destino, f.peso_kg, f.volumes, f.valor_total " +
            "FROM frete f " +
            "JOIN cliente rem ON f.id_remetente = rem.idcliente " +
            "JOIN cliente dest ON f.id_destinatario = dest.idcliente " +
            "WHERE f.id_motorista = ? " +
            "  AND COALESCE(CAST(f.data_saida AS DATE), f.data_emissao) = ? " +
            "  AND f.status <> 'C' " +
            "ORDER BY f.numero ASC";

        List<RomaneioCargaRelatorio> lista = new ArrayList<>();
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idMotorista);
            ps.setDate(2, Date.valueOf(dataOperacao));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RomaneioCargaRelatorio linha = new RomaneioCargaRelatorio();
                    linha.setNumero(rs.getString("numero"));
                    linha.setNomeRemetente(rs.getString("remetente"));
                    linha.setNomeDestinatario(rs.getString("destinatario"));
                    linha.setDestino(local(rs.getString("municipio_destino"), rs.getString("uf_destino")));
                    linha.setPesoKg(getBigDecimal(rs, "peso_kg"));
                    linha.setVolumes(getInteger(rs, "volumes"));
                    linha.setValorTotal(getBigDecimal(rs, "valor_total"));
                    lista.add(linha);
                }
            }
        }
        return lista;
    }

    public RomaneioCabecalho buscarCabecalhoRomaneio(int idMotorista, LocalDate dataOperacao)
            throws SQLException {
        RomaneioCabecalho cabecalho = new RomaneioCabecalho();

        final String sqlMotorista =
            "SELECT nome, cpf, cnh_numero, cnh_categoria, cnh_validade " +
            "FROM motorista WHERE idmotorista = ?";

        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sqlMotorista)) {
            ps.setInt(1, idMotorista);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                cabecalho.setMotoristaNome(rs.getString("nome"));
                cabecalho.setMotoristaCpf(mascaraCpf(rs.getString("cpf")));
                cabecalho.setMotoristaCnh(
                    rs.getString("cnh_numero") + " / " +
                    rs.getString("cnh_categoria") + " / validade " +
                    formatarData(rs.getDate("cnh_validade")));
            }
        }

        cabecalho.setVeiculoPlacas(buscarPlacasRomaneio(idMotorista, dataOperacao));
        return cabecalho;
    }

    public DocumentoFreteRelatorio buscarDocumentoFrete(int idFrete) throws SQLException {
        final String sql =
            "SELECT f.*, " +
            "       rem.razao_social AS rem_razao, rem.cnpj AS rem_cnpj, " +
            "       rem.logradouro AS rem_logradouro, rem.numero_end AS rem_numero, " +
            "       rem.bairro AS rem_bairro, rem.municipio AS rem_municipio, " +
            "       rem.uf AS rem_uf, rem.cep AS rem_cep, " +
            "       dest.razao_social AS dest_razao, dest.cnpj AS dest_cnpj, " +
            "       dest.logradouro AS dest_logradouro, dest.numero_end AS dest_numero, " +
            "       dest.bairro AS dest_bairro, dest.municipio AS dest_municipio, " +
            "       dest.uf AS dest_uf, dest.cep AS dest_cep, " +
            "       m.nome AS motorista_nome, m.cpf AS motorista_cpf, " +
            "       m.cnh_numero, m.cnh_categoria, m.cnh_validade, " +
            "       v.placa, v.tipo AS veiculo_tipo, v.capacidade_kg " +
            "FROM frete f " +
            "JOIN cliente rem ON f.id_remetente = rem.idcliente " +
            "JOIN cliente dest ON f.id_destinatario = dest.idcliente " +
            "JOIN motorista m ON f.id_motorista = m.idmotorista " +
            "JOIN veiculo v ON f.id_veiculo = v.idveiculo " +
            "WHERE f.idfrete = ?";

        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idFrete);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return mapearDocumentoFrete(rs);
            }
        }
    }

    public List<FreteClienteRelatorio> listarFretesPorCliente(int idCliente,
            LocalDate dataInicio, LocalDate dataFim) throws SQLException {
        final String sql =
            "SELECT f.numero, f.data_emissao, f.status, f.valor_total, " +
            "       f.municipio_origem, f.uf_origem, f.municipio_destino, f.uf_destino, " +
            "       rem.razao_social AS remetente, dest.razao_social AS destinatario, " +
            "       m.nome AS motorista, " +
            "       CASE WHEN f.id_remetente = ? THEN 'Remetente' ELSE 'Destinatario' END AS papel_cliente, " +
            "       CASE WHEN f.id_remetente = ? THEN dest.razao_social ELSE rem.razao_social END AS contraparte " +
            "FROM frete f " +
            "JOIN cliente rem ON f.id_remetente = rem.idcliente " +
            "JOIN cliente dest ON f.id_destinatario = dest.idcliente " +
            "JOIN motorista m ON f.id_motorista = m.idmotorista " +
            "WHERE (f.id_remetente = ? OR f.id_destinatario = ?) " +
            "  AND f.data_emissao BETWEEN ? AND ? " +
            "ORDER BY f.data_emissao ASC, f.numero ASC";

        List<FreteClienteRelatorio> lista = new ArrayList<>();
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idCliente);
            ps.setInt(2, idCliente);
            ps.setInt(3, idCliente);
            ps.setInt(4, idCliente);
            ps.setDate(5, Date.valueOf(dataInicio));
            ps.setDate(6, Date.valueOf(dataFim));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    FreteClienteRelatorio linha = new FreteClienteRelatorio();
                    linha.setNumero(rs.getString("numero"));
                    linha.setDataEmissao(formatarData(rs.getDate("data_emissao")));
                    linha.setPapelCliente(rs.getString("papel_cliente"));
                    linha.setContraparte(rs.getString("contraparte"));
                    linha.setOrigem(local(rs.getString("municipio_origem"), rs.getString("uf_origem")));
                    linha.setDestino(local(rs.getString("municipio_destino"), rs.getString("uf_destino")));
                    linha.setMotorista(rs.getString("motorista"));
                    linha.setStatusDescricao(StatusFrete.fromCodigo(rs.getString("status")).getDescricao());
                    linha.setValorTotal(getBigDecimal(rs, "valor_total"));
                    lista.add(linha);
                }
            }
        }
        return lista;
    }

    public List<OcorrenciaPeriodoRelatorio> listarOcorrenciasPorPeriodo(
            LocalDate dataInicio, LocalDate dataFim) throws SQLException {
        final String sql =
            "SELECT o.data_hora, o.tipo, o.municipio, o.uf, o.descricao, " +
            "       o.nome_recebedor, o.documento_recebedor, " +
            "       f.numero, f.status AS status_frete, m.nome AS motorista, v.placa " +
            "FROM ocorrencia_frete o " +
            "JOIN frete f ON o.id_frete = f.idfrete " +
            "JOIN motorista m ON f.id_motorista = m.idmotorista " +
            "JOIN veiculo v ON f.id_veiculo = v.idveiculo " +
            "WHERE CAST(o.data_hora AS DATE) BETWEEN ? AND ? " +
            "ORDER BY o.data_hora ASC, f.numero ASC";

        List<OcorrenciaPeriodoRelatorio> lista = new ArrayList<>();
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(dataInicio));
            ps.setDate(2, Date.valueOf(dataFim));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OcorrenciaPeriodoRelatorio linha = new OcorrenciaPeriodoRelatorio();
                    linha.setNumeroFrete(rs.getString("numero"));
                    linha.setDataHora(formatarDataHora(rs.getTimestamp("data_hora")));
                    linha.setTipoDescricao(TipoOcorrencia.fromCodigo(rs.getString("tipo")).getDescricao());
                    linha.setLocalizacao(local(rs.getString("municipio"), rs.getString("uf")));
                    linha.setDescricao(rs.getString("descricao"));
                    linha.setMotorista(rs.getString("motorista"));
                    linha.setPlaca(rs.getString("placa"));
                    linha.setStatusFrete(StatusFrete.fromCodigo(rs.getString("status_frete")).getDescricao());
                    linha.setRecebedor(recebedor(rs));
                    lista.add(linha);
                }
            }
        }
        return lista;
    }

    public List<DesempenhoMotoristaRelatorio> listarDesempenhoMotoristas(
            LocalDate dataInicio, LocalDate dataFim) throws SQLException {
        final String sql =
            "SELECT m.nome AS motorista, m.cpf, " +
            "       COUNT(f.idfrete) AS entregas, " +
            "       SUM(CASE WHEN CAST(f.data_entrega AS DATE) <= f.data_prev_entrega THEN 1 ELSE 0 END) AS entregas_no_prazo, " +
            "       SUM(CASE WHEN CAST(f.data_entrega AS DATE) > f.data_prev_entrega THEN 1 ELSE 0 END) AS entregas_atrasadas, " +
            "       COALESCE(AVG(GREATEST(0, CAST(f.data_entrega AS DATE) - f.data_prev_entrega)), 0) AS media_dias_atraso, " +
            "       COALESCE(SUM(f.peso_kg), 0) AS peso_total_kg, " +
            "       COALESCE(SUM(f.volumes), 0) AS volumes_total, " +
            "       COALESCE(SUM(f.valor_total), 0) AS valor_total " +
            "FROM frete f " +
            "JOIN motorista m ON f.id_motorista = m.idmotorista " +
            "WHERE f.status = 'R' " +
            "  AND f.data_entrega IS NOT NULL " +
            "  AND CAST(f.data_entrega AS DATE) BETWEEN ? AND ? " +
            "GROUP BY m.idmotorista, m.nome, m.cpf " +
            "ORDER BY entregas DESC, entregas_no_prazo DESC, valor_total DESC";

        List<DesempenhoMotoristaRelatorio> lista = new ArrayList<>();
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(dataInicio));
            ps.setDate(2, Date.valueOf(dataFim));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DesempenhoMotoristaRelatorio linha = new DesempenhoMotoristaRelatorio();
                    int entregas = rs.getInt("entregas");
                    int noPrazo = rs.getInt("entregas_no_prazo");

                    linha.setMotorista(rs.getString("motorista"));
                    linha.setCpf(mascaraCpf(rs.getString("cpf")));
                    linha.setEntregas(entregas);
                    linha.setEntregasNoPrazo(noPrazo);
                    linha.setEntregasAtrasadas(rs.getInt("entregas_atrasadas"));
                    linha.setPercentualNoPrazo(percentual(noPrazo, entregas));
                    linha.setMediaDiasAtraso(getBigDecimal(rs, "media_dias_atraso"));
                    linha.setPesoTotalKg(getBigDecimal(rs, "peso_total_kg"));
                    linha.setVolumesTotal(rs.getInt("volumes_total"));
                    linha.setValorTotal(getBigDecimal(rs, "valor_total"));
                    lista.add(linha);
                }
            }
        }
        return lista;
    }

    public List<RelatorioFreteOpcao> listarFretesParaSelecao(int limite) throws SQLException {
        final String sql =
            "SELECT f.idfrete, f.numero, f.status, " +
            "       rem.razao_social AS remetente, dest.razao_social AS destinatario " +
            "FROM frete f " +
            "JOIN cliente rem ON f.id_remetente = rem.idcliente " +
            "JOIN cliente dest ON f.id_destinatario = dest.idcliente " +
            "ORDER BY f.idfrete DESC LIMIT ?";

        List<RelatorioFreteOpcao> lista = new ArrayList<>();
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limite);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RelatorioFreteOpcao opcao = new RelatorioFreteOpcao();
                    opcao.setId(rs.getInt("idfrete"));
                    opcao.setNumero(rs.getString("numero"));
                    opcao.setDescricao(
                        rs.getString("numero") + " - " +
                        rs.getString("remetente") + " -> " +
                        rs.getString("destinatario") + " (" +
                        StatusFrete.fromCodigo(rs.getString("status")).getDescricao() + ")");
                    lista.add(opcao);
                }
            }
        }
        return lista;
    }

    private String buscarPlacasRomaneio(int idMotorista, LocalDate dataOperacao)
            throws SQLException {
        final String sql =
            "SELECT DISTINCT v.placa " +
            "FROM frete f " +
            "JOIN veiculo v ON f.id_veiculo = v.idveiculo " +
            "WHERE f.id_motorista = ? " +
            "  AND COALESCE(CAST(f.data_saida AS DATE), f.data_emissao) = ? " +
            "  AND f.status <> 'C' " +
            "ORDER BY v.placa";

        List<String> placas = new ArrayList<>();
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idMotorista);
            ps.setDate(2, Date.valueOf(dataOperacao));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    placas.add(rs.getString("placa"));
                }
            }
        }
        return placas.isEmpty() ? "Sem fretes na data" : juntar(placas);
    }

    private DocumentoFreteRelatorio mapearDocumentoFrete(ResultSet rs) throws SQLException {
        DocumentoFreteRelatorio doc = new DocumentoFreteRelatorio();
        doc.setNumero(rs.getString("numero"));
        doc.setStatusDescricao(StatusFrete.fromCodigo(rs.getString("status")).getDescricao());
        doc.setDataEmissao(formatarData(rs.getDate("data_emissao")));
        doc.setDataPrevista(formatarData(rs.getDate("data_prev_entrega")));
        doc.setDataSaida(formatarDataHora(rs.getTimestamp("data_saida")));
        doc.setDataEntrega(formatarDataHora(rs.getTimestamp("data_entrega")));

        doc.setRemetenteRazao(rs.getString("rem_razao"));
        doc.setRemetenteCnpj(mascaraCnpj(rs.getString("rem_cnpj")));
        doc.setRemetenteEndereco(endereco(rs, "rem"));
        doc.setDestinatarioRazao(rs.getString("dest_razao"));
        doc.setDestinatarioCnpj(mascaraCnpj(rs.getString("dest_cnpj")));
        doc.setDestinatarioEndereco(endereco(rs, "dest"));

        doc.setMotoristaNome(rs.getString("motorista_nome"));
        doc.setMotoristaCpf(mascaraCpf(rs.getString("motorista_cpf")));
        doc.setMotoristaCnh(
            rs.getString("cnh_numero") + " / " +
            rs.getString("cnh_categoria") + " / validade " +
            formatarData(rs.getDate("cnh_validade")));
        doc.setVeiculoPlaca(rs.getString("placa"));
        doc.setVeiculoTipo(TipoVeiculo.fromCodigo(rs.getString("veiculo_tipo")).getDescricao());
        doc.setVeiculoCapacidadeKg(getBigDecimal(rs, "capacidade_kg"));

        doc.setOrigem(local(rs.getString("municipio_origem"), rs.getString("uf_origem")));
        doc.setDestino(local(rs.getString("municipio_destino"), rs.getString("uf_destino")));
        doc.setDescricaoCarga(rs.getString("descricao_carga"));
        doc.setPesoKg(getBigDecimal(rs, "peso_kg"));
        doc.setVolumes(getInteger(rs, "volumes"));

        doc.setValorFrete(getBigDecimal(rs, "valor_frete"));
        doc.setAliquotaIcms(getBigDecimal(rs, "aliquota_icms"));
        doc.setValorIcms(getBigDecimal(rs, "valor_icms"));
        doc.setAliquotaIbs(getBigDecimal(rs, "aliquota_ibs"));
        doc.setValorIbs(getBigDecimal(rs, "valor_ibs"));
        doc.setAliquotaCbs(getBigDecimal(rs, "aliquota_cbs"));
        doc.setValorCbs(getBigDecimal(rs, "valor_cbs"));
        doc.setValorTotal(getBigDecimal(rs, "valor_total"));
        doc.setObservacao(rs.getString("observacao"));
        return doc;
    }

    private String endereco(ResultSet rs, String prefixo) throws SQLException {
        List<String> partes = new ArrayList<>();
        adicionar(partes, rs.getString(prefixo + "_logradouro"));
        adicionar(partes, rs.getString(prefixo + "_numero"));
        adicionar(partes, rs.getString(prefixo + "_bairro"));
        adicionar(partes, local(rs.getString(prefixo + "_municipio"), rs.getString(prefixo + "_uf")));
        adicionar(partes, rs.getString(prefixo + "_cep"));
        return partes.isEmpty() ? "Endereco nao informado" : juntar(partes);
    }

    private String recebedor(ResultSet rs) throws SQLException {
        String nome = rs.getString("nome_recebedor");
        String documento = rs.getString("documento_recebedor");
        if ((nome == null || nome.trim().isEmpty())
                && (documento == null || documento.trim().isEmpty())) {
            return "";
        }
        if (documento == null || documento.trim().isEmpty()) {
            return nome;
        }
        if (nome == null || nome.trim().isEmpty()) {
            return documento;
        }
        return nome + " - " + documento;
    }

    private void adicionar(List<String> partes, String valor) {
        if (valor != null && !valor.trim().isEmpty()) {
            partes.add(valor.trim());
        }
    }

    private String local(String municipio, String uf) {
        String mun = municipio == null ? "" : municipio.trim();
        String sigla = uf == null ? "" : uf.trim();
        if (mun.isEmpty()) {
            return sigla;
        }
        if (sigla.isEmpty()) {
            return mun;
        }
        return mun + "/" + sigla;
    }

    private String juntar(List<String> partes) {
        StringBuilder sb = new StringBuilder();
        for (String parte : partes) {
            if (sb.length() > 0) {
                sb.append(" - ");
            }
            sb.append(parte);
        }
        return sb.toString();
    }

    private String formatarData(Date data) {
        return data != null ? data.toLocalDate().format(FMT_DATA) : "";
    }

    private String formatarDataHora(Timestamp dataHora) {
        return dataHora != null ? dataHora.toLocalDateTime().format(FMT_DATA_HORA) : "";
    }

    private BigDecimal getBigDecimal(ResultSet rs, String coluna) throws SQLException {
        BigDecimal valor = rs.getBigDecimal(coluna);
        return valor != null ? valor : BigDecimal.ZERO;
    }

    private BigDecimal percentual(int parte, int total) {
        if (total == 0) {
            return BigDecimal.ZERO;
        }
        return new BigDecimal(parte)
            .multiply(new BigDecimal("100"))
            .divide(new BigDecimal(total), 2, java.math.RoundingMode.HALF_EVEN);
    }

    private Integer getInteger(ResultSet rs, String coluna) throws SQLException {
        int valor = rs.getInt(coluna);
        return rs.wasNull() ? null : valor;
    }

    private String mascaraCpf(String cpf) {
        if (cpf == null) return "";
        String d = cpf.replaceAll("[^0-9]", "");
        if (d.length() != 11) return cpf;
        return d.substring(0, 3) + "." + d.substring(3, 6) + "." +
               d.substring(6, 9) + "-" + d.substring(9);
    }

    private String mascaraCnpj(String cnpj) {
        if (cnpj == null) return "";
        String d = cnpj.replaceAll("[^0-9]", "");
        if (d.length() != 14) return cnpj;
        return d.substring(0, 2) + "." + d.substring(2, 5) + "." +
               d.substring(5, 8) + "/" + d.substring(8, 12) + "-" +
               d.substring(12);
    }
}
