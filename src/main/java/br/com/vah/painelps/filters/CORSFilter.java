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
    ((HttpServletResponse) response).addHeader("Access-Control-Allow-Headers", "Content-Type");
    ((HttpServletResponse) response).addHeader("Access-Control-Allow-Methods", "GET,POST,DELETE,PUT,OPTIONS");
    chain.doFilter(request, response);
  }
}
