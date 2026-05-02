package br.com.gw.cliente;

import br.com.gw.Enums.TipoCliente;
import br.com.gw.nucleo.exception.CadastroException;
import br.com.gw.nucleo.exception.NegocioException;
import br.com.gw.nucleo.utils.ValidadorCNPJ;
import br.com.gw.nucleo.utils.ValidadorCPF;

import java.sql.SQLException;
import java.util.List;
import java.util.logging.Logger;
import br.com.gw.nucleo.utils.ValidadorUtil;

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
        c.setTipo(TipoCliente.AMBOS);
        validar(c);

        try {
            if (c.getCnpj() != null && !c.getCnpj().trim().isEmpty()) {
                if (dao.existeDocumentoFiscal(c.getCnpj(), c.getId())) {
                    throw new CadastroException(
                        "O documento " + c.getCnpj() + " já está cadastrado para outro cliente.");
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

        // ── Obrigatórios principais ──────────────────────────────────────────
        if (vazio(c.getRazaoSocial()))
            throw new CadastroException("O campo Razão Social é obrigatório.");
    
        if (c.getRazaoSocial().trim().length() < 3)
            throw new CadastroException("A Razão Social deve ter pelo menos 3 caracteres.");
    
        // ── Documento fiscal ─────────────────────────────────────────────────
        if (vazio(c.getCnpj()))
            throw new CadastroException("O campo CPF/CNPJ é obrigatório.");

        String documento = somenteDigitos(c.getCnpj());
        if (documento.length() == 11) {
            if (!ValidadorCPF.isValido(documento))
                throw new CadastroException("O CPF informado (" + c.getCnpj() + ") é inválido. Verifique os dígitos.");
        } else if (documento.length() == 14) {
            if (!ValidadorCNPJ.isValido(documento))
                throw new CadastroException("O CNPJ informado (" + c.getCnpj() + ") é inválido. Verifique os dígitos.");
        } else {
            throw new CadastroException("Informe um CPF com 11 dígitos ou CNPJ com 14 dígitos.");
        }
    
        // ── Endereço ──────────────────────────────────────────────────────────
        if (vazio(c.getLogradouro()))
            throw new CadastroException("O campo Logradouro é obrigatório.");
    
        if (vazio(c.getNumeroEnd()))
            throw new CadastroException("O campo Número do endereço é obrigatório.");
    
        if (vazio(c.getBairro()))
            throw new CadastroException("O campo Bairro é obrigatório.");
    
        if (vazio(c.getMunicipio()))
            throw new CadastroException("O campo Município é obrigatório.");
    
        if (vazio(c.getUf()))
            throw new CadastroException("O campo UF é obrigatório.");
    
        if (!ValidadorUtil.isUfValida(c.getUf()))
            throw new CadastroException("A UF informada (" + c.getUf().toUpperCase() + ") é inválida.");
    
        if (vazio(c.getCep()))
            throw new CadastroException("O campo CEP é obrigatório.");
    
        if (!ValidadorUtil.isCepValido(c.getCep()))
            throw new CadastroException("O CEP informado é inválido. Use o formato 00000-000.");
    
        // ── Contato ───────────────────────────────────────────────────────────
        if (vazio(c.getTelefone()))
            throw new CadastroException("O campo Telefone é obrigatório.");
    
        if (!ValidadorUtil.isTelefoneValido(c.getTelefone()))
            throw new CadastroException("O Telefone informado é inválido. Use o formato (XX) XXXXX-XXXX.");
    
        if (!vazio(c.getEmail()) && !ValidadorUtil.isEmailValido(c.getEmail()))
            throw new CadastroException("O E-mail informado não é válido.");
    }
    
    // ── helper ────────────────────────────────────────────────────────────────
    private boolean vazio(String s) {
        return s == null || s.trim().isEmpty();
    }

    private String somenteDigitos(String s) {
        return s == null ? "" : s.replaceAll("[^0-9]", "");
    }
}
