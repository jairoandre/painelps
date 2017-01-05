package br.com.vah.painelps.services;

import javax.ejb.Stateless;
import java.util.*;

@Stateless
public class PainelSrv extends AbstractSrv {

  public List<Map<String, Object>> especialidadeAtendimento() {

    String sql =
        "SELECT " +
            "  ATD.CD_PACIENTE, " +
            "  PAC.NM_PACIENTE, " +
            "  ATD.CD_ATENDIMENTO, " +
            "  CONV.NM_CONVENIO, " +
            "  ESP.DS_ESPECIALID, " +
            "  ATD.TP_PRIORIDADE, " +
            "  ATD.NR_CHAMADA_PAINEL, " +
            "  COR.NM_COR, " +
            "  CLAS.DS_TIPO_RISCO, " +
            "  TEMP_PRO.CD_TIPO_TEMPO_PROCESSO, " +
            "  TIP_TEMP_PRO.DS_TIPO_TEMPO_PROCESSO, " +
            "  TEMP_PRO.DH_PROCESSO, " +
            "  TATD.DS_ALERGIA, " +
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
            "  LEFT JOIN DBAMV.SACR_CLASSIFICACAO_RISCO CLAS_RISCO " +
            "    ON TATD.CD_TRIAGEM_ATENDIMENTO = CLAS_RISCO.CD_TRIAGEM_ATENDIMENTO " +
            "  LEFT JOIN DBAMV.SACR_CLASSIFICACAO CLAS " +
            "    ON CLAS_RISCO.CD_CLASSIFICACAO = CLAS.CD_CLASSIFICACAO " +
            "  LEFT JOIN DBAMV.SACR_COR_REFERENCIA COR " +
            "    ON CLAS.CD_COR_REFERENCIA = COR.CD_COR_REFERENCIA " +
            "  LEFT JOIN DBAMV.SACR_TEMPO_PROCESSO TEMP_PRO " +
            "    ON ATD.CD_ATENDIMENTO = TEMP_PRO.CD_ATENDIMENTO " +
            "  LEFT JOIN DBAMV.SACR_TIPO_TEMPO_PROCESSO TIP_TEMP_PRO " +
            "    ON TEMP_PRO.CD_TIPO_TEMPO_PROCESSO = TIP_TEMP_PRO.CD_TIPO_TEMPO_PROCESSO " +
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
        atendimento.put("codigo", row[0]);
        atendimento.put("nome", row[1]);
        atendimento.put("atendimento", row[2]);
        atendimento.put("convenio", row[3]);
        atendimento.put("especialidade", row[4]);
        atendimento.put("prioridade", row[5]);
        atendimento.put("chamada", row[6]);
        atendimento.put("cor", row[7]);
        atendimento.put("risco", row[8]);
        atendimento.put("processo", row[9]);
        atendimento.put("etapaAtual", row[10]);
        atendimento.put("tempo", 0);
        inicioAtendimentoMap.put(row[0], (Date) row[11]);
        atendimento.put("alergia", row[12]);
        atendimento.put("observacao", row[13]);
        atendimentos.put(row[0], atendimento);
        result.add(atendimento);
      } else {
        atendimento.put("etapa", row[10]);
        long deltaTime = ((Date) row[11]).getTime() - inicioAtendimentoMap.get(row[0]).getTime();
        atendimento.put("tempo", deltaTime / 3600);
      }
    }
    return result;
  }

}
