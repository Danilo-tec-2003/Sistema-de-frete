package br.com.gw.nucleo.utils;

/**
 * Validação de CPF pelo dígito verificador.
 * Regra de negócio — fica aqui, nunca no BO direto.
 */
public class ValidadorCPF {

    private ValidadorCPF() {}

    /**
     * Valida CPF (aceita com ou sem máscara: 000.000.000-00 ou 00000000000).
     * @return true se válido
     */
    public static boolean isValido(String cpf) {
        if (cpf == null) return false;
        String nums = cpf.replaceAll("[^0-9]", "");
        if (nums.length() != 11) return false;

        // Rejeita sequências iguais (111.111.111-11, etc.)
        if (nums.matches("(\\d)\\1{10}")) return false;

        int soma = 0;
        for (int i = 0; i < 9; i++) soma += Character.getNumericValue(nums.charAt(i)) * (10 - i);
        int r1 = (soma * 10) % 11;
        if (r1 == 10 || r1 == 11) r1 = 0;
        if (r1 != Character.getNumericValue(nums.charAt(9))) return false;

        soma = 0;
        for (int i = 0; i < 10; i++) soma += Character.getNumericValue(nums.charAt(i)) * (11 - i);
        int r2 = (soma * 10) % 11;
        if (r2 == 10 || r2 == 11) r2 = 0;
        return r2 == Character.getNumericValue(nums.charAt(10));
    }

    /** Formata 11 dígitos numéricos para 000.000.000-00. */
    public static String formatar(String cpf) {
        if (cpf == null) return "";
        String nums = cpf.replaceAll("[^0-9]", "");
        if (nums.length() != 11) return cpf;
        return nums.substring(0, 3) + "." + nums.substring(3, 6) + "."
             + nums.substring(6, 9) + "-" + nums.substring(9);
    }
}