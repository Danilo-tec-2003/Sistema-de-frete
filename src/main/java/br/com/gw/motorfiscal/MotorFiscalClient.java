package br.com.gw.motorfiscal;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class MotorFiscalClient {

    private static final String SIMULATE_PATH = "/api/v1/tax/simulate";
    private static final String PREVIEW_PATH = "/api/v1/tax/preview";

    private final MotorFiscalConfig config;
    private final Gson gson;

    public MotorFiscalClient() {
        this(MotorFiscalConfig.load());
    }

    public MotorFiscalClient(MotorFiscalConfig config) {
        this.config = config;
        this.gson = new Gson();
    }

    public TaxSimulationResponse simulate(TaxSimulationRequest request, String correlationId)
            throws MotorFiscalException {
        return post(SIMULATE_PATH, request, correlationId);
    }

    public TaxSimulationResponse preview(TaxPreviewRequest request, String correlationId)
            throws MotorFiscalException {
        return post(PREVIEW_PATH, request, correlationId);
    }

    private TaxSimulationResponse post(String path, Object request, String correlationId)
            throws MotorFiscalException {
        HttpURLConnection conn = null;

        try {
            URL url = new URL(config.getBaseUrl() + path);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setConnectTimeout(config.getTimeoutMs());
            conn.setReadTimeout(config.getTimeoutMs());
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setRequestProperty("Accept", "application/json");
            conn.setRequestProperty("X-API-Key", config.getApiKey());
            if (correlationId != null && !correlationId.trim().isEmpty()) {
                conn.setRequestProperty("X-Correlation-ID", correlationId);
            }

            writeRequestBody(conn, gson.toJson(request));

            int status = conn.getResponseCode();
            String body = readResponseBody(conn, status);

            if (status >= 200 && status < 300) {
                return gson.fromJson(body, TaxSimulationResponse.class);
            }

            throw buildException(status, body);
        } catch (MotorFiscalException e) {
            throw e;
        } catch (Exception e) {
            throw new MotorFiscalException(
                "Nao foi possivel comunicar com o Motor Fiscal.", e);
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }

    private void writeRequestBody(HttpURLConnection conn, String json) throws Exception {
        byte[] payload = json.getBytes(StandardCharsets.UTF_8);
        conn.setFixedLengthStreamingMode(payload.length);
        try (OutputStream output = conn.getOutputStream()) {
            output.write(payload);
        }
    }

    private String readResponseBody(HttpURLConnection conn, int status) throws Exception {
        InputStream stream = status >= 400 ? conn.getErrorStream() : conn.getInputStream();
        if (stream == null) {
            return "";
        }

        StringBuilder body = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(stream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                body.append(line);
            }
        }
        return body.toString();
    }

    private MotorFiscalException buildException(int status, String body) {
        try {
            MotorFiscalErrorResponse error = gson.fromJson(body, MotorFiscalErrorResponse.class);
            String message = error != null && error.getMessage() != null
                ? error.getMessage()
                : "Motor Fiscal retornou erro HTTP " + status + ".";
            return new MotorFiscalException(
                message, status,
                error != null ? error.getCode() : null,
                error != null ? error.getCorrelationId() : null
            );
        } catch (JsonSyntaxException e) {
            return new MotorFiscalException(
                "Motor Fiscal retornou erro HTTP " + status + ".", status, null, null);
        }
    }
}
