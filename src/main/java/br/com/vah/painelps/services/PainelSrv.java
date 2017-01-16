package br.com.vah.painelps.services;

import org.hibernate.SQLQuery;
import org.hibernate.Session;

import javax.ejb.Stateless;
import java.math.BigDecimal;
import java.util.*;

@Stateless
public class PainelSrv extends AbstractSrv {

  public List<Map<String, Object>> especialidadeAtendimento() {

    String sql =
        "SELECT " +
            "  ATD.CD_ATENDIMENTO, " +
            "  PAC.NM_PACIENTE, " +
            "  CONV.NM_CONVENIO, " +
            "  ESP.DS_ESPECIALID, " +
            "  COR.NM_COR, " +
            "  TEMP_PRO.CD_TIPO_TEMPO_PROCESSO, " +
            "  TEMP_PRO.DH_PROCESSO, " +
            "  TATD.DS_ALERGIA, " +
            "  PM.DH_IMPRESSAO, " +
            "  TATD.DS_OBSERVACAO, " +
            "  IPM.CD_TIP_PRESC, " +
            "  RD.CD_DOCUMENTO, " +
            "  PROT.CD_TIPO " +
            "FROM DBAMV.TB_ATENDIME ATD " +
            "  JOIN DBAMV.ESPECIALID ESP " +
            "    ON ATD.CD_ESPECIALID = ESP.CD_ESPECIALID " +
            "  JOIN DBAMV.CONVENIO CONV " +
            "    ON ATD.CD_CONVENIO = CONV.CD_CONVENIO " +
            "  JOIN DBAMV.PACIENTE PAC " +
            "    ON ATD.CD_PACIENTE = PAC.CD_PACIENTE " +
            "  LEFT JOIN DBAMV.TRIAGEM_ATENDIMENTO TATD " +
            "    ON ATD.CD_ATENDIMENTO = TATD.CD_ATENDIMENTO " +
            "  LEFT JOIN DBAMV.SACR_COR_REFERENCIA COR " +
            "    ON TATD.CD_COR_REFERENCIA = COR.CD_COR_REFERENCIA " +
            "  LEFT JOIN DBAMV.SACR_TEMPO_PROCESSO TEMP_PRO " +
            "    ON ATD.CD_ATENDIMENTO = TEMP_PRO.CD_ATENDIMENTO " +
            "  LEFT JOIN DBAMV.PRE_MED PM " +
            "    ON ATD.CD_ATENDIMENTO = PM.CD_ATENDIMENTO " +
            "  LEFT JOIN DBAMV.ITPRE_MED IPM " +
            "    ON PM.CD_PRE_MED = IPM.CD_PRE_MED AND IPM.CD_TIP_PRESC IN ('25936', '25935', '25934', '25927', '25937') " +
            "  LEFT JOIN DBAMV.REGISTRO_DOCUMENTO RD " +
            "    ON ATD.CD_ATENDIMENTO = RD.CD_ATENDIMENTO AND RD.CD_DOCUMENTO = 168 " +
            "  LEFT JOIN USRDBVAH.TB_PAINELPS_PROTOCOLO PROT " +
            "    ON ATD.CD_ATENDIMENTO = PROT.ID " +
            "WHERE ATD.TP_ATENDIMENTO = 'U' " +
            "      AND ATD.DT_ALTA IS NULL " +
            "      AND ATD.CD_MULTI_EMPRESA = 1 " +
            "      AND ATD.DT_ATENDIMENTO >= :DATE " +
            "ORDER BY CD_PACIENTE, DH_PROCESSO";

    Map<String, Object> params = new HashMap<>();
    Calendar cld = Calendar.getInstance();
    cld.add(Calendar.HOUR, -24);
    params.put("DATE", cld.getTime());

    List<Object[]> rows = runSql(sql, params);

    List<Map<String, Object>> result = new ArrayList<>();

    Map<Object, Map<String, Object>> atendimentos = new HashMap<>();
    Map<Object, Date> inicioAtendimentoMap = new HashMap<>();

    for (Object[] row : rows) {
      Map<String, Object> atendimento = atendimentos.get(row[0]);
      if (atendimento == null) {
        atendimento = new HashMap<>();
        atendimento.put("atendimento", row[0]);
        atendimento.put("nome", row[1]);
        atendimento.put("convenio", row[2]);
        atendimento.put("especialidade", row[3]);
        atendimento.put("classificacao", row[4]);
        atendimento.put("etapa", row[5]);
        atendimento.put("entrada", row[6]);
        atendimento.put("tempo", 0);
        inicioAtendimentoMap.put(row[0], (Date) row[6]);
        atendimento.put("alergias", row[7]);
        atendimento.put("prescricao", row[8] != null);
        atendimento.put("observacao", row[9]);
        atendimento.put("internacao", row[10] != null);
        atendimento.put("sepse", row[11] != null && ((BigDecimal) row[11]).intValue() == 168);
        atendimento.put("protocolo", row[12]);
        atendimentos.put(row[0], atendimento);
        result.add(atendimento);
      } else {
        atendimento.put("etapa", row[5]);
        long deltaTime = ((Date) row[6]).getTime() - inicioAtendimentoMap.get(row[0]).getTime();
        atendimento.put("tempo", deltaTime / 60000);
        if (row[8] != null) {
          atendimento.put("prescricao", true);
        }
        if (row[10] != null) {
          atendimento.put("internacao", true);
        }
        if (row[11] != null && ((BigDecimal) row[11]).intValue() == 168) {
          atendimento.put("sepse", true);
        }

      }
    }
    result.sort((Map o1, Map o2) -> (int) ((long) o2.get("tempo") - (long) o1.get("tempo")));
    return result;
  }

