package br.com.gw.nucleo.exception;

/**
 * Exceção base para erros de regra de negócio.
 * Sempre capturada no Controller — nunca exposta ao usuário como stack trace.
 */
public class NegocioException extends Exception {

    private static final long serialVersionUID = 1L;

    public NegocioException(String mensagem) {
        super(mensagem);
    }

    public NegocioException(String mensagem, Throwable causa) {
        super(mensagem, causa);
    }
}