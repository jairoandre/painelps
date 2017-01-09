module Rest exposing (..)

import Http
import Json.Decode as JD
import Json.Decode.Pipeline as JDP
import Types exposing (..)


fetchPacientes : Cmd Msg
fetchPacientes =
    Http.send ReceivePacientes (Http.get "http://10.1.8.118:8080/painelps/rest/api/painel" decodePacientes)


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
        |> JDP.required "risco" JD.int
        |> JDP.required "nome" maybeString
        |> JDP.required "convenio" maybeString
        |> JDP.required "observacao" maybeString
        |> JDP.required "etapa" JD.int
        |> JDP.required "tempo" JD.int
        |> JDP.required "prescricao" JD.bool
