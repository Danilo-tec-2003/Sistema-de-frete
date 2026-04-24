package br.com.gw.cliente;

import br.com.gw.Enums.TipoCliente;
import br.com.gw.nucleo.exception.CadastroException;
import br.com.gw.nucleo.exception.NegocioException;
import br.com.gw.nucleo.utils.ValidadorCNPJ;

import java.sql.SQLException;
import java.util.List;
import java.util.logging.Logger;

public class ClienteBO {

    private static final Logger     LOG = Logger.getLogger(ClienteBO.class.getName());
    private static final int        TAMANHO_PAGINA = 10;

    private final ClienteDAO dao = new ClienteDAO();

    public List<Cliente> listar(String filtro, int pagina) throws NegocioException {
        try {
            int p = pagina < 1 ? 1 : pagina;
            return dao.listar(filtro, p, TAMANHO_PAGINA);
        } catch (SQLException e) {
            LOG.severe("Erro ao listar clientes: " + e.getMessage());
            throw new NegocioException("Erro ao carregar lista de clientes.", e);
        }
    }

    public int totalPaginas(String filtro) throws NegocioException {
        try {
            int total = dao.contarTotal(filtro);
            return (int) Math.ceil((double) total / TAMANHO_PAGINA);
        } catch (SQLException e) {
            LOG.severe("Erro ao contar clientes: " + e.getMessage());
            throw new NegocioException("Erro ao calcular paginação.", e);
        }
    }

    public Cliente buscarPorId(int id) throws NegocioException {
        try {
            Cliente c = dao.buscarPorId(id);
            if (c == null) throw new CadastroException("Cliente não encontrado (id=" + id + ").");
            return c;
        } catch (CadastroException e) {
            throw e;
        } catch (SQLException e) {
            LOG.severe("Erro ao buscar cliente id=" + id + ": " + e.getMessage());
            throw new NegocioException("Erro ao buscar cliente.", e);
        }
    }

    public void salvar(Cliente c) throws NegocioException {
        validar(c);

        try {
            if (c.getCnpj() != null  && !c.getCnpj().trim().isEmpty()) {
                if (dao.existeCnpj(c.getCnpj(), c.getId())) {
                    throw new CadastroException(
                        "O CNPJ " + c.getCnpj() + " já está cadastrado para outro cliente.");
                }
            }

            if (c.getId() == 0) {
                dao.inserir(c);
            } else {
                dao.atualizar(c);
            }
        } catch (CadastroException e) {
            throw e;
        } catch (SQLException e) {
            LOG.severe("Erro ao salvar cliente: " + e.getMessage());
            throw new NegocioException("Erro ao salvar cliente. Tente novamente.", e);
        }
    }


    public void excluir(int id) throws NegocioException {
        try {
            if (dao.possuiFretes(id)) {
                throw new CadastroException(
                    "Não é possível excluir este cliente pois ele possui fretes cadastrados.");
            }
            dao.excluir(id);
        } catch (CadastroException e) {
            throw e;
        } catch (SQLException e) {
            LOG.severe("Erro ao excluir cliente id=" + id + ": " + e.getMessage());
            throw new NegocioException("Erro ao excluir cliente.", e);
        }
    }

    private void validar(Cliente c) throws CadastroException {
        if (c.getRazaoSocial() == null || c.getRazaoSocial().trim().isEmpty()) {
            throw new CadastroException("O campo Razão Social é obrigatório.");
        }
        if (c.getTipo() == null) {
            throw new CadastroException("O campo Tipo é obrigatório.");
        }

        String cnpj = c.getCnpj();
        if (cnpj != null && !c.getCnpj().trim().isEmpty()) {
            if (!ValidadorCNPJ.isValido(cnpj)) {
                throw new CadastroException(
                    "O CNPJ informado (" + cnpj + ") é inválido. Verifique os dígitos.");
            }
        }

        if (c.getUf() != null && !c.getUf().trim().isEmpty() && c.getUf().length() != 2) {
            throw new CadastroException("A UF deve ter exatamente 2 caracteres.");
        }
    }
}