package br.com.gw.nucleo;

import br.com.gw.nucleo.utils.ConexaoUtil;
import org.apache.commons.dbcp2.BasicDataSource;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.io.InputStream;
import java.util.Properties;
import java.util.logging.Logger;

/**
 * Inicializa o pool de conexões DBCP2 ao subir a aplicação.
 * Lê configurações de /WEB-INF/db.properties (nunca hardcoded).
 */
@WebListener
public class AppContextListener implements ServletContextListener {

    private static final Logger LOG = Logger.getLogger(AppContextListener.class.getName());

    private BasicDataSource bds;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext ctx = sce.getServletContext();
        try {
            // db.properties fica em src/main/resources → WEB-INF/classes em runtime
            InputStream is = ctx.getResourceAsStream("/WEB-INF/classes/db.properties");
            if (is == null) {
                // fallback para desenvolvimento local via classpath
                is = getClass().getClassLoader().getResourceAsStream("db.properties");
            }
            if (is == null) {
                throw new IllegalStateException(
                    "db.properties não encontrado. Copie db.properties.example para src/main/resources/db.properties");
            }

            Properties props = new Properties();
            props.load(is);

            bds = new BasicDataSource();
            bds.setDriverClassName("org.postgresql.Driver");
            bds.setUrl(props.getProperty("db.url"));
            bds.setUsername(props.getProperty("db.user"));
            bds.setPassword(props.getProperty("db.password"));
            bds.setMinIdle(Integer.parseInt(props.getProperty("db.pool.min", "2")));
            bds.setMaxTotal(Integer.parseInt(props.getProperty("db.pool.max", "10")));
            bds.setTestOnBorrow(true);
            bds.setValidationQuery("SELECT 1");

            ConexaoUtil.setDataSource(bds);
            LOG.info("Pool DBCP2 inicializado com sucesso. URL: " + bds.getUrl());

        } catch (Exception e) {
            LOG.severe("FALHA ao inicializar pool de conexões: " + e.getMessage());
            throw new RuntimeException("Falha ao inicializar DataSource", e);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        try {
            if (bds != null) {
                bds.close();
                LOG.info("Pool DBCP2 encerrado.");
            }
        } catch (Exception e) {
            LOG.warning("Erro ao fechar pool: " + e.getMessage());
        }
    }
}