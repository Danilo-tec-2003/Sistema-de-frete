package br.com.gw.motorista;

import br.com.gw.Enums.StatusMotorista;
import br.com.gw.nucleo.exception.CadastroException;
import br.com.gw.nucleo.exception.NegocioException;
import br.com.gw.nucleo.utils.ValidadorCNH;
import br.com.gw.nucleo.utils.ValidadorCPF;
import br.com.gw.nucleo.utils.ValidadorUtil;

import java.sql.SQLException;
import java.util.List;
import java.util.logging.Logger;

public class MotoristaBO {

    private static final Logger LOG = Logger.getLogger(MotoristaBO.class.getName());
    private static final int    TAMANHO_PAGINA = 10;

    private final MotoristaDAO dao = new MotoristaDAO();

    public List<Motorista> listar(String filtro, int pagina) throws NegocioException {
        try {
            return dao.listar(filtro, Math.max(1, pagina), TAMANHO_PAGINA);
        } catch (SQLException e) {
            LOG.severe("Erro ao listar motoristas: " + e.getMessage());
            throw new NegocioException("Erro ao carregar lista de motoristas.", e);
        }
    }

    public int totalPaginas(String filtro) throws NegocioException {
        try {
            int total = dao.contarTotal(filtro);
            return (int) Math.ceil((double) total / TAMANHO_PAGINA);
        } catch (SQLException e) {
            LOG.severe("Erro ao contar motoristas: " + e.getMessage());
            throw new NegocioException("Erro ao calcular paginação.", e);
        }
    }

    public Motorista buscarPorId(int id) throws NegocioException {
        try {
            Motorista m = dao.buscarPorId(id);
            if (m == null) throw new CadastroException("Motorista não encontrado (id=" + id + ").");
            return m;
        } catch (CadastroException e) {
            throw e;
        } catch (SQLException e) {
            LOG.severe("Erro ao buscar motorista id=" + id + ": " + e.getMessage());
            throw new NegocioException("Erro ao buscar motorista.", e);
        }
    }

    public void salvar(Motorista m) throws NegocioException {
        validar(m);
        try {
            if (dao.existeCpf(m.getCpf(), m.getId())) {
                throw new CadastroException(
                    "O CPF " + m.getCpf() + " já está cadastrado para outro motorista.");
            }
            if (dao.existeCnh(m.getCnhNumero(), m.getId())) {
                throw new CadastroException(
                    "A CNH " + m.getCnhNumero() + " já está cadastrada para outro motorista.");
            }
            if (m.getId() == 0) dao.inserir(m);
            else                dao.atualizar(m);
        } catch (CadastroException e) {
            throw e;
        } catch (SQLException e) {
            LOG.severe("Erro ao salvar motorista: " + e.getMessage());
            throw new NegocioException(mensagemSalvarMotorista(e), e);
        }
    }

    public void excluir(int id) throws NegocioException {
        try {
            if (dao.possuiFreteAtivo(id)) {
                throw new CadastroException(
                    "Não é possível excluir este motorista pois ele possui fretes em andamento.");
            }
            if (dao.possuiFretes(id)) {
                throw new CadastroException(
                    "Não é possível excluir este motorista pois ele possui fretes vinculados ao histórico.");
            }
            dao.excluir(id);
        } catch (CadastroException e) {
            throw e;
        } catch (SQLException e) {
            LOG.severe("Erro ao excluir motorista id=" + id + ": " + e.getMessage());
            throw new NegocioException("Erro ao excluir motorista.", e);
        }
    }

    private void validar(Motorista m) throws CadastroException {

        if (m.getNome() == null || m.getNome().trim().isEmpty())
            throw new CadastroException("O campo Nome é obrigatório.");
    
        if (m.getNome().trim().length() < 3)
            throw new CadastroException("O Nome deve ter pelo menos 3 caracteres.");
    
        if (m.getCpf() == null || m.getCpf().trim().isEmpty())
            throw new CadastroException("O campo CPF é obrigatório.");
    
        if (!ValidadorCPF.isValido(m.getCpf()))
            throw new CadastroException("O CPF informado (" + m.getCpf() + ") é inválido. Verifique os dígitos.");
    
        // ── Data de nascimento ────────────────────────────────────────────────
        if (m.getDataNascimento() == null)
            throw new CadastroException("O campo Data de Nascimento é obrigatório.");
    
        if (m.getDataNascimento().isAfter(java.time.LocalDate.now()))
            throw new CadastroException("A Data de Nascimento não pode ser uma data futura.");
    
        if (m.getDataNascimento().isAfter(java.time.LocalDate.now().minusYears(18)))
            throw new CadastroException("O motorista deve ter pelo menos 18 anos de idade.");
    
        if (m.getDataNascimento().isBefore(java.time.LocalDate.now().minusYears(80)))
            throw new CadastroException("Data de Nascimento inválida.");
    
        // ── Telefone ──────────────────────────────────────────────────────────
        if (m.getTelefone() == null || m.getTelefone().trim().isEmpty())
            throw new CadastroException("O campo Telefone é obrigatório.");
    
        if (!ValidadorUtil.isTelefoneValido(m.getTelefone()))
            throw new CadastroException("O Telefone informado é inválido. Use o formato (XX) XXXXX-XXXX.");
    
        // ── CNH ───────────────────────────────────────────────────────────────
        if (m.getCnhNumero() == null || m.getCnhNumero().trim().isEmpty())
            throw new CadastroException("O número da CNH é obrigatório.");

        if (!ValidadorCNH.temFormatoValido(m.getCnhNumero()))
            throw new CadastroException("A CNH deve conter 11 dígitos numéricos.");
    
        if (m.getCnhCategoria() == null)
            throw new CadastroException("A categoria da CNH é obrigatória.");
    
        if (m.getCnhValidade() == null)
            throw new CadastroException("A validade da CNH é obrigatória.");

        if (!ValidadorCNH.isValidadeVigente(m.getCnhValidade()))
            throw new CadastroException("A CNH do motorista está vencida.");
    
        // ── Vínculo e status ──────────────────────────────────────────────────
        if (m.getTipoVinculo() == null)
            throw new CadastroException("O tipo de vínculo é obrigatório.");
    
        if (m.getStatus() == null)
            throw new CadastroException("O status é obrigatório.");

        if (m.getStatus() == StatusMotorista.ATIVO && m.isCnhVencida())
            throw new CadastroException("Motorista ativo não pode permanecer com CNH vencida.");
    
        // ── Regra de negócio: inativação com frete ativo ──────────────────────
        if (m.getId() > 0 && m.getStatus() != StatusMotorista.ATIVO) {
            try {
                if (dao.possuiFreteAtivo(m.getId()))
                    throw new CadastroException(
                        "Não é permitido inativar/suspender motorista com frete em andamento " +
                        "(status: Emitido, Saída Confirmada ou Em Trânsito).");
            } catch (SQLException e) {
                LOG.severe("Erro ao verificar fretes do motorista: " + e.getMessage());
                throw new CadastroException("Erro ao verificar fretes ativos do motorista.");
            }
        }
    }

    private String mensagemSalvarMotorista(SQLException e) {
        String detalhe = e.getMessage() == null ? "" : e.getMessage().toLowerCase();
        if ("23505".equals(e.getSQLState())) {
            if (detalhe.contains("cnh")) {
                return "A CNH informada já está cadastrada para outro motorista.";
            }
            if (detalhe.contains("cpf")) {
                return "O CPF informado já está cadastrado para outro motorista.";
            }
            return "Já existe um motorista cadastrado com estes dados.";
        }
        return "Erro ao salvar motorista. Tente novamente.";
    }
}
