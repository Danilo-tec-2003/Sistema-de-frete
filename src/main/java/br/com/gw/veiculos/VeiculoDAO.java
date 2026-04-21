package br.com.gw.veiculos;

import br.com.gw.Enums.StatusVeiculo;
import br.com.gw.Enums.TipoVeiculo;
import br.com.gw.nucleo.utils.ConexaoUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

public class VeiculoDAO {

    private static final Logger LOG = Logger.getLogger(VeiculoDAO.class.getName());

    public List<Veiculo> listar(String filtro, int pagina, int tamPagina) throws SQLException {
        int offset = (pagina - 1) * tamPagina;
        String sql = "SELECT * FROM veiculo WHERE placa ILIKE ? ORDER BY placa LIMIT ? OFFSET ?";
        List<Veiculo> lista = new ArrayList<>();
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + (filtro == null ? "" : filtro.trim()) + "%");
            ps.setInt(2, tamPagina);
            ps.setInt(3, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        return lista;
    }

    public int contarTotal(String filtro) throws SQLException {
        String sql = "SELECT COUNT(*) FROM veiculo WHERE placa ILIKE ?";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + (filtro == null ? "" : filtro.trim()) + "%");
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : 0; }
        }
    }

    public Veiculo buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM veiculo WHERE idveiculo = ?";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? mapear(rs) : null; }
        }
    }

    public boolean existePlaca(String placa, int ignorarId) throws SQLException {
        String sql = "SELECT 1 FROM veiculo WHERE placa = ? AND idveiculo <> ?";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, placa.toUpperCase().trim());
            ps.setInt(2, ignorarId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    public boolean estaEmViagem(int idVeiculo) throws SQLException {
        String sql = "SELECT 1 FROM frete WHERE id_veiculo = ? AND status = 'T' LIMIT 1";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idVeiculo);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    public void inserir(Veiculo v) throws SQLException {
        String sql = "INSERT INTO veiculo "
                   + "(placa, rntrc, ano_fabricacao, tipo, tara_kg, capacidade_kg, volume_m3, status) "
                   + "VALUES (?,?,?,?,?,?,?,?)";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            preencher(ps, v);
            ps.executeUpdate();
        }
    }

    public void atualizar(Veiculo v) throws SQLException {
        String sql = "UPDATE veiculo SET "
                   + "placa=?, rntrc=?, ano_fabricacao=?, tipo=?, tara_kg=?, "
                   + "capacidade_kg=?, volume_m3=?, status=?, updated_at=NOW() "
                   + "WHERE idveiculo=?";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            preencher(ps, v);
            ps.setInt(9, v.getId());
            ps.executeUpdate();
        }
    }

    public void excluir(int id) throws SQLException {
        String sql = "DELETE FROM veiculo WHERE idveiculo = ?";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private void preencher(PreparedStatement ps, Veiculo v) throws SQLException {
        ps.setString(1, v.getPlaca() == null ? null : v.getPlaca().toUpperCase().trim());
        ps.setString(2, v.getRntrc());
        if (v.getAnoFabricacao() != null) ps.setInt(3, v.getAnoFabricacao());
        else ps.setNull(3, Types.SMALLINT);
        ps.setString(4, v.getTipo() == null ? "K" : String.valueOf(v.getTipo().getCodigo()));
        ps.setBigDecimal(5, v.getTaraKg());
        ps.setBigDecimal(6, v.getCapacidadeKg());
        ps.setBigDecimal(7, v.getVolumeM3());
        ps.setString(8, v.getStatus() == null ? "D" : String.valueOf(v.getStatus().getCodigo()));
    }

    private Veiculo mapear(ResultSet rs) throws SQLException {
        Veiculo v = new Veiculo();
        v.setId(rs.getInt("idveiculo"));
        v.setPlaca(rs.getString("placa"));
        v.setRntrc(rs.getString("rntrc"));
        int ano = rs.getInt("ano_fabricacao");
        if (!rs.wasNull()) v.setAnoFabricacao(ano);
        String tipo = rs.getString("tipo");
        if (tipo != null) v.setTipo(TipoVeiculo.fromCodigo(tipo));
        v.setTaraKg(rs.getBigDecimal("tara_kg"));
        v.setCapacidadeKg(rs.getBigDecimal("capacidade_kg"));
        v.setVolumeM3(rs.getBigDecimal("volume_m3"));
        String stat = rs.getString("status");
        if (stat != null) v.setStatus(StatusVeiculo.fromCodigo(stat));
        return v;
    }
}