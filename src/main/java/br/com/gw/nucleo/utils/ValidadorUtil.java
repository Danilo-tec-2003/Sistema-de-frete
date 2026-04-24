package br.com.gw.nucleo.utils;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.regex.Pattern;

public class ValidadorUtil {

    // ── UFs válidas ──────────────────────────────────────────────────────────
    private static final Set<String> UFS_VALIDAS = new HashSet<>(Arrays.asList(
        "AC","AL","AM","AP","BA","CE","DF","ES","GO","MA","MG","MS","MT",
        "PA","PB","PE","PI","PR","RJ","RN","RO","RR","RS","SC","SE","SP","TO"
    ));

    private static final Pattern EMAIL   = Pattern.compile("^[\\w._%+\\-]+@[\\w.\\-]+\\.[a-zA-Z]{2,}$");
    private static final Pattern CEP     = Pattern.compile("^\\d{5}-?\\d{3}$");
    private static final Pattern TELEFONE= Pattern.compile("^\\(?\\d{2}\\)?[\\s\\-]?\\d{4,5}[\\-]?\\d{4}$");
    private static final Pattern PLACA_ANTIGA   = Pattern.compile("^[A-Z]{3}[0-9]{4}$");
    private static final Pattern PLACA_MERCOSUL = Pattern.compile("^[A-Z]{3}[0-9][A-Z][0-9]{2}$");

    public static boolean isEmailValido(String email) {
        return email != null && EMAIL.matcher(email.trim()).matches();
    }

    public static boolean isCepValido(String cep) {
        return cep != null && CEP.matcher(cep.trim()).matches();
    }

    public static boolean isTelefoneValido(String tel) {
        if (tel == null) return false;
        String limpo = tel.replaceAll("[^0-9]", "");
        return limpo.length() == 10 || limpo.length() == 11;
    }

    public static boolean isUfValida(String uf) {
        return uf != null && UFS_VALIDAS.contains(uf.toUpperCase().trim());
    }

    public static boolean isPlacaValida(String placa) {
        if (placa == null) return false;
        String p = placa.trim().toUpperCase().replaceAll("[\\s\\-]", "");
        return PLACA_ANTIGA.matcher(p).matches() || PLACA_MERCOSUL.matcher(p).matches();
    }

    public static boolean isAnoValido(int ano) {
        int anoAtual = LocalDate.now().getYear();
        return ano >= 1980 && ano <= anoAtual + 1;
    }

    // Remove tudo que não é dígito (para comparar CPF/CNPJ limpos)
    public static String somenteDigitos(String valor) {
        return valor == null ? "" : valor.replaceAll("[^0-9]", "");
    }
}