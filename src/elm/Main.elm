module Main exposing (..)

import Html exposing (Html)
import Types exposing (..)
import View exposing (..)
import Rest exposing (..)
import Time


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
    ( Model [] 0 0 Nothing, fetchPacientes )


tickTime : List PacientePS -> List PacientePS
tickTime pacientes =
    List.map (\p -> { p | tempo = p.tempo + 1 }) pacientes


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ReceivePacientes (Ok pacientes) ->
            let
                len =
                    List.length pacientes

                pages =
                    if (len % 10) == 0 then
                        len // 10
                    else
                        (len // 10) + 1
            in
                ( { model | pacientes = pacientes, pages = pages, page = 0, error = Nothing }, Cmd.none )

        ReceivePacientes (Err e) ->
            ( { model | error = Just e }, Cmd.none )

        TickTime newTime ->
            ( { model | pacientes = tickTime model.pacientes }, Cmd.none )

        UpdatePage newTime ->
            ( { model | page = ((model.page + 1) % model.pages) }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every Time.minute TickTime
        , Time.every (10 * Time.second) UpdatePage
        ]
