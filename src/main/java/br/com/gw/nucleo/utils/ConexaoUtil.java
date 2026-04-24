package br.com.gw.nucleo.utils;

import javax.naming.InitialContext;
import javax.servlet.ServletContext;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * Utilitário central de conexão.
 * O DataSource é guardado no ServletContext pelo AppContextListener.
 * Todos os BOs obtêm conexão daqui — nunca criam DriverManager diretamente.
 */
public class ConexaoUtil {

    private static final String DS_KEY = "dataSource";

    private static DataSource dataSource;

    private ConexaoUtil() {}

    /** Chamado pelo AppContextListener na inicialização da aplicação. */
    public static void setDataSource(DataSource ds) {
        dataSource = ds;
    }

    /**
     * Retorna uma conexão do pool.
     * O chamador é responsável por fechar (conn.close() devolve ao pool).
     */
    public static Connection getConexao() throws SQLException {
        if (dataSource == null) {
            throw new IllegalStateException(
                "DataSource não inicializado. Verifique o AppContextListener.");
        }
        return dataSource.getConnection();
    }
}