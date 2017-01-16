module Main exposing (..)

import Html exposing (Html)
import Types exposing (..)
import View exposing (..)
import Rest exposing (..)
import Task
import Time
import Window


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( initModel, initialSize )


tickTime : List PacientePS -> List PacientePS
tickTime pacientes =
    List.map (\p -> { p | tempo = p.tempo + 1 }) pacientes


updateExamesPaciente : Int -> List String -> PacientePS -> PacientePS
updateExamesPaciente cdAtend exames paciente =
    if cdAtend == paciente.atendimento then
        { paciente | exames = exames }
    else
        paciente


initialSize : Cmd Msg
initialSize =
    Task.perform InitialSize Window.size


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        InitialSize newSize ->
            let
                scale =
                    (toFloat newSize.width) / 1920.0
            in
                ( { model | scale = scale }, fetchPacientes )

        ReceivePacientes (Ok pacientes) ->
            let
                len =
                    List.length pacientes

                pages =
                    if (len % patientsPerPage) == 0 then
                        len // patientsPerPage
                    else
                        (len // patientsPerPage) + 1
            in
                ( { model
                    | pacientes = pacientes
                    , pages = pages
                    , page = 0
                    , counter = 0
                    , error = Nothing
                    , loading = False
                  }
                , fetchExamesPacientes pacientes
                )

        ReceivePacientes (Err e) ->
            ( { model | error = Just e, loading = False }, Cmd.none )

        ReceiveExames atendimento (Ok exames) ->
            let
                pacientes =
                    List.map (updateExamesPaciente atendimento exames) model.pacientes
            in
                ( { model | pacientes = pacientes }, Cmd.none )

        ReceiveExames atendimento (Err e) ->
            ( model, Cmd.none )

        TickTime newTime ->
            ( { model | pacientes = tickTime model.pacientes }, Cmd.none )

        UpdatePage newTime ->
            ( { model | page = ((model.page + 1) % model.pages) }, Cmd.none )

        UpdateCounter newTime ->
            ( { model | counter = model.counter + 1 }, Cmd.none )

        RefreshPacientes newTime ->
            ( { model | loading = True }, fetchPacientes )


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.loading then
        Sub.none
    else
        Sub.batch
            [ Time.every Time.minute TickTime
            , Time.every Time.second UpdateCounter
            , Time.every (2 * Time.minute) RefreshPacientes
            , Time.every (10 * Time.second) UpdatePage
            ]
