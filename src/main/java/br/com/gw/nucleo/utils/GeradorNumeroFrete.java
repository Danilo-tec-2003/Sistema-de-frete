package br.com.gw.nucleo.utils;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.Year;

/**
 * Gera o número do frete no formato FRT-AAAA-NNNNN.
 *
 * Usa a sequence seq_numero_frete do PostgreSQL — nunca SELECT MAX()
 * (evita race condition idêntica ao ticket #1397).
 *
 * Exemplo de saída: FRT-2026-00001
 */
public final class GeradorNumeroFrete {

    private GeradorNumeroFrete() {}

    /**
     * Gera o próximo número de frete usando a sequence do banco.
     * Deve ser chamado DENTRO de uma transação aberta — a conexão
     * é gerenciada pelo FreteBO.
     *
     * @param conn conexão ativa (não fecha aqui)
     * @return string no formato FRT-AAAA-NNNNN
     */
    public static String gerar(Connection conn) throws SQLException {
        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery("SELECT nextval('seq_numero_frete')")) {
            if (rs.next()) {
                long seq  = rs.getLong(1);
                int  ano  = Year.now().getValue();
                return String.format("FRT-%d-%05d", ano, seq);
            }
            throw new SQLException("Não foi possível obter valor da sequence seq_numero_frete");
        }
    }
}