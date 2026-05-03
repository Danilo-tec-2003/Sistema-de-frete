package br.com.gw.motorista;

import br.com.gw.Enums.CategoriaCNH;
import br.com.gw.Enums.StatusMotorista;
import br.com.gw.Enums.TipoVinculo;
import br.com.gw.nucleo.exception.NegocioException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

@WebServlet("/motoristas")
public class MotoristaControlador extends HttpServlet {

    private final MotoristaBO bo = new MotoristaBO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String acao = req.getParameter("acao");

        if ("novo".equals(acao)) {
            req.setAttribute("categorias", CategoriaCNH.values());
            req.setAttribute("vinculos",   TipoVinculo.values());
            req.setAttribute("statusList", StatusMotorista.values());
            req.setAttribute("maxDataNascimento",
                java.time.LocalDate.now().minusYears(18).toString());
            req.setAttribute("minCnhValidade", java.time.LocalDate.now().toString());
            req.getRequestDispatcher("/jsp/motoristas/FormMotoristas.jsp").forward(req, resp);
            return;
        }

        if ("editar".equals(acao)) {
            int id = parseInt(req.getParameter("id"));
            try {
                req.setAttribute("motorista",  bo.buscarPorId(id));
                req.setAttribute("categorias", CategoriaCNH.values());
                req.setAttribute("vinculos",   TipoVinculo.values());
                req.setAttribute("statusList", StatusMotorista.values());
                req.setAttribute("maxDataNascimento",
                    java.time.LocalDate.now().minusYears(18).toString());
                req.setAttribute("minCnhValidade", java.time.LocalDate.now().toString());
                req.getRequestDispatcher("/jsp/motoristas/FormMotoristas.jsp").forward(req, resp);
            } catch (NegocioException e) {
                req.setAttribute("erro", e.getMessage());
                listar(req, resp);
            }
            return;
        }

        if ("excluir".equals(acao)) {
            int id = parseInt(req.getParameter("id"));
            try {
                bo.excluir(id);
                resp.sendRedirect(req.getContextPath()
                    + "/motoristas?sucesso=Motorista+exclu%C3%ADdo+com+sucesso.");
            } catch (NegocioException e) {
                req.setAttribute("erro", e.getMessage());
                listar(req, resp);
            }
            return;
        }

        listar(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        Motorista m = null;

        try {
            m = montarDoRequest(req);
            bo.salvar(m);
            String msg = m.getId() == 0
                ? "Motorista+cadastrado+com+sucesso."
                : "Motorista+atualizado+com+sucesso.";
            resp.sendRedirect(req.getContextPath() + "/motoristas?sucesso=" + msg);
        } catch (IllegalArgumentException | DateTimeParseException e) {
            req.setAttribute("erro", "Revise os dados do motorista. Há um valor inválido no formulário.");
            req.setAttribute("motorista",  m);
            req.setAttribute("maxDataNascimento",
            java.time.LocalDate.now().minusYears(18).toString());
            req.setAttribute("categorias", CategoriaCNH.values());
            req.setAttribute("vinculos",   TipoVinculo.values());
            req.setAttribute("statusList", StatusMotorista.values());
            req.setAttribute("minCnhValidade", java.time.LocalDate.now().toString());
            req.getRequestDispatcher("/jsp/motoristas/FormMotoristas.jsp").forward(req, resp);
        } catch (NegocioException e) {
            req.setAttribute("erro",       e.getMessage());
            req.setAttribute("motorista",  m);
            req.setAttribute("maxDataNascimento",
            java.time.LocalDate.now().minusYears(18).toString()); // ex: "2008-04-24"
            req.setAttribute("categorias", CategoriaCNH.values());
            req.setAttribute("vinculos",   TipoVinculo.values());
            req.setAttribute("statusList", StatusMotorista.values());
            req.setAttribute("minCnhValidade", java.time.LocalDate.now().toString());
            req.getRequestDispatcher("/jsp/motoristas/FormMotoristas.jsp").forward(req, resp);
        }
    }

    private void listar(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String filtro = req.getParameter("filtro");
        int pagina = Math.max(1, parseInt(req.getParameter("pagina")));
        try {
            req.setAttribute("motoristas",   bo.listar(filtro, pagina));
            req.setAttribute("totalPaginas", bo.totalPaginas(filtro));
            req.setAttribute("paginaAtual",  pagina);
            req.setAttribute("filtro",       filtro);
            req.setAttribute("sucesso",      req.getParameter("sucesso"));
        } catch (NegocioException e) {
            req.setAttribute("erro", e.getMessage());
        }
        req.getRequestDispatcher("/jsp/motoristas/listarMotoristas.jsp").forward(req, resp);
    }

    private Motorista montarDoRequest(HttpServletRequest req) {
        Motorista m = new Motorista();
        m.setId(parseInt(req.getParameter("id")));
        m.setNome(req.getParameter("nome"));
        m.setCpf(req.getParameter("cpf"));
        m.setTelefone(req.getParameter("telefone"));
        m.setCnhNumero(req.getParameter("cnhNumero"));

        String cat = req.getParameter("cnhCategoria");
        if (cat != null && !cat.isEmpty()) m.setCnhCategoria(CategoriaCNH.fromCodigo(cat));

        String dataNasc = req.getParameter("dataNascimento");
        if (dataNasc != null && !dataNasc.isEmpty()) m.setDataNascimento(LocalDate.parse(dataNasc));

        String dataVal = req.getParameter("cnhValidade");
        if (dataVal != null && !dataVal.isEmpty()) m.setCnhValidade(LocalDate.parse(dataVal));

        String vinc = req.getParameter("tipoVinculo");
        if (vinc != null && !vinc.isEmpty()) m.setTipoVinculo(TipoVinculo.fromCodigo(vinc));

        String stat = req.getParameter("status");
        if (stat != null && !stat.isEmpty()) m.setStatus(StatusMotorista.fromCodigo(stat));

        return m;
    }

    private int parseInt(String s) {
        try { return s == null ? 0 : Integer.parseInt(s.trim()); }
        catch (NumberFormatException e) { return 0; }
    }
}
