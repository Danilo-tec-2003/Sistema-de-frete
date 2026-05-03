package br.com.gw.nucleo.utils;

import java.time.LocalDate;

/**
 * Validações estruturais de CNH usadas pelo cadastro de motorista e emissão de frete.
 *
 * O dígito verificador da CNH possui particularidades históricas e variações de emissão.
 * Por segurança, neste momento o sistema valida obrigatoriedade, formato numérico,
 * tamanho oficial de 11 dígitos e vencimento. O método isDigitoVerificadorValido foi
 * mantido preparado para uma futura ativação controlada com base oficial homologada.
 */
public final class ValidadorCNH {

    private ValidadorCNH() {}

    public static String somenteDigitos(String cnh) {
        return cnh == null ? "" : cnh.replaceAll("[^0-9]", "");
    }

    public static boolean temFormatoValido(String cnh) {
        String nums = somenteDigitos(cnh);
        return nums.length() == 11 && !nums.matches("(\\d)\\1{10}");
    }

    public static boolean isValidadeVigente(LocalDate validade) {
        return validade != null && !validade.isBefore(LocalDate.now());
    }

    public static boolean isDigitoVerificadorValido(String cnh) {
        return temFormatoValido(cnh);
    }
}
