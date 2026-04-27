package br.com.gw.cliente;

import br.com.gw.Enums.TipoCliente;
import br.com.gw.nucleo.utils.ConexaoUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;


public class ClienteDAO {

    private static final Logger LOG = Logger.getLogger(ClienteDAO.class.getName());

    public List<Cliente> listar(String filtro, int pagina, int tamanhoPagina) throws SQLException {
        int offset = (pagina - 1) * tamanhoPagina;
        String sql = "SELECT * FROM cliente "
                   + "WHERE razao_social ILIKE ? "
                   + "ORDER BY razao_social "
                   + "LIMIT ? OFFSET ?";

        List<Cliente> lista = new ArrayList<>();
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + (filtro == null ? "" : filtro.trim()) + "%");
            ps.setInt(2, tamanhoPagina);
            ps.setInt(3, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        return lista;
    }

    public int contarTotal(String filtro) throws SQLException {
        String sql = "SELECT COUNT(*) FROM cliente WHERE razao_social ILIKE ?";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + (filtro == null ? "" : filtro.trim()) + "%");
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public Cliente buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM cliente WHERE idcliente = ?";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapear(rs) : null;
            }
        }
    }

    public boolean existeCnpj(String cnpj, int ignorarId) throws SQLException {
        String sql = "SELECT 1 FROM cliente WHERE cnpj = ? AND idcliente <> ?";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cnpj.replaceAll("[^0-9]", ""));
            ps.setInt(2, ignorarId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    public boolean possuiFretes(int idcliente) throws SQLException {
        String sql = "SELECT 1 FROM frete "
                   + "WHERE id_remetente = ? OR id_destinatario = ? LIMIT 1";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idcliente);
            ps.setInt(2, idcliente);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    public void inserir(Cliente c) throws SQLException {
        String sql = "INSERT INTO cliente "
                   + "(razao_social, nome_fantasia, cnpj, inscricao_est, tipo, "
                   + " logradouro, numero_end, complemento, bairro, municipio, "
                   + " uf, cep, telefone, email, is_ativo) "
                   + "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
 
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            preencherStatement(ps, c);
            ps.executeUpdate();
        }
    }

    public void atualizar(Cliente c) throws SQLException {
        String sql = "UPDATE cliente SET "
                   + "razao_social=?, nome_fantasia=?, cnpj=?, inscricao_est=?, tipo=?, "
                   + "logradouro=?, numero_end=?, complemento=?, bairro=?, municipio=?, "
                   + "uf=?, cep=?, telefone=?, email=?, is_ativo=?, "
                   + "updated_at=NOW() "
                   + "WHERE idcliente=?";
 
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            preencherStatement(ps, c);
            ps.setInt(16, c.getId());  
            ps.executeUpdate();
        }
    }

    public void excluir(int id) throws SQLException {
        String sql = "DELETE FROM cliente WHERE idcliente = ?";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ...existing code...
    public List<Cliente> listarAtivos() throws SQLException {
        List<Cliente> lista = new ArrayList<>();
        String sql = "SELECT idcliente, razao_social, nome_fantasia, cnpj, inscricao_est, tipo, logradouro, numero_end, complemento, bairro, municipio, uf, cep, telefone, email, is_ativo FROM cliente WHERE is_ativo = TRUE ORDER BY razao_social";
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapear(rs));
            }
        }
        return lista;
    }
// ...existing code...

    private void preencherStatement(PreparedStatement ps, Cliente c) throws SQLException {
        ps.setString(1,  c.getRazaoSocial());
        ps.setString(2,  c.getNomeFantasia());
        String cnpjNums = c.getCnpj() == null ? null : c.getCnpj().replaceAll("[^0-9]", "");
        ps.setString(3,  cnpjNums);
        ps.setString(4,  c.getInscricaoEst());
        ps.setString(5,  String.valueOf(c.getTipo().getCodigo()));
        ps.setString(6,  c.getLogradouro());
        ps.setString(7,  c.getNumeroEnd());
        ps.setString(8,  c.getComplemento());
        ps.setString(9,  c.getBairro());
        ps.setString(10, c.getMunicipio());
        ps.setString(11, c.getUf());
        ps.setString(12, c.getCep());
        ps.setString(13, c.getTelefone());
        ps.setString(14, c.getEmail());
        ps.setBoolean(15, c.isAtivo());
    }

    private Cliente mapear(ResultSet rs) throws SQLException {
        Cliente c = new Cliente();
        c.setId(rs.getInt("idcliente"));
        c.setRazaoSocial(rs.getString("razao_social"));
        c.setNomeFantasia(rs.getString("nome_fantasia"));
        c.setCnpj(rs.getString("cnpj"));
        c.setInscricaoEst(rs.getString("inscricao_est"));
        String tipoStr = rs.getString("tipo");
        c.setTipo(tipoStr != null ? TipoCliente.fromCodigo(tipoStr) : TipoCliente.AMBOS);
        c.setLogradouro(rs.getString("logradouro"));
        c.setNumeroEnd(rs.getString("numero_end"));
        c.setComplemento(rs.getString("complemento"));
        c.setBairro(rs.getString("bairro"));
        c.setMunicipio(rs.getString("municipio"));
        c.setUf(rs.getString("uf"));
        c.setCep(rs.getString("cep"));
        c.setTelefone(rs.getString("telefone"));
        c.setEmail(rs.getString("email"));
        c.setAtivo(rs.getBoolean("is_ativo"));
        return c;
    }

}