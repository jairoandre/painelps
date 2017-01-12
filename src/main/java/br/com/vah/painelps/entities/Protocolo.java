package br.com.vah.painelps.entities;

import br.com.vah.painelps.constants.ProtocoloEnum;

import javax.persistence.*;
import java.io.Serializable;

/**
 * Created by Jairoportela on 11/01/2017.
 */
@Entity
@Table(name = "TB_PAINELPS_PROTOCOLO", schema = "USRDBVAH")
public class Protocolo implements Serializable {

  @Id
  @Column(name = "ID")
  private Long id;


  @Enumerated
  @Column(name = "CD_TIPO")
  private ProtocoloEnum tipo;

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public ProtocoloEnum getTipo() {
    return tipo;
  }

  public void setTipo(ProtocoloEnum tipo) {
    this.tipo = tipo;
  }
}
