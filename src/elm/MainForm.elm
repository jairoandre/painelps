module MainForm exposing (main)

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


type alias Model =
    { atendimento : String
    , tipo : String
    , paciente : String
    , search : Bool
    , timer : Int
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
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" "" "" False 0, Cmd.none )


maybeString : JD.Decoder String
maybeString =
    JD.oneOf [ JD.null "", JD.string ]


decodePaciente : JD.Decoder Paciente
decodePaciente =
    JD.map2 Paciente
        (JD.field "nome" maybeString)
        (JD.field "convenio" maybeString)


fetchPaciente : String -> Cmd Msg
fetchPaciente atendimento =
    Http.send ReceivePaciente (Http.get ("http://10.1.8.118:8080/painelps/rest/api/atendimento/" ++ atendimento) decodePaciente)


defaultInt : String -> Int
defaultInt str =
    Result.withDefault -1 (String.toInt str)


encodePaciente : Model -> JE.Value
encodePaciente model =
    JE.object
        [ ( "atendimento", JE.int <| defaultInt model.atendimento )
        , ( "tipo", JE.int <| defaultInt model.tipo )
        ]


postPaciente : Model -> Cmd Msg
postPaciente model =
    Http.send SavePaciente (Http.post "http://10.1.8.118:8080/painelps/rest/api/protocolo" (Http.jsonBody (encodePaciente model)) JD.string)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ChangeValue fieldToChange newValue ->
            case fieldToChange of
                Atendimento ->
                    ( { model | atendimento = (String.filter Char.isDigit newValue), search = True, timer = 600 }, Cmd.none )

                Tipo ->
                    ( { model | tipo = newValue }, Cmd.none )

        SearchAtendimento newTime ->
            if model.timer > 0 then
                ( { model | timer = model.timer - 10 }, Cmd.none )
            else if model.search then
                ( { model | timer = 0, search = False }, fetchPaciente model.atendimento )
            else
                ( { model | timer = 0 }, Cmd.none )

        ReceivePaciente (Err e) ->
            ( { model | paciente = "" }, Cmd.none )

        ReceivePaciente (Ok atendimento) ->
            ( { model | paciente = atendimento.nome }, Cmd.none )

        SavePaciente (Err e) ->
            ( { model | paciente = toString e }, Cmd.none )

        SavePaciente (Ok str) ->
            ( model, Cmd.none )

        PostPaciente ->
            ( model, postPaciente model )


buttonClass : Model -> String -> String -> String
buttonClass model tipoClass tipo =
    if model.tipo == tipo then
        "protocolo protocolo--" ++ tipoClass
    else
        "protocolo"


view : Model -> Html Msg
view model =
    div []
        [ div [ class "input-block" ]
            [ div [ class "label" ] [ text "ATENDIMENTO" ]
            , input [ class "input", onInput (ChangeValue Atendimento), value model.atendimento ] []
            , span [ class "span" ] [ text model.paciente ]
            ]
        , div [ class "input-block" ]
            [ div [ class "label", style [ ( "margin-bottom", "15px" ) ] ] [ text "PROTOCOLO" ]
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
        , div [ class "input-block" ]
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


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.search then
        Sub.batch [ Time.every (10 * Time.millisecond) SearchAtendimento ]
    else
        Sub.none
