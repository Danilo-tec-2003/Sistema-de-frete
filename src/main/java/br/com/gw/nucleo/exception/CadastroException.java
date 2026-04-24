package br.com.gw.nucleo.exception;

/** Violações em cadastros: CPF duplicado, CNPJ inválido, campos obrigatórios, etc. */
public class CadastroException extends NegocioException {

    private static final long serialVersionUID = 1L;    

    public CadastroException(String mensagem) {
        super(mensagem);
    }

    public CadastroException(String mensagem, Throwable causa) {
        super(mensagem, causa);
    }
}