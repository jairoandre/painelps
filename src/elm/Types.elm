module Types exposing (..)

import Http


type alias Model =
    { pacientes : List PacientePS
    , error : Maybe Http.Error
    }


type alias PacientePS =
    { atendimento : Int
    , risco : String
    , nome : String
    , convenio : String
    , observacao : String
    , etapa : String
    , tempo : Int
    }


type Msg
    = ReceivePacientes (Result Http.Error (List PacientePS))
