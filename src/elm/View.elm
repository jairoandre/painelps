module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)


paddingDiv : String -> Html Msg -> Html Msg
paddingDiv oClass content =
    div [ class oClass ]
        [ div [ class "div-padd-left" ] [ content ] ]


pacientesToHtml : Int -> PacientePS -> Html Msg
pacientesToHtml idx paciente =
    div [ class <| "row row--" ++ (toString idx) ]
        [ paddingDiv "td td-atendimento" <| text <| toString paciente.atendimento
        , paddingDiv "td td-risco" <| text paciente.risco
        , paddingDiv "td td-paciente" <| text paciente.nome
        , paddingDiv "td td-convenio" <| text paciente.convenio
        , paddingDiv "td td-observacao" <| text paciente.observacao
        , paddingDiv "td td-etapa" <| text paciente.etapa
        , paddingDiv "td td-tempo" <| text <| toString paciente.tempo
        , paddingDiv "td td-exames" <| text "?"
        , paddingDiv "td td-protocolo" <| text "?"
        , paddingDiv "td td-internar" <| text "?"
        ]


headerView : Html Msg
headerView =
    div [ class "header" ]
        [ paddingDiv "th th-atendimento" <| text "ATEND."
        , paddingDiv "th th-risco" <| text "RISCO"
        , paddingDiv "th th-paciente" <| text "PACIENTE"
        , paddingDiv "th th-convenio" <| text "CONVÊNIO"
        , paddingDiv "th th-observacao" <| text "OBS."
        , paddingDiv "th th-etapa" <| text "ETAPA"
        , paddingDiv "th th-tempo" <| text "TEMPO"
        , paddingDiv "th th-exames" <| text "EXAMES"
        , paddingDiv "th th-protocolo" <| text "PROTOC."
        , paddingDiv "th th-internar" <| text "INTERNAR"
        ]


view : Model -> Html Msg
view model =
    div [ class "content", style [ ( "transform", "scale(0.65)" ) ] ]
        [ headerView
        , div [ class "rows" ] <| List.indexedMap pacientesToHtml <| List.take 10 model.pacientes
        ]
