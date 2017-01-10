package br.com.vah.painelps.services;

import javax.ejb.Stateless;
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
            "  TATD.DS_OBSERVACAO " +
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
        atendimentos.put(row[0], atendimento);
        result.add(atendimento);
      } else {
        atendimento.put("etapa", row[5]);
        long deltaTime = ((Date) row[6]).getTime() - inicioAtendimentoMap.get(row[0]).getTime();
        atendimento.put("tempo", deltaTime / 60000);
        if (row[8] != null) {
          atendimento.put("prescricao", true);
        }
      }
    }
    result.sort((Map o1, Map o2) -> (int) ((long) o2.get("tempo") - (long) o1.get("tempo")));
    return result;
  }

  public List<String> getExames(Long atendimento) {
    String sql =
        "SELECT " +
            "    TP.DS_TIP_PRESC " +
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

    List<String> result = new ArrayList<>();

    for (Object row : rows) {
      if (row != null) {
        result.add((String) row);
      }
    }

    return result;
  }

}
