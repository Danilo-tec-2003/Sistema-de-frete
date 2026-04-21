package br.com.gw.nucleo.utils;

/**
 * Validação de CNPJ pelo dígito verificador.
 */
public class ValidadorCNPJ {

    private ValidadorCNPJ() {}

    public static boolean isValido(String cnpj) {
        if (cnpj == null) return false;
        String nums = cnpj.replaceAll("[^0-9]", "");
        if (nums.length() != 14) return false;
        if (nums.matches("(\\d)\\1{13}")) return false;

        int[] pesos1 = {5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2};
        int soma = 0;
        for (int i = 0; i < 12; i++) soma += Character.getNumericValue(nums.charAt(i)) * pesos1[i];
        int r1 = soma % 11;
        r1 = (r1 < 2) ? 0 : 11 - r1;
        if (r1 != Character.getNumericValue(nums.charAt(12))) return false;

        int[] pesos2 = {6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2};
        soma = 0;
        for (int i = 0; i < 13; i++) soma += Character.getNumericValue(nums.charAt(i)) * pesos2[i];
        int r2 = soma % 11;
        r2 = (r2 < 2) ? 0 : 11 - r2;
        return r2 == Character.getNumericValue(nums.charAt(13));
    }

    /** Formata 14 dígitos para 00.000.000/0000-00. */
    public static String formatar(String cnpj) {
        if (cnpj == null) return "";
        String n = cnpj.replaceAll("[^0-9]", "");
        if (n.length() != 14) return cnpj;
        return n.substring(0,2) + "." + n.substring(2,5) + "." + n.substring(5,8)
             + "/" + n.substring(8,12) + "-" + n.substring(12);
    }
}