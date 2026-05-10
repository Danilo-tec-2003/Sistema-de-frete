package br.com.gw.motorfiscal;

import java.io.InputStream;
import java.util.Properties;

public class MotorFiscalConfig {

    private static final String PROPERTIES_FILE = "db.properties";

    private final String baseUrl;
    private final String apiKey;
    private final int timeoutMs;

    private MotorFiscalConfig(String baseUrl, String apiKey, int timeoutMs) {
        this.baseUrl = normalizeBaseUrl(baseUrl);
        this.apiKey = apiKey;
        this.timeoutMs = timeoutMs;
    }

    public static MotorFiscalConfig load() {
        Properties props = new Properties();

        try (InputStream input = MotorFiscalConfig.class.getClassLoader()
                .getResourceAsStream(PROPERTIES_FILE)) {
            if (input != null) {
                props.load(input);
            }
        } catch (Exception e) {
            throw new IllegalStateException("Erro ao carregar configuracoes do Motor Fiscal.", e);
        }

        String baseUrl = firstNonBlank(
            System.getenv("MOTOR_FISCAL_BASE_URL"),
            props.getProperty("motor.fiscal.base.url"),
            "http://localhost:8080"
        );

        String apiKey = firstNonBlank(
            System.getenv("MOTOR_FISCAL_API_KEY"),
            props.getProperty("motor.fiscal.api.key"),
            ""
        );

        int timeoutMs = parseInt(firstNonBlank(
            System.getenv("MOTOR_FISCAL_TIMEOUT_MS"),
            props.getProperty("motor.fiscal.timeout.ms"),
            "5000"
        ), 5000);

        if (apiKey.trim().isEmpty()) {
            throw new IllegalStateException("motor.fiscal.api.key nao configurado.");
        }

        return new MotorFiscalConfig(baseUrl, apiKey, timeoutMs);
    }

    private static String firstNonBlank(String first, String second, String fallback) {
        if (first != null && !first.trim().isEmpty()) return first.trim();
        if (second != null && !second.trim().isEmpty()) return second.trim();
        return fallback;
    }

    private static int parseInt(String value, int fallback) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private static String normalizeBaseUrl(String value) {
        String normalized = value == null ? "" : value.trim();
        while (normalized.endsWith("/")) {
            normalized = normalized.substring(0, normalized.length() - 1);
        }
        return normalized;
    }

    public String getBaseUrl() {
        return baseUrl;
    }

    public String getApiKey() {
        return apiKey;
    }

    public int getTimeoutMs() {
        return timeoutMs;
    }
}
