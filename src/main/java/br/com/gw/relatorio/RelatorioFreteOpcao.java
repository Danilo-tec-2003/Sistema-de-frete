package br.com.gw.relatorio;

/**
 * Opção de frete para o select do catálogo de relatórios.
 */
public class RelatorioFreteOpcao {

    private int id;
    private String numero;
    private String descricao;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNumero() { return numero; }
    public void setNumero(String numero) { this.numero = numero; }

    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }
}
