module Rest exposing (..)

import Http
import Json.Decode as JD
import Json.Decode.Pipeline as JDP
import Types exposing (..)


fetchPacientes : Cmd Msg
fetchPacientes =
    Http.send ReceivePacientes (Http.get "http://localhost:8080/painelps/rest/api/painel" decodePacientes)


decodePacientes : JD.Decoder (List PacientePS)
decodePacientes =
    JD.list decodePaciente


maybeString : JD.Decoder String
maybeString =
    JD.oneOf [ JD.null "", JD.string ]


decodePaciente : JD.Decoder PacientePS
decodePaciente =
    JDP.decode PacientePS
        |> JDP.required "atendimento" JD.int
        |> JDP.required "risco" maybeString
        |> JDP.required "nome" maybeString
        |> JDP.required "convenio" maybeString
        |> JDP.required "observacao" maybeString
        |> JDP.required "etapa" maybeString
        |> JDP.required "tempo" JD.int
