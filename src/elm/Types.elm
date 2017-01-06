module Types exposing (..)

import Http
import Time


type alias Model =
    { pacientes : List PacientePS
    , pages : Int
    , page : Int
    , error : Maybe Http.Error
    }


type alias PacientePS =
    { atendimento : Int
    , risco : Int
    , nome : String
    , convenio : String
    , observacao : String
    , etapa : Int
    , tempo : Int
    }


type Msg
    = ReceivePacientes (Result Http.Error (List PacientePS))
    | TickTime Time.Time
    | UpdatePage Time.Time
