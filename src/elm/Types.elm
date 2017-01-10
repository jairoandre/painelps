module Types exposing (..)

import Http
import Time


type alias Model =
    { pacientes : List PacientePS
    , pages : Int
    , page : Int
    , error : Maybe Http.Error
    , loading : Bool
    , counter : Int
    }


type alias PacientePS =
    { exames : List String
    , atendimento : Int
    , nome : String
    , convenio : String
    , especialidade : String
    , classificacao : String
    , etapa : Int
    , tempo : Int
    , alergias : String
    , prescricao : Bool
    , observacao : String
    }


type Msg
    = ReceivePacientes (Result Http.Error (List PacientePS))
    | TickTime Time.Time
    | UpdatePage Time.Time
    | UpdateCounter Time.Time
    | RefreshPacientes Time.Time
    | ReceiveExames Int (Result Http.Error (List String))
