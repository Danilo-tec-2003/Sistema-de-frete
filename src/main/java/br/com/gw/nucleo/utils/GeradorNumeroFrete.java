package br.com.gw.nucleo.utils;

import java.time.Year;

/**
 * Gera o número único do frete no formato FRT-AAAA-NNNNN.
 * DEVE ser chamado apenas no FreteBO — nunca no Controller ou no banco.
 * Conforme requisito: "gerado na camada BO, não no banco e não no Controller."
 */
public class GeradorNumeroFrete {

    private GeradorNumeroFrete() {}

    /**
     * @param proximoSequencial próximo número da sequência (vem do FreteDAO)
     * @return ex: "FRT-2026-00042"
     */
    public static String gerar(long proximoSequencial) {
        int ano = Year.now().getValue();
        return String.format("FRT-%d-%05d", ano, proximoSequencial);
    }
}