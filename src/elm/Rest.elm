module Rest exposing (..)

import Http
import Json.Decode as JD
import Json.Decode.Pipeline as JDP
import Types exposing (..)


urlPrefix : String
urlPrefix =
    if False then
        "http://10.1.8.118:8080/painelps/rest/api/"
    else
        "rest/api/"


fetchPacientes : Model -> Cmd Msg
fetchPacientes model =
    if (String.contains "pediatria" model.location.hash) then
        Http.send ReceivePacientes (Http.get (urlPrefix ++ "pediatria") decodePacientes)
    else
        Http.send ReceivePacientes (Http.get (urlPrefix ++ "painel") decodePacientes)


fetchExamesPacientes : List PacientePS -> Cmd Msg
fetchExamesPacientes pacientes =
    Cmd.batch <| List.map (\p -> fetchExames p) pacientes


fetchExames : PacientePS -> Cmd Msg
fetchExames paciente =
    Http.send (ReceiveExames paciente.atendimento)
        (Http.get (urlPrefix ++ "exames/" ++ (toString paciente.atendimento)) (JD.list JD.string))


decodePacientes : JD.Decoder (List PacientePS)
decodePacientes =
    JD.list decodePaciente


maybeString : JD.Decoder String
maybeString =
    JD.oneOf [ JD.null "", JD.string ]


maybeInt : JD.Decoder Int
maybeInt =
    JD.oneOf [ JD.null -1, JD.int ]


decodePaciente : JD.Decoder PacientePS
decodePaciente =
    JDP.decode (PacientePS [])
        |> JDP.required "atendimento" JD.int
        |> JDP.required "nome" maybeString
        |> JDP.required "convenio" maybeString
        |> JDP.required "especialidade" maybeString
        |> JDP.required "classificacao" maybeString
        |> JDP.required "etapa" JD.int
        |> JDP.required "tempo" JD.int
        |> JDP.required "alergias" maybeString
        |> JDP.required "prescricao" JD.bool
        |> JDP.required "observacao" maybeString
        |> JDP.required "internacao" JD.bool
        |> JDP.required "sepse" JD.bool
        |> JDP.required "protocolo" (JD.oneOf [ JD.null 0, JD.int ])
