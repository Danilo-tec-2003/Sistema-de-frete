package br.com.gw.nucleo.login;

import br.com.gw.Enums.StatusFrete;
import br.com.gw.cliente.ClienteDAO;
import br.com.gw.frete.FreteDAO;
import br.com.gw.motorista.MotoristaDAO;
import br.com.gw.veiculos.VeiculoDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/home")
public class HomeControlador extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(HomeControlador.class.getName());
    private static final Locale PT_BR = new Locale("pt", "BR");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        carregarResumoOperacional(req);
        req.getRequestDispatcher("/jsp/home.jsp").forward(req, resp);
    }

    private void carregarResumoOperacional(HttpServletRequest req) {
        DateTimeFormatter dataFmt = DateTimeFormatter.ofPattern("EEEE, dd 'de' MMMM 'de' yyyy", PT_BR);
        DateTimeFormatter horaFmt = DateTimeFormatter.ofPattern("HH:mm", PT_BR);
        req.setAttribute("dataDashboard", capitalizar(LocalDate.now().format(dataFmt)));
        req.setAttribute("horaDashboard", LocalTime.now().format(horaFmt));

        try {
            FreteDAO freteDAO = new FreteDAO();
            ClienteDAO clienteDAO = new ClienteDAO();
            MotoristaDAO motoristaDAO = new MotoristaDAO();
            VeiculoDAO veiculoDAO = new VeiculoDAO();

            int emitidos = freteDAO.contarTotal(null, StatusFrete.EMITIDO.getCodigoString());
            int saidaConfirmada = freteDAO.contarTotal(null, StatusFrete.SAIDA_CONFIRMADA.getCodigoString());
            int emTransito = freteDAO.contarTotal(null, StatusFrete.EM_TRANSITO.getCodigoString());

            req.setAttribute("totalFretes", freteDAO.contarTotal(null, null));
            req.setAttribute("fretesAndamento", emitidos + saidaConfirmada + emTransito);
            req.setAttribute("aguardandoColeta", emitidos);
            req.setAttribute("fretesAtrasados", freteDAO.contarAtrasados());
            req.setAttribute("entregasHoje", freteDAO.contarEntreguesHoje());
            req.setAttribute("totalClientes", clienteDAO.contarAtivos());
            req.setAttribute("totalMotoristas", motoristaDAO.contarAtivos());
            req.setAttribute("totalVeiculos", veiculoDAO.contarDisponiveis());
        } catch (Exception e) {
            LOG.log(Level.WARNING, "Não foi possível carregar os indicadores do dashboard.", e);
            req.setAttribute("dashboardAviso", "Indicadores temporariamente indisponíveis.");
        }
    }

    private String capitalizar(String texto) {
        if (texto == null || texto.isEmpty()) return texto;
        return Character.toUpperCase(texto.charAt(0)) + texto.substring(1);
    }
}
