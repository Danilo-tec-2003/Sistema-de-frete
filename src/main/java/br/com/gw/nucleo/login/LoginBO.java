package br.com.gw.nucleo.login;

import br.com.gw.nucleo.exception.NegocioException;

import java.sql.SQLException;
import java.util.logging.Logger;

/**
 * Regras de negócio de autenticação.
 * O Controller só chama autenticar() e trata NegocioException.
 */
public class LoginBO {

    private static final Logger LOG = Logger.getLogger(LoginBO.class.getName());

    private final LoginDAO loginDAO = new LoginDAO();

    /**
     * Autentica o usuário.
     * @return Usuario se credenciais válidas.
     * @throws NegocioException se login/senha inválidos ou campos em branco.
     */
    public Usuario autenticar(String login, String senha) throws NegocioException {
        if (login == null || login.trim().isEmpty()) {
            throw new NegocioException("O campo login é obrigatório.");
        }
        if (senha == null || senha.trim().isEmpty()) {
            throw new NegocioException("O campo senha é obrigatório.");
        }

        try {
            Usuario usuario = loginDAO.buscarPorLoginSenha(login.trim(), senha);
            if (usuario == null) {
                throw new NegocioException("Login ou senha inválidos.");
            }
            return usuario;
        } catch (SQLException e) {
            LOG.severe("Erro de banco ao autenticar usuário '" + login + "': " + e.getMessage());
            throw new NegocioException("Erro interno ao realizar login. Tente novamente.", e);
        }
    }
}