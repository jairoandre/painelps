module Main exposing (..)

import Html exposing (Html)
import Types exposing (..)
import View exposing (..)
import Rest exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


init : ( Model, Cmd Msg )
init =
    ( Model [] Nothing, fetchPacientes )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ReceivePacientes (Ok pacientes) ->
            ( { model | pacientes = pacientes, error = Nothing }, Cmd.none )

        ReceivePacientes (Err e) ->
            ( { model | error = Just e }, Cmd.none )
