package br.com.vah.painelps;

import br.com.vah.painelps.services.PainelSrv;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

@Path("/api")
public class MainApp {

  @Inject
  private PainelSrv painelSrv;

  @GET
  @Path("/painel")
  @Produces("application/json")
  public List<Map<String, Object>> painel() {
    return painelSrv.especialidadeAtendimento();
  }

  @GET
  @Path("/exames/{atendimento}")
  @Produces("application/json")
  public List<String> exames(@PathParam("atendimento") Long atendimento) {
    return painelSrv.getExames(atendimento);
  }

}
