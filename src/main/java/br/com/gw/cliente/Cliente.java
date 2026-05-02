package br.com.gw.cliente;

import br.com.gw.Enums.TipoCliente;

/** POJO que representa a tabela cliente do banco. */
public class Cliente {

    private int         id;
    private String      razaoSocial;
    private String      nomeFantasia;
    private String      cnpj;
    private String      inscricaoEst;
    private TipoCliente tipo;
    private String      logradouro;
    private String      numeroEnd;
    private String      complemento;
    private String      bairro;
    private String      municipio;
    private String      uf;
    private String      cep;
    private String      telefone;
    private String      email;
    private boolean     ativo;

    public Cliente() {}

    // ---- Getters e Setters ----
    public int         getId()            { return id; }
    public String      getRazaoSocial()   { return razaoSocial; }
    public String      getNomeFantasia()  { return nomeFantasia; }
    public String      getCnpj()          { return cnpj; }
    public String      getDocumentoFiscal() { return cnpj; }
    public String      getTipoDocumentoFiscal() {
        String nums = somenteDigitos(cnpj);
        if (nums.length() == 11) return "CPF";
        if (nums.length() == 14) return "CNPJ";
        return "Documento";
    }
    public String      getDocumentoFiscalFormatado() {
        String nums = somenteDigitos(cnpj);
        if (nums.length() == 11) {
            return nums.substring(0, 3) + "." + nums.substring(3, 6) + "."
                 + nums.substring(6, 9) + "-" + nums.substring(9);
        }
        if (nums.length() == 14) {
            return nums.substring(0, 2) + "." + nums.substring(2, 5) + "."
                 + nums.substring(5, 8) + "/" + nums.substring(8, 12)
                 + "-" + nums.substring(12);
        }
        return cnpj;
    }
    public String      getInscricaoEst()  { return inscricaoEst; }
    public TipoCliente getTipo()          { return tipo; }
    public String      getLogradouro()    { return logradouro; }
    public String      getNumeroEnd()     { return numeroEnd; }
    public String      getComplemento()   { return complemento; }
    public String      getBairro()        { return bairro; }
    public String      getMunicipio()     { return municipio; }
    public String      getUf()            { return uf; }
    public String      getCep()           { return cep; }
    public String      getTelefone()      { return telefone; }
    public String      getEmail()         { return email; }
    public boolean     isAtivo()          { return ativo; }

    public void setId(int id)                         { this.id           = id; }
    public void setRazaoSocial(String v)              { this.razaoSocial  = v; }
    public void setNomeFantasia(String v)             { this.nomeFantasia = v; }
    public void setCnpj(String v)                     { this.cnpj         = v; }
    public void setDocumentoFiscal(String v)          { this.cnpj         = v; }
    public void setInscricaoEst(String v)             { this.inscricaoEst = v; }
    public void setTipo(TipoCliente v)                { this.tipo         = v; }
    public void setLogradouro(String v)               { this.logradouro   = v; }
    public void setNumeroEnd(String v)                { this.numeroEnd    = v; }
    public void setComplemento(String v)              { this.complemento  = v; }
    public void setBairro(String v)                   { this.bairro       = v; }
    public void setMunicipio(String v)                { this.municipio    = v; }
    public void setUf(String v)                       { this.uf           = v; }
    public void setCep(String v)                      { this.cep          = v; }
    public void setTelefone(String v)                 { this.telefone     = v; }
    public void setEmail(String v)                    { this.email        = v; }
    public void setAtivo(boolean v)                   { this.ativo        = v; }

    private String somenteDigitos(String valor) {
        return valor == null ? "" : valor.replaceAll("[^0-9]", "");
    }
}
