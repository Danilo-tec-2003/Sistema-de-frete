package br.com.gw.nucleo.login;

import java.io.Serializable;

/** POJO do usuário — guardado na sessão HTTP após login. */
public class Usuario implements Serializable {

    private static final long serialVersionUID = 1L;

    private int    id;
    private String nome;
    private String login;

    public Usuario() {}

    public Usuario(int id, String nome, String login) {
        this.id    = id;
        this.nome  = nome;
        this.login = login;
    }

    public int    getId()    { return id;    }
    public String getNome()  { return nome;  }
    public String getLogin() { return login; }

    public void setId(int id)        { this.id    = id;    }
    public void setNome(String nome) { this.nome  = nome;  }
    public void setLogin(String l)   { this.login = l;     }
}