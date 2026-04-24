package br.com.gw.motorista;

import br.com.gw.Enums.StatusMotorista;
import br.com.gw.nucleo.exception.CadastroException;
import br.com.gw.nucleo.exception.NegocioException;
import br.com.gw.nucleo.utils.ValidadorCPF;

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
            if (m.getId() == 0) dao.inserir(m);
            else                dao.atualizar(m);
        } catch (CadastroException e) {
            throw e;
        } catch (SQLException e) {
            LOG.severe("Erro ao salvar motorista: " + e.getMessage());
            throw new NegocioException("Erro ao salvar motorista. Tente novamente.", e);
        }
    }

    public void excluir(int id) throws NegocioException {
        try {
            if (dao.possuiFreteAtivo(id)) {
                throw new CadastroException(
                    "Não é possível excluir este motorista pois ele possui fretes em andamento.");
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
        if (m.getNome() == null || m.getNome().trim().isEmpty()) {
            throw new CadastroException("O campo Nome é obrigatório.");
        }
        if (m.getCpf() == null || m.getCpf().trim().isEmpty()) {
            throw new CadastroException("O campo CPF é obrigatório.");
        }
        if (!ValidadorCPF.isValido(m.getCpf())) {
            throw new CadastroException(
                "O CPF informado (" + m.getCpf() + ") é inválido. Verifique os dígitos.");
        }
        if (m.getCnhNumero() == null || m.getCnhNumero().trim().isEmpty()) {
            throw new CadastroException("O número da CNH é obrigatório.");
        }
        if (m.getCnhCategoria() == null) {
            throw new CadastroException("A categoria da CNH é obrigatória.");
        }
        if (m.getCnhValidade() == null) {
            throw new CadastroException("A validade da CNH é obrigatória.");
        }
        if (m.getTipoVinculo() == null) {
            throw new CadastroException("O tipo de vínculo é obrigatório.");
        }
        if (m.getStatus() == null) {
            throw new CadastroException("O status é obrigatório.");
        }

        if (m.getId() > 0
                && m.getStatus() != StatusMotorista.ATIVO) {
            try {
                if (dao.possuiFreteAtivo(m.getId())) {
                    throw new CadastroException(
                        "Não é permitido inativar/suspender motorista com frete em andamento "
                        + "(status: Emitido, Saída Confirmada ou Em Trânsito).");
                }
            } catch (SQLException e) {
                LOG.severe("Erro ao verificar fretes do motorista: " + e.getMessage());
                throw new CadastroException("Erro ao verificar fretes ativos do motorista.");
            }
        }
    }
}