package br.com.gw.nucleo.login;

import java.io.Serializable;

/** POJO do usuário — guardado na sessão HTTP após login. */
public class Usuario implements Serializable {

    private static final long serialVersionUID = 1L;

    private int    id;
    private String nome;
    private String login;
    private String senha;
    private boolean ativo;

    public Usuario() {}

    public Usuario(int id, String nome, String login) {
        this.id    = id;
        this.nome  = nome;
        this.login = login;
    }

    public Usuario(int id, String nome, String login, String senha, Boolean ativo) {
        this.id    = id;
        this.nome  = nome;
        this.login = login;
        this.senha = senha;
        this.ativo = ativo;
    }

    public int    getId()    { return id;    }
    public String getNome()  { return nome;  }
    public String getLogin() { return login; }
    public String getSenha() {return senha;}
    public boolean getAtivo() { return ativo; }

    public void setId(int id)        { this.id    = id;    }
    public void setNome(String nome) { this.nome  = nome;  }
    public void setLogin(String l)   { this.login = l;     }
    public void setSenha(String s)   { this.senha = s; }
    public void setAtivo(boolean a)  { this.ativo = a; }




}