module Protocolo exposing (..)

import Html exposing (Html, div, text, input, label, span)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as JD
import Json.Encode as JE
import Char
import Time
import Http


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
    , tipo : String
    , paciente : String
    , search : Bool
    , timer : Int
    , messages : Maybe (List ( MessageType, String ))
    , showForm : Bool
    , convenio : String
    , exames : List String
    }


type Msg
    = ChangeValue Field String
    | SearchAtendimento Time.Time
    | ReceivePaciente (Result Http.Error Paciente)
    | SavePaciente (Result Http.Error String)
    | PostPaciente


type Field
    = Atendimento
    | Tipo


type alias Paciente =
    { nome : String
    , convenio : String
    , tipo : Maybe Int
    , exames : List String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" "" "" False 0 Nothing False "" [], Cmd.none )


maybeString : JD.Decoder String
maybeString =
    JD.oneOf [ JD.null "", JD.string ]


decodePaciente : JD.Decoder Paciente
decodePaciente =
    JD.map4 Paciente
        (JD.field "nome" maybeString)
        (JD.field "convenio" maybeString)
        (JD.field "tipo" (JD.maybe JD.int))
        (JD.field "exames" (JD.list JD.string))


urlPrefix : String
urlPrefix =
    if False then
        "http://10.1.8.118:8080/painelps/rest/api/"
    else
        "rest/api/"


fetchPaciente : String -> Cmd Msg
fetchPaciente atendimento =
    Http.send ReceivePaciente (Http.get (urlPrefix ++ "atendimento/" ++ atendimento) decodePaciente)


defaultInt : String -> Int
defaultInt str =
    Result.withDefault -1 (String.toInt str)


encodePaciente : Model -> JE.Value
encodePaciente model =
    JE.object
        [ ( "atendimento", JE.int <| defaultInt model.atendimento )
        , ( "tipo", JE.int <| defaultInt model.tipo )
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
        ChangeValue fieldToChange newValue ->
            case fieldToChange of
                Atendimento ->
                    ( { model
                        | atendimento = (String.filter Char.isDigit newValue)
                        , search = True
                        , showForm = False
                        , timer = 300
                        , messages = Nothing
                        , tipo = ""
                        , exames = []
                      }
                    , Cmd.none
                    )

                Tipo ->
                    ( { model | tipo = newValue, messages = Just [ ( InfoMessage, "Existem mudanças não salvas" ) ] }, Cmd.none )

        SearchAtendimento newTime ->
            if model.timer > 0 then
                ( { model | timer = model.timer - 10 }, Cmd.none )
            else if model.search then
                ( { model | timer = 0, search = False }, fetchPaciente model.atendimento )
            else
                ( { model | timer = 0 }, Cmd.none )

        ReceivePaciente (Err e) ->
            ( { model
                | messages =
                    Just
                        [ ( ErrorMessage, formartErrorMessage e )
                        , ( ErrorMessage, "Paciente não encontrado" )
                        ]
              }
            , Cmd.none
            )

        ReceivePaciente (Ok paciente) ->
            ( { model
                | paciente = paciente.nome
                , convenio = paciente.convenio
                , exames = paciente.exames
                , tipo =
                    case paciente.tipo of
                        Nothing ->
                            ""

                        Just v ->
                            toString v
                , showForm = True
              }
            , Cmd.none
            )

        SavePaciente (Err e) ->
            ( { model | messages = Just [ ( ErrorMessage, formartErrorMessage e ) ] }, Cmd.none )

        SavePaciente (Ok str) ->
            ( { model | messages = Just [ ( SuccessMessage, "Alterações registradas." ) ] }, Cmd.none )

        PostPaciente ->
            ( model, postPaciente model )


buttonClass : Model -> String -> String -> String
buttonClass model tipoClass tipo =
    if model.tipo == tipo then
        "protocolo protocolo--" ++ tipoClass
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
            [ div [ class "form-block" ]
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
                    [ onClick (ChangeValue Tipo "")
                    , type_ "button"
                    , class (buttonClass model "nenhum" "")
                    , value "NENHUM"
                    ]
                    []
                , input
                    [ onClick (ChangeValue Tipo "0")
                    , type_ "button"
                    , class (buttonClass model "sepse" "0")
                    , value "SEPSE"
                    ]
                    []
                , input
                    [ onClick (ChangeValue Tipo "1")
                    , type_ "button"
                    , class (buttonClass model "toraxica" "1")
                    , value "DOR TORÁXICA"
                    ]
                    []
                , input
                    [ onClick (ChangeValue Tipo "2")
                    , type_ "button"
                    , class (buttonClass model "renal" "2")
                    , value "CÓLICA RENAL"
                    ]
                    []
                , input
                    [ onClick (ChangeValue Tipo "3")
                    , type_ "button"
                    , class (buttonClass model "avc" "3")
                    , value "AVC"
                    ]
                    []
                ]
              -- EXAMES
            , div [ class "form-block" ]
                [ label [ class "label" ] [ text "EXAMES: " ]
                , div [] <| List.map (\s -> div [] [ text s ]) model.exames
                ]
              -- FIM EXAMES
            , div []
                [ input
                    [ type_ "button"
                    , class "submit-btn"
                    , value "Enviar"
                    , onClick PostPaciente
                    , disabled (model.paciente == "")
                    ]
                    []
                ]
            ]
    else
        text ""


view : Model -> Html Msg
view model =
    let
        messages =
            case model.messages of
                Nothing ->
                    text ""

                Just msgs ->
                    div [] (List.map printMessage msgs)
    in
        div []
            [ div [ class "input-block" ]
                [ div [ class "label" ] [ text "ATENDIMENTO" ]
                , input [ class "input", onInput (ChangeValue Atendimento), value model.atendimento ] []
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