  public List<String> getExames(Integer atendimento) {
    String sql = "SELECT " +
        "  TP.DS_TIP_PRESC " +
        "FROM DBAMV.PRE_MED PM " +
        "  LEFT JOIN DBAMV.ITPRE_MED IPM " +
        "    ON PM.CD_PRE_MED = IPM.CD_PRE_MED " +
        "       AND IPM.CD_TIP_ESQ IN ('ETR', 'ECA', 'LAB', 'EXA', 'EXC', 'LAS', 'ERX', 'EUS') " +
        "  LEFT JOIN DBAMV.TIP_PRESC TP " +
        "    ON IPM.CD_TIP_PRESC = TP.CD_TIP_PRESC " +
        "  LEFT JOIN USRDBVAH.TB_PAINELPS_PROTOCOLO PROT " +
        "    ON PROT.ID = PM.CD_ATENDIMENTO " +
        "WHERE PM.CD_ATENDIMENTO = :CD_ATENDIMENTO " +
        "      AND " +
        "      (PROT.LS_EXAMES_REALIZADOS IS NULL OR PROT.LS_EXAMES_REALIZADOS NOT LIKE '%' || TO_CHAR(IPM.CD_ITPRE_MED) || '%')";

    Map<String, Object> params = new HashMap<>();
    params.put("CD_ATENDIMENTO", atendimento);

    List<Object[]> rows = runSql(sql, params);

    List<String> result = new ArrayList<>();

    for (Object row : rows) {
      if (row != null) {
        result.add((String) row);
      }
    }

    return result;
  }

  public List<Map<String, Object>> getExamesComIds(Integer atendimento) {
    String sql =
        "SELECT " +
            "IPM.CD_ITPRE_MED, TP.DS_TIP_PRESC " +
            "FROM DBAMV.PRE_MED PM " +
            "  LEFT JOIN DBAMV.ITPRE_MED IPM " +
            "    ON PM.CD_PRE_MED = IPM.CD_PRE_MED " +
            "       AND IPM.CD_TIP_ESQ IN ('ETR','ECA','LAB','EXA','EXC','LAS','ERX','EUS') " +
            "  LEFT JOIN DBAMV.TIP_PRESC TP " +
            "    ON IPM.CD_TIP_PRESC = TP.CD_TIP_PRESC " +
            "WHERE PM.CD_ATENDIMENTO = :CD_ATENDIMENTO";

    Map<String, Object> params = new HashMap<>();
    params.put("CD_ATENDIMENTO", atendimento);

    List<Object[]> rows = runSql(sql, params);

    List<Map<String, Object>> result = new ArrayList<>();

    for (Object[] row : rows) {
      if (row != null) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", row[0]);
        map.put("descricao", row[1]);
        if (row[0] != null && row[1] != null) {
          result.add(map);
        }
      }
    }

