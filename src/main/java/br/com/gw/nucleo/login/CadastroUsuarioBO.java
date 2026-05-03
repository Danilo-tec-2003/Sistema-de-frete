package br.com.gw.nucleo.login;

import br.com.gw.nucleo.login.Usuario;
import br.com.gw.nucleo.exception.NegocioException;

import java.sql.SQLException;
import java.util.logging.Logger;

public class CadastroUsuarioBO {

    private static final Logger LOG = Logger.getLogger(CadastroUsuarioBO.class.getName());
    private final LoginDAO dao = new LoginDAO();

    public void cadastrar(String nome, String login, String senha, String confirmaSenha)
            throws NegocioException {

        // Validações
        if (nome == null || nome.trim().isEmpty())
            throw new NegocioException("O nome é obrigatório.");

        if (login == null || login.trim().isEmpty())
            throw new NegocioException("O login é obrigatório.");

        if (login.trim().length() < 4)
            throw new NegocioException("O login deve ter pelo menos 4 caracteres.");

        if (senha == null || senha.isEmpty())
            throw new NegocioException("A senha é obrigatória.");

        if (senha.length() < 6)
            throw new NegocioException("A senha deve ter pelo menos 6 caracteres.");

        if (!senha.equals(confirmaSenha))
            throw new NegocioException("As senhas não coincidem.");

        try {
            if (dao.loginJaExiste(login.trim())) {
                throw new NegocioException("Este login já está em uso. Escolha outro.");
            }

            Usuario u = new Usuario();
            u.setNome(nome.trim());
            u.setLogin(login.trim().toLowerCase());
            u.setSenha(senha); // Em produção real: aplicar hash (BCrypt, etc.)
            u.setAtivo(true);

            dao.inserirUsuario(u);

        } catch (SQLException e) {
            LOG.severe("Erro ao cadastrar usuário: " + e.getMessage());
            if ("23505".equals(e.getSQLState())) {
                throw new NegocioException("Este login já está em uso. Escolha outro.");
            }
            throw new NegocioException("Erro interno ao criar conta. Tente novamente.");
        }
    }
}
