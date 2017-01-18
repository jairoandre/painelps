module Protocolo exposing (..)

import Html exposing (Html, div, text, input, label, span)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as JD
import Json.Encode as JE
import Char
import Time
import Http
import Bitwise


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type MessageType
    = ErrorMessage
    | InfoMessage
    | SuccessMessage


type alias Model =
    { atendimento : String
    , paciente : String
    , tipo : Int
    , search : Bool
    , timer : Int
    , messages : Maybe (List ( MessageType, String ))
    , showForm : Bool
    , convenio : String
    , exames : List Exame
    , loading : Bool
    }


type Msg
    = ChangeAtendimento String
    | ChangeTipo Int
    | SearchAtendimento Time.Time
    | ReceivePaciente (Result Http.Error Paciente)
    | SavePaciente (Result Http.Error String)
    | PostPaciente
    | ToggleExame Int


type alias Paciente =
    { nome : String
    , convenio : String
    , tipo : Int
    , exames : List Exame
    , examesRealizados : String
    }


type alias Exame =
    { id : Int
    , descricao : String
    , realizado : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" "" 0 False 0 Nothing False "" [] False, Cmd.none )


maybeString : JD.Decoder String
maybeString =
    JD.oneOf [ JD.null "", JD.string ]


decodeExame : JD.Decoder Exame
decodeExame =
    JD.map3 Exame
        (JD.field "id" JD.int)
        (JD.field "descricao" JD.string)
        (JD.field "realizado" JD.bool)


decodePaciente : JD.Decoder Paciente
decodePaciente =
    JD.map5 Paciente
        (JD.field "nome" maybeString)
        (JD.field "convenio" maybeString)
        (JD.field "tipo" (JD.oneOf [ JD.null 0, JD.int ]))
        (JD.field "exames" (JD.list decodeExame))
        (JD.field "examesRealizados" maybeString)


urlPrefix : String
urlPrefix =
    if False then
        "http://10.1.0.105:8080/painelps/rest/api/"
    else
        "rest/api/"


fetchPaciente : String -> Cmd Msg
fetchPaciente atendimento =
    Http.send ReceivePaciente (Http.get (urlPrefix ++ "atendimento/" ++ atendimento) decodePaciente)


defaultInt : String -> Int
defaultInt str =
    Result.withDefault -1 (String.toInt str)


idExameRealizado : Exame -> String
idExameRealizado exame =
    if exame.realizado then
        (toString exame.id)
    else
        ""


filterIds : String -> Bool
filterIds id =
    id /= ""


examesRealizados : Model -> String
examesRealizados model =
    String.join ";" (List.filter filterIds (List.map idExameRealizado model.exames))


encodePaciente : Model -> JE.Value
encodePaciente model =
    JE.object
        [ ( "atendimento", JE.int <| defaultInt model.atendimento )
        , ( "tipo", JE.int model.tipo )
        , ( "examesRealizados", JE.string (examesRealizados model) )
        ]


decodePostMessage : JD.Decoder String
decodePostMessage =
    JD.field "message" JD.string


postPaciente : Model -> Cmd Msg
postPaciente model =
    Http.send
        SavePaciente
        (Http.post (urlPrefix ++ "protocolo") (Http.jsonBody (encodePaciente model)) decodePostMessage)


formartErrorMessage : Http.Error -> String
formartErrorMessage message =
    case message of
        Http.BadUrl msg ->
            "Endereço inválido: " ++ msg

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "Erro de rede"

        Http.BadStatus resp ->
            "Status: " ++ (toString resp.status.code) ++ " | Messagem: " ++ (toString resp.status.message)

        Http.BadPayload msg resp ->
            "BadPayload: " ++ msg


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ChangeAtendimento newValue ->
            ( { model
                | atendimento = (String.filter Char.isDigit newValue)
                , search = True
                , showForm = False
                , timer = 600
                , messages = Nothing
                , tipo = 0
                , exames = []
              }
            , Cmd.none
            )

        ChangeTipo tipo ->
            let
                newTipo =
                    if tipo == 0 then
                        0
                    else
                        Bitwise.xor model.tipo tipo
            in
                ( { model | tipo = newTipo, messages = Just [ ( InfoMessage, "Existem mudanças não salvas" ) ] }, Cmd.none )

        SearchAtendimento newTime ->
            if model.timer > 0 then
                ( { model | timer = model.timer - 10 }, Cmd.none )
            else if (model.search && (String.length model.atendimento > 0)) then
                ( { model | timer = 0, search = False, loading = True }, fetchPaciente model.atendimento )
            else
                ( { model | timer = 0 }, Cmd.none )

        ReceivePaciente (Err e) ->
            ( { model
                | messages =
                    Just
                        [ ( ErrorMessage, formartErrorMessage e )
                        , ( ErrorMessage, "Paciente não encontrado" )
                        ]
                , loading = False
              }
            , Cmd.none
            )

        ReceivePaciente (Ok paciente) ->
            ( { model
                | paciente = paciente.nome
                , convenio = paciente.convenio
                , exames = paciente.exames
                , tipo = paciente.tipo
                , showForm = True
                , loading = False
              }
            , Cmd.none
            )

        SavePaciente (Err e) ->
            ( { model | messages = Just [ ( ErrorMessage, formartErrorMessage e ) ] }, Cmd.none )

        SavePaciente (Ok str) ->
            ( { model | messages = Just [ ( SuccessMessage, "Alterações registradas." ) ] }, Cmd.none )

        PostPaciente ->
            ( model, postPaciente model )

        ToggleExame exameId ->
            let
                updatedExames =
                    List.map (toggleExame exameId) model.exames
            in
                ( { model | exames = updatedExames, messages = Just [ ( InfoMessage, "Mudanças pendentes de registro." ) ] }, Cmd.none )


toggleExame : Int -> Exame -> Exame
toggleExame exameId exame =
    if exameId == exame.id then
        { exame | realizado = not exame.realizado }
    else
        exame


buttonClass : Model -> String -> Int -> String
buttonClass model btnClass tipo =
    if tipo == 0 then
        if model.tipo == 0 then
            "protocolo protocolo--nenhum"
        else
            "protocolo"
    else if (Bitwise.and model.tipo tipo) == tipo then
        "protocolo protocolo--" ++ btnClass
    else
        "protocolo"


printMessage : ( MessageType, String ) -> Html Msg
printMessage msgTuple =
    let
        ( t, m ) =
            msgTuple
    in
        case t of
            ErrorMessage ->
                div [ class "message message--error" ] [ text m ]

            InfoMessage ->
                div [ class "message message--info" ] [ text m ]

            SuccessMessage ->
                div [ class "message message--success" ] [ text m ]


pacientForm : Model -> Html Msg
pacientForm model =
    if model.showForm then
        div [ class "paciente-info" ]
            [ div []
                [ input
                    [ type_ "button"
                    , class "submit-btn"
                    , value "SALVAR"
                    , onClick PostPaciente
                    , disabled (model.paciente == "")
                    ]
                    []
                ]
            , div [ class "form-block" ]
                [ label [ class "label" ] [ text "NOME: " ]
                , span [ class "span" ] [ text model.paciente ]
                ]
            , div [ class "form-block" ]
                [ label [ class "label" ] [ text "CONVÊNIO: " ]
                , span [ class "span" ] [ text model.convenio ]
                ]
            , div [ class "form-block" ]
                [ label [ class "label" ] [ text "PROTOCOLO: " ]
                , input
                    [ onClick (ChangeTipo 0)
                    , type_ "button"
                    , class (buttonClass model "nenhum" 0)
                    , value "NENHUM"
                    ]
                    []
                , input
                    [ onClick (ChangeTipo 1)
                    , type_ "button"
                    , class (buttonClass model "sepse" 1)
                    , value "SEPSE"
                    ]
                    []
                , input
                    [ onClick (ChangeTipo 2)
                    , type_ "button"
                    , class (buttonClass model "toracica" 2)
                    , value "DOR TORÁCICA"
                    ]
                    []
                , input
                    [ onClick (ChangeTipo 4)
                    , type_ "button"
                    , class (buttonClass model "renal" 4)
                    , value "CÓLICA RENAL"
                    ]
                    []
                , input
                    [ onClick (ChangeTipo 8)
                    , type_ "button"
                    , class (buttonClass model "avc" 8)
                    , value "AVC"
                    ]
                    []
                ]
              -- EXAMES
            , examesToHtml model
              -- FIM EXAMES
            , div []
                [ input
                    [ type_ "button"
                    , class "submit-btn"
                    , value "SALVAR"
                    , onClick PostPaciente
                    , disabled (model.paciente == "")
                    ]
                    []
                ]
            ]
    else
        text ""


exameToHtml : Exame -> Html Msg
exameToHtml exame =
    let
        ( checkClass, itemClass ) =
            if exame.realizado then
                ( "check-item check-item--active", "exames-item exames-item--realizado" )
            else
                ( "check-item", "exames-item" )
    in
        div [ class itemClass, onClick (ToggleExame exame.id) ]
            [ div [ class checkClass ] []
            , text exame.descricao
            ]


examesToHtml : Model -> Html Msg
examesToHtml model =
    if (List.length model.exames) == 0 then
        text ""
    else
        div [ class "form-block" ]
            [ label [ class "label" ] [ text "EXAMES (MARQUE OS REALIZADOS): " ]
            , div [ class "exames" ] <|
                List.map exameToHtml model.exames
            ]


view : Model -> Html Msg
view model =
    let
        messages =
            case model.messages of
                Nothing ->
                    text ""

                Just msgs ->
                    div [ class "messages" ] (List.map printMessage msgs)
    in
        div []
            [ div [ class "input-block" ]
                [ div [ class "label" ] [ text "ATENDIMENTO" ]
                , input [ class "input", onInput ChangeAtendimento, readonly model.loading, value model.atendimento ] []
                ]
            , messages
            , pacientForm model
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.search then
        Sub.batch [ Time.every (10 * Time.millisecond) SearchAtendimento ]
    else
        Sub.none
