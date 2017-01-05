package br.com.vah.painelps;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@Path("/api")
public class MainApp {

  @GET
  @Path("/painel")
  @Produces("application/json")
  public String painel() {
    return "Hello World!";
  }

}