    return result;
  }

  public String protocolo(Map body) {
    String queryStr =
        "SELECT COUNT(*) FROM USRDBVAH.TB_PAINELPS_PROTOCOLO WHERE ID = :ID";

    Integer atendimento = (Integer) body.get("atendimento");
    Integer tipo = (Integer) body.get("tipo");
    String examesRealizados = (String) body.get("examesRealizados");

    Session session = getSession();
    String output;

    SQLQuery query = session.createSQLQuery(queryStr);

    query.setParameter("ID", atendimento);

    BigDecimal countResult = (BigDecimal) query.uniqueResult();

    if (BigDecimal.ZERO.equals(countResult)) {
      queryStr =
          "INSERT INTO USRDBVAH.TB_PAINELPS_PROTOCOLO (ID, CD_TIPO, LS_EXAMES_REALIZADOS) VALUES (:ID, :CD_TIPO, :LS_EXAMES_REALIZADOS)";
      output = "Protocolo cadastrado";
    } else {
      queryStr =
          "UPDATE USRDBVAH.TB_PAINELPS_PROTOCOLO SET CD_TIPO = :CD_TIPO, LS_EXAMES_REALIZADOS = :LS_EXAMES_REALIZADOS WHERE ID = :ID";
      output = "Protocolo atualizado";
    }
    query = session.createSQLQuery(queryStr);
    query.setParameter("CD_TIPO", tipo);
    query.setParameter("ID", atendimento);
    query.setParameter("LS_EXAMES_REALIZADOS", examesRealizados);
    query.executeUpdate();
    return output;
  }

  public Map<String, Object> pacienteByAtendimento(Integer atendimento) {
    String sql =
        "SELECT PAC.NM_PACIENTE, " +
            "CONV.NM_CONVENIO, " +
            "PROT.CD_TIPO, " +
            "PROT.LS_EXAMES_REALIZADOS " +
            "FROM DBAMV.TB_ATENDIME ATD " +
            "  LEFT JOIN DBAMV.PACIENTE PAC " +
            "    ON ATD.CD_PACIENTE = PAC.CD_PACIENTE " +
            "  LEFT JOIN DBAMV.CONVENIO CONV " +
            "    ON ATD.CD_CONVENIO = CONV.CD_CONVENIO " +
            "  LEFT JOIN USRDBVAH.TB_PAINELPS_PROTOCOLO PROT " +
            "    ON ATD.CD_ATENDIMENTO = PROT.ID " +
            "WHERE CD_ATENDIMENTO = :CD_ATENDIMENTO";

    Session session = getSession();
    SQLQuery query = session.createSQLQuery(sql);
    query.setParameter("CD_ATENDIMENTO", atendimento);

    List<Object[]> result = query.list();

    Map<String, Object> map = new HashMap<>();

    List<BigDecimal> examesIds = new ArrayList<>();


    for (Object[] row : result) {
      map.put("nome", row[0]);
      map.put("convenio", row[1]);
      map.put("tipo", row[2]);
      map.put("examesRealizados", row[3]);
      String row_3 = (String) row[3];
      if (row_3 != null) {
        String[] exames = row_3.split(";");
        for (String exameIdStr : exames) {
          examesIds.add(new BigDecimal(exameIdStr));
        }
      }
    }

    map.put("exames", getExamesComIds(atendimento));

    for (Map<String, Object> exame : (List<Map>) map.get("exames")) {
      exame.put("realizado", examesIds.contains(exame.get("id")));
    }

    return map;

  }

}
