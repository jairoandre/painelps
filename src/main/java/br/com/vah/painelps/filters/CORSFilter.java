package br.com.vah.painelps.filters;

import javax.servlet.*;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class CORSFilter implements Filter {

  public CORSFilter() {}

  public void init(FilterConfig fConfig) throws ServletException {}

  public void destroy() {}

  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
    ((HttpServletResponse) response).addHeader("Access-Control-Allow-Origin", "*");
    chain.doFilter(request, response);
  }
}
