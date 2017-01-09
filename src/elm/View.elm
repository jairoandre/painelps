module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)


customDiv : String -> String -> Html Msg -> Html Msg
customDiv oClass iClass content =
    div [ class oClass ]
        [ div [ class iClass ] [ content ] ]


lPaddDiv : String -> Html Msg -> Html Msg
lPaddDiv oClass content =
    customDiv oClass "ellipsis-text lpadd" content


rPaddDiv : String -> Html Msg -> Html Msg
rPaddDiv oClass content =
    customDiv oClass "ellipsis-text rpadd" content


centeringDiv : String -> Html Msg -> Html Msg
centeringDiv oClass content =
    customDiv oClass "centering" content


riscoToHtml : Int -> Html Msg
riscoToHtml risco =
    let
        riscoClass =
            "risco risco--" ++ (toString risco)
    in
        div [ class riscoClass ] []


etapaToHtml : PacientePS -> Html Msg
etapaToHtml paciente =
    if paciente.prescricao then
        div [ class "etapa etapa--enfermagem" ] []
    else if List.member paciente.etapa [ 1, 10, 11, 12, 20, 21, 22 ] then
        div [ class "etapa etapa--recepcao" ] []
    else if List.member paciente.etapa [ 30, 31, 32 ] then
        div [ class "etapa etapa--medico" ] []
    else
        div [ class "etapa" ] [ text <| toString paciente.etapa ]


observacaoToHtml : String -> Html Msg
observacaoToHtml observacao =
    div [] <| List.map (\s -> div [] [ text s ]) (String.split "\x0D" observacao)


pacientesToHtml : Int -> PacientePS -> Html Msg
pacientesToHtml idx paciente =
    div [ class <| "row row--" ++ (toString idx) ]
        [ lPaddDiv "td td-atendimento" <| text <| toString paciente.atendimento
        , div [ class "td td-risco" ] [ riscoToHtml paciente.risco ]
        , lPaddDiv "td td-paciente" <| text paciente.nome
        , lPaddDiv "td td-convenio" <| text paciente.convenio
        , customDiv "td td-observacao" "in-observacao" <| observacaoToHtml paciente.observacao
        , customDiv "td td-etapa" "" <| etapaToHtml paciente
        , rPaddDiv "td td-tempo" <| text <| fancyTime paciente.tempo
        , lPaddDiv "td td-exames" <| text "?"
        , lPaddDiv "td td-protocolo" <| text "?"
        , lPaddDiv "td td-internar" <| text "?"
        ]


headerView : Html Msg
headerView =
    div [ class "header" ]
        [ lPaddDiv "th th-atendimento" <| text "ATEND."
        , centeringDiv "th th-risco" <| text "RISCO"
        , lPaddDiv "th th-paciente" <| text "PACIENTE"
        , lPaddDiv "th th-convenio" <| text "CONVÊNIO"
        , lPaddDiv "th th-observacao" <| text "OBS."
        , centeringDiv "th th-etapa" <| text "ETAPA"
        , rPaddDiv "th th-tempo" <| text "TEMPO"
        , lPaddDiv "th th-exames" <| text "EXAMES"
        , lPaddDiv "th th-protocolo" <| text "PROTOC."
        , lPaddDiv "th th-internar" <| text "INTERNAR"
        ]


fancyTime : Int -> String
fancyTime minutes =
    let
        hours =
            toString (minutes // 60)

        mins =
            toString (minutes % 60)
    in
        if hours == "0" then
            mins ++ "m"
        else
            hours ++ "h " ++ mins ++ "m"


view : Model -> Html Msg
view model =
    case model.error of
        Nothing ->
            div [ class "content", style [ ( "transform", "scale(0.70)" ) ] ]
                [ headerView
                , div [ class "rows" ] <| List.indexedMap pacientesToHtml <| List.take 10 <| List.drop (model.page * 10) model.pacientes
                ]

        Just e ->
            div [ style [ ( "position", "absolute" ), ( "padding", "20px" ), ( "color", "#fff" ) ] ] [ text <| (toString e) ]
