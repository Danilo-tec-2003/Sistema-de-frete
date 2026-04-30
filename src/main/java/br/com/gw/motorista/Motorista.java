package br.com.gw.motorista;

import br.com.gw.Enums.CategoriaCNH;
import br.com.gw.Enums.StatusMotorista;
import br.com.gw.Enums.TipoVinculo;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class Motorista {

    private static final DateTimeFormatter FMT_DATA =
        DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private int            id;
    private String         nome;
    private String         cpf;
    private LocalDate      dataNascimento;
    private String         telefone;
    private String         cnhNumero;
    private CategoriaCNH   cnhCategoria;
    private LocalDate      cnhValidade;
    private TipoVinculo    tipoVinculo;
    private StatusMotorista status;

    public Motorista() {}

    public int             getId()            { return id; }
    public String          getNome()          { return nome; }
    public String          getCpf()           { return cpf; }
    public LocalDate       getDataNascimento(){ return dataNascimento; }
    public String          getTelefone()      { return telefone; }
    public String          getCnhNumero()     { return cnhNumero; }
    public CategoriaCNH    getCnhCategoria()  { return cnhCategoria; }
    public LocalDate       getCnhValidade()   { return cnhValidade; }
    public TipoVinculo     getTipoVinculo()   { return tipoVinculo; }
    public StatusMotorista getStatus()        { return status; }

    public boolean isCnhVencida() {
        return cnhValidade != null && cnhValidade.isBefore(LocalDate.now());
    }

    public String getCnhValidadeFormatada() {
        return cnhValidade != null ? cnhValidade.format(FMT_DATA) : "";
    }

    public void setId(int id)                          { this.id             = id; }
    public void setNome(String v)                      { this.nome           = v; }
    public void setCpf(String v)                       { this.cpf            = v; }
    public void setDataNascimento(LocalDate v)         { this.dataNascimento = v; }
    public void setTelefone(String v)                  { this.telefone       = v; }
    public void setCnhNumero(String v)                 { this.cnhNumero      = v; }
    public void setCnhCategoria(CategoriaCNH v)        { this.cnhCategoria   = v; }
    public void setCnhValidade(LocalDate v)            { this.cnhValidade    = v; }
    public void setTipoVinculo(TipoVinculo v)          { this.tipoVinculo    = v; }
    public void setStatus(StatusMotorista v)           { this.status         = v; }
}
