package br.com.gw.nucleo.exception;

/**
 * Exceção para violações das regras de negócio específicas de frete:
 * transição de status inválida, veículo indisponível, CNH vencida, etc.
 *
 * Herda de NegocioException para que o controlador possa capturar
 * ambos com um único catch quando necessário.
 */
public class FreteException extends NegocioException {

    public FreteException(String mensagem) {
        super(mensagem);
    }

    public FreteException(String mensagem, Throwable causa) {
        super(mensagem, causa);
    }
}