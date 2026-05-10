package br.com.gw.motorfiscal;

public class MotorFiscalException extends Exception {

    private final int statusCode;
    private final String code;
    private final String correlationId;

    public MotorFiscalException(String message) {
        this(message, 0, null, null, null);
    }

    public MotorFiscalException(String message, Throwable cause) {
        this(message, 0, null, null, cause);
    }

    public MotorFiscalException(String message, int statusCode, String code, String correlationId) {
        this(message, statusCode, code, correlationId, null);
    }

    public MotorFiscalException(String message, int statusCode, String code,
                                String correlationId, Throwable cause) {
        super(message, cause);
        this.statusCode = statusCode;
        this.code = code;
        this.correlationId = correlationId;
    }

    public int getStatusCode() {
        return statusCode;
    }

    public String getCode() {
        return code;
    }

    public String getCorrelationId() {
        return correlationId;
    }
}
