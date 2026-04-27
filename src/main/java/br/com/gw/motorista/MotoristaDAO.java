package br.com.gw.motorista;

import br.com.gw.Enums.CategoriaCNH;
import br.com.gw.Enums.StatusMotorista;
import br.com.gw.Enums.TipoVinculo;
import br.com.gw.nucleo.utils.ConexaoUtil;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

public class MotoristaDAO {

    private static final Logger LOG = Logger.getLogger(MotoristaDAO.class.getName());

    public List<Motorista> listar(String filtro, int pagina, int tamPagina) throws SQLException {
        int offset = (pagina - 1) * tamPagina;
        String sql = "SELECT * FROM motorista WHERE nome ILIKE ? ORDER BY nome LIMIT ? OFFSET ?";
        List<Motorista> lista = new ArrayList<>();
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
        String sql = "SELECT COUNT(*) FROM motorista WHERE nome ILIKE ?";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + (filtro == null ? "" : filtro.trim()) + "%");
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : 0; }
        }
    }

    public Motorista buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM motorista WHERE idmotorista = ?";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? mapear(rs) : null; }
        }
    }

    public boolean existeCpf(String cpf, int ignorarId) throws SQLException {
        String sql = "SELECT 1 FROM motorista WHERE cpf = ? AND idmotorista <> ?";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cpf.replaceAll("[^0-9]", ""));
            ps.setInt(2, ignorarId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    public boolean possuiFreteAtivo(int idMotorista) throws SQLException {
        String sql = "SELECT 1 FROM frete WHERE id_motorista = ? AND status IN ('E','S','T') LIMIT 1";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idMotorista);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    public void inserir(Motorista m) throws SQLException {
        String sql = "INSERT INTO motorista "
                   + "(nome, cpf, data_nascimento, telefone, cnh_numero, cnh_categoria, "
                   + " cnh_validade, tipo_vinculo, status) "
                   + "VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            preencher(ps, m);
            ps.executeUpdate();
        }
    }

    public void atualizar(Motorista m) throws SQLException {
        String sql = "UPDATE motorista SET "
                   + "nome=?, cpf=?, data_nascimento=?, telefone=?, cnh_numero=?, "
                   + "cnh_categoria=?, cnh_validade=?, tipo_vinculo=?, status=?, "
                   + "updated_at=NOW() WHERE idmotorista=?";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            preencher(ps, m);
            ps.setInt(10, m.getId());
            ps.executeUpdate();
        }
    }

    public void excluir(int id) throws SQLException {
        String sql = "DELETE FROM motorista WHERE idmotorista = ?";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    public List<Motorista> listarAtivos() throws SQLException {
        // Reutiliza o método listar para evitar duplicação do mapeamento do ResultSet.
        List<Motorista> todos = listar("%", 1, Integer.MAX_VALUE);
        List<Motorista> ativos = new ArrayList<>();
        for (Motorista m : todos) {
            if (m != null && m.getStatus() == StatusMotorista.ATIVO) {
                ativos.add(m);
            }
        }
        return ativos;
    }

    private void preencher(PreparedStatement ps, Motorista m) throws SQLException {
        ps.setString(1, m.getNome());
        ps.setString(2, m.getCpf() == null ? null : m.getCpf().replaceAll("[^0-9]",""));
        ps.setObject(3, m.getDataNascimento()); 
        ps.setString(4, m.getTelefone());
        ps.setString(5, m.getCnhNumero());
        ps.setString(6, m.getCnhCategoria() == null ? "B" : String.valueOf(m.getCnhCategoria().getCodigo()));
        ps.setObject(7, m.getCnhValidade());
        ps.setString(8, m.getTipoVinculo() == null ? "F" : String.valueOf(m.getTipoVinculo().getCodigo()));
        ps.setString(9, m.getStatus() == null ? "A" : String.valueOf(m.getStatus().getCodigo()));
    }

    private Motorista mapear(ResultSet rs) throws SQLException {
        Motorista m = new Motorista();
        m.setId(rs.getInt("idmotorista"));
        m.setNome(rs.getString("nome"));
        m.setCpf(rs.getString("cpf"));
        Date dn = rs.getDate("data_nascimento");
        if (dn != null) m.setDataNascimento(dn.toLocalDate());
        m.setTelefone(rs.getString("telefone"));
        m.setCnhNumero(rs.getString("cnh_numero"));
        String cat = rs.getString("cnh_categoria");
        if (cat != null) m.setCnhCategoria(CategoriaCNH.fromCodigo(cat));
        Date cv = rs.getDate("cnh_validade");
        if (cv != null) m.setCnhValidade(cv.toLocalDate());
        String vinc = rs.getString("tipo_vinculo");
        if (vinc != null) m.setTipoVinculo(TipoVinculo.fromCodigo(vinc));
        String stat = rs.getString("status");
        if (stat != null) m.setStatus(StatusMotorista.fromCodigo(stat));
        return m;
    }
}