package br.com.vah.painelps;

import br.com.vah.painelps.services.PainelSrv;

import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
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
  public List<String> exames(@PathParam("atendimento") Integer atendimento) {
    return painelSrv.getExames(atendimento);
  }

  @POST
  @Path("/protocolo")
  @Consumes("application/json")
  @Produces("application/json")
  public Response protocolo(Map body) {
    String message = painelSrv.protocolo(body);
    Map<String, Object> output = new HashMap<>();
    output.put("message", message);
    return Response.status(200).entity(output).build();
  }

  @GET
  @Path("/atendimento/{atendimento}")
  @Produces("application/json")
  public Map<String, Object> atendimento(@PathParam("atendimento") Integer atendimento) {
    return painelSrv.pacienteByAtendimento(atendimento);
  }



}
