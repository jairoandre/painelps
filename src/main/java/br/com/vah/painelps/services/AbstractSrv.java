package br.com.vah.painelps.services;

import org.hibernate.SQLQuery;
import org.hibernate.Session;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * Created by Jairoportela on 10/11/2016.
 */
public abstract class AbstractSrv implements Serializable {

  @PersistenceContext
  private EntityManager em;

  public Session getSession() {
    return em.unwrap(Session.class);
  }

  public List<Object[]> runSql(String sql, Map<String, Object> params) {

    Session session = getSession();

    SQLQuery query = session.createSQLQuery(sql);

    for (String key : params.keySet()) {
      query.setParameter(key, params.get(key));
    }

    return query.list();

  }
}
