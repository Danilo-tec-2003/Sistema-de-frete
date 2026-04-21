package br.com.gw.nucleo.login;

import br.com.gw.nucleo.utils.ConexaoUtil;

import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Logger;

/**
 * Único lugar onde SQL de login é executado.
 * Nunca contém regra de negócio — só acessa o banco.
 */
public class LoginDAO {

    private static final Logger LOG = Logger.getLogger(LoginDAO.class.getName());

    /**
     * Busca usuário ativo por login + senha (SHA-256).
     * @return Usuario preenchido ou null se não encontrado.
     */
    public Usuario buscarPorLoginSenha(String login, String senha) throws SQLException {
        String hash = sha256(senha);
        String sql  = "SELECT idusuario, nome, login FROM usuario "
                    + "WHERE login = ? AND senha = ? AND is_ativo = TRUE";
 
        try (Connection conn = ConexaoUtil.getConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {
 
            ps.setString(1, login);
            ps.setString(2, hash);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Usuario(
                        rs.getInt("idusuario"),
                        rs.getString("nome"),
                        rs.getString("login")
                    );
                }
            }
        }
        return null;
    }
    

    // -----------------------------------------------------------------------
    private static String sha256(String texto) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(texto.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            LOG.severe("Erro ao calcular SHA-256: " + e.getMessage());
            throw new RuntimeException("Erro interno ao processar senha", e);
        }
    }
}