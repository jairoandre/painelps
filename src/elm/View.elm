module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)


customDiv : String -> String -> List (Html Msg) -> Html Msg
customDiv oClass iClass contents =
    div [ class oClass ]
        [ div [ class iClass ] contents ]


lPaddDiv : String -> Html Msg -> Html Msg
lPaddDiv oClass content =
    customDiv oClass "ellipsis-text lpadd" [ content ]


rPaddDiv : String -> Html Msg -> Html Msg
rPaddDiv oClass content =
    customDiv oClass "ellipsis-text rpadd" [ content ]


centeringDiv : String -> Html Msg -> Html Msg
centeringDiv oClass content =
    customDiv oClass "centering" [ content ]


classificacaoToHtml : String -> Html Msg
classificacaoToHtml classificacao =
    let
        classificacaoClass =
            "classificacao classificacao--" ++ classificacao
    in
        div [ class classificacaoClass ] []


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


scrollableItems : Int -> List String -> Html Msg
scrollableItems counter items =
    let
        lenItems =
            List.length items

        visibleItems =
            if lenItems < 3 then
                items
            else
                let
                    modLen =
                        counter % lenItems
                in
                    List.take 3 <| ((List.drop modLen items) ++ (List.take modLen items))
    in
        div [] <| List.map (\s -> div [ class "ellipsis-text" ] [ text s ]) visibleItems


protocoloToHtml : Int -> Html Msg
protocoloToHtml protocolo =
    if protocolo > -1 then
        div [ class ("protocolo protocolo--" ++ toString protocolo) ]
            [ case protocolo of
                0 ->
                    text "SEPSE"

                1 ->
                    text "DOR TORÁX."

                2 ->
                    text "CÓLICA RENAL"

                _ ->
                    text "AVC"
            ]
    else
        text ""


pacientesToHtml : Int -> Int -> PacientePS -> Html Msg
pacientesToHtml counter idx paciente =
    div [ class <| "row row--" ++ (toString idx) ]
        [ customDiv "td td-atendimento"
            "lpadd"
            [ div [ class "ellipsis-text" ] [ text <| (toString paciente.atendimento) ++ " - " ++ paciente.convenio ]
            , div [ class "ellipsis-text" ] [ text paciente.especialidade ]
            ]
        , div [ class "td td-classificacao" ] [ classificacaoToHtml paciente.classificacao ]
        , lPaddDiv "td td-paciente" <| text paciente.nome
        , customDiv "td td-convenio" "" [ div [ class ("convenio convenio--" ++ paciente.convenio) ] [] ]
        , customDiv "td td-observacao" "in-observacao" <|
            [ scrollableItems counter <|
                List.filter (\s -> s /= "") <|
                    ((String.split "\x0D" paciente.observacao)
                        ++ (String.split " " paciente.alergias)
                    )
            ]
        , customDiv "td td-etapa" "" [ etapaToHtml paciente ]
        , rPaddDiv "td td-tempo" <| text <| fancyTime paciente.tempo
        , customDiv "td td-exames" "in-exames" [ scrollableItems counter paciente.exames ]
        , centeringDiv "td td-protocolo" <| protocoloToHtml paciente.protocolo
        , div [ class "td td-internar" ] <|
            if paciente.internacao then
                [ div [ class "internar" ] [] ]
            else
                [ div [ class "internar internar--nao" ] [] ]
        ]


headerView : Html Msg
headerView =
    div [ class "header" ]
        [ lPaddDiv "th th-atendimento" <| text "ATEND./ESPEC."
        , centeringDiv "th th-classificacao" <| text "CLASS."
        , lPaddDiv "th th-paciente" <| text "PACIENTE"
        , centeringDiv "th th-convenio" <| text "CONV."
        , lPaddDiv "th th-observacao" <| text "OBS./ALERGIAS"
        , centeringDiv "th th-etapa" <| text "ETAPA"
        , rPaddDiv "th th-tempo" <| text "TEMPO"
        , lPaddDiv "th th-exames" <| text "EXAMES"
        , centeringDiv "th th-protocolo" <| text "PROTOC."
        , centeringDiv "th th-internar" <| text "INTER."
        ]


patientsPerPage : Int
patientsPerPage =
    8


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
            div
                [ class "content"
                , style
                    [ ( "-webkit-transform", "scale(0.655)" )
                    , ( "-webkit-transform-origin", "0 0" )
                    ]
                ]
                [ headerView
                , div [ class "rows" ] <|
                    List.indexedMap (pacientesToHtml model.counter) <|
                        List.take patientsPerPage <|
                            List.drop (model.page * patientsPerPage) model.pacientes
                ]

        Just e ->
            div [ style [ ( "position", "absolute" ), ( "padding", "20px" ), ( "color", "#fff" ) ] ] [ text <| (toString e) ]
