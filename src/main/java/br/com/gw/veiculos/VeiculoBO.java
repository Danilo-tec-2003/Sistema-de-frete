package br.com.gw.veiculos;

import br.com.gw.Enums.StatusVeiculo;
import br.com.gw.nucleo.exception.CadastroException;
import br.com.gw.nucleo.exception.NegocioException;
import br.com.gw.nucleo.utils.ValidadorUtil;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.Year;
import java.util.List;
import java.util.logging.Logger;
import java.util.regex.Pattern;

public class VeiculoBO {

    private static final Logger  LOG = Logger.getLogger(VeiculoBO.class.getName());
    private static final int     TAMANHO_PAGINA = 10;

    /** Formato Mercosul: ABC1D23 | Formato antigo: ABC1234 */
    private static final Pattern PLACA_MERCOSUL = Pattern.compile("[A-Z]{3}[0-9][A-Z][0-9]{2}");
    private static final Pattern PLACA_ANTIGA   = Pattern.compile("[A-Z]{3}[0-9]{4}");

    private final VeiculoDAO dao = new VeiculoDAO();

    public List<Veiculo> listar(String filtro, int pagina) throws NegocioException {
        try {
            return dao.listar(filtro, Math.max(1, pagina), TAMANHO_PAGINA);
        } catch (SQLException e) {
            LOG.severe("Erro ao listar veículos: " + e.getMessage());
            throw new NegocioException("Erro ao carregar lista de veículos.", e);
        }
    }

    public int totalPaginas(String filtro) throws NegocioException {
        try {
            return (int) Math.ceil((double) dao.contarTotal(filtro) / TAMANHO_PAGINA);
        } catch (SQLException e) {
            LOG.severe("Erro ao contar veículos: " + e.getMessage());
            throw new NegocioException("Erro ao calcular paginação.", e);
        }
    }

    public Veiculo buscarPorId(int id) throws NegocioException {
        try {
            Veiculo v = dao.buscarPorId(id);
            if (v == null) throw new CadastroException("Veículo não encontrado (id=" + id + ").");
            return v;
        } catch (CadastroException e) {
            throw e;
        } catch (SQLException e) {
            LOG.severe("Erro ao buscar veículo id=" + id + ": " + e.getMessage());
            throw new NegocioException("Erro ao buscar veículo.", e);
        }
    }

    public void salvar(Veiculo v) throws NegocioException {
        validar(v);
        try {
            if (dao.existePlaca(v.getPlaca(), v.getId())) {
                throw new CadastroException(
                    "A placa " + v.getPlaca() + " já está cadastrada para outro veículo.");
            }
            if (v.getId() == 0) dao.inserir(v);
            else                dao.atualizar(v);
        } catch (CadastroException e) {
            throw e;
        } catch (SQLException e) {
            LOG.severe("Erro ao salvar veículo: " + e.getMessage());
            throw new NegocioException(mensagemSalvarVeiculo(e), e);
        }
    }

    public void excluir(int id) throws NegocioException {
        try {
            if (dao.estaEmViagem(id)) {
                throw new CadastroException(
                    "Não é possível excluir este veículo pois há frete Em Trânsito vinculado a ele.");
            }
            if (dao.possuiFretes(id)) {
                throw new CadastroException(
                    "Não é possível excluir este veículo pois ele possui fretes vinculados ao histórico.");
            }
            dao.excluir(id);
        } catch (CadastroException e) {
            throw e;
        } catch (SQLException e) {
            LOG.severe("Erro ao excluir veículo id=" + id + ": " + e.getMessage());
            throw new NegocioException("Erro ao excluir veículo.", e);
        }
    }

    private void validar(Veiculo v) throws CadastroException {

        // ── Placa ─────────────────────────────────────────────────────────────
        if (v.getPlaca() == null || v.getPlaca().trim().isEmpty())
            throw new CadastroException("O campo Placa é obrigatório.");
    
        String placa = v.getPlaca().toUpperCase().trim().replaceAll("[\\s\\-]", "");
        if (!PLACA_MERCOSUL.matcher(placa).matches() && !PLACA_ANTIGA.matcher(placa).matches())
            throw new CadastroException(
                "A placa informada (" + v.getPlaca() + ") não está no formato Mercosul (ABC1D23) " +
                "nem no formato antigo (ABC1234).");
    
        // ── RNTRC ─────────────────────────────────────────────────────────────
        if (v.getRntrc() == null || v.getRntrc().trim().isEmpty())
            throw new CadastroException("O campo RNTRC é obrigatório.");
    
        // ── Tipo e status ─────────────────────────────────────────────────────
        if (v.getTipo() == null)
            throw new CadastroException("O tipo do veículo é obrigatório.");
    
        if (v.getStatus() == null)
            throw new CadastroException("O status do veículo é obrigatório.");
    
        // ── Ano de fabricação ─────────────────────────────────────────────────
        if (v.getAnoFabricacao() == null)
            throw new CadastroException("O campo Ano de Fabricação é obrigatório.");
    
        int anoAtual = Year.now().getValue();
        if (v.getAnoFabricacao() < 1950 || v.getAnoFabricacao() > anoAtual + 1)
            throw new CadastroException("Ano de fabricação inválido: " + v.getAnoFabricacao() + ".");
    
        // ── Capacidades numéricas ─────────────────────────────────────────────
        if (v.getTaraKg() == null || v.getTaraKg().compareTo(BigDecimal.ZERO) <= 0)
            throw new CadastroException("O campo Tara (kg) é obrigatório e deve ser maior que zero.");
    
        if (v.getCapacidadeKg() == null || v.getCapacidadeKg().compareTo(BigDecimal.ZERO) <= 0)
            throw new CadastroException("O campo Capacidade de Carga (kg) é obrigatório e deve ser maior que zero.");

        if (!v.getTipo().permiteCapacidade(v.getCapacidadeKg())) {
            throw new CadastroException(
                "A capacidade informada excede ou fica abaixo do limite de referência para "
                + v.getTipo().getDescricao() + ". Faixa aceita: "
                + v.getTipo().getFaixaCapacidadeDescricao() + ". "
                + "Estes limites são referências operacionais do sistema e podem variar conforme "
                + "modelo, eixo e documentação do veículo.");
        }
    
        if (v.getVolumeM3() == null || v.getVolumeM3().compareTo(BigDecimal.ZERO) <= 0)
            throw new CadastroException("O campo Volume (m³) é obrigatório e deve ser maior que zero.");
    
        // ── Regra: status disponível com frete em trânsito ───────────────────
        if (v.getId() > 0 && v.getStatus() == StatusVeiculo.DISPONIVEL) {
            try {
                if (dao.estaEmViagem(v.getId()))
                    throw new CadastroException(
                        "Não é permitido alterar o status para Disponível manualmente enquanto há " +
                        "frete Em Trânsito vinculado. O status é atualizado automaticamente ao concluir o frete.");
            } catch (SQLException e) {
                LOG.severe("Erro ao verificar viagem do veículo: " + e.getMessage());
                throw new CadastroException("Erro ao verificar status do frete vinculado.");
            }
        }
    }

    private String mensagemSalvarVeiculo(SQLException e) {
        String detalhe = e.getMessage() == null ? "" : e.getMessage().toLowerCase();
        if ("23505".equals(e.getSQLState())) {
            if (detalhe.contains("placa")) {
                return "A placa informada já está cadastrada para outro veículo.";
            }
            return "Já existe um veículo cadastrado com estes dados.";
        }
        return "Erro ao salvar veículo. Tente novamente.";
    }
}
