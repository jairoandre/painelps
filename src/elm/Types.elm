module Types exposing (..)

import Http
import Time
import Window
import Navigation


type alias Model =
    { pacientes : List PacientePS
    , pages : Int
    , page : Int
    , error : Maybe Http.Error
    , loading : Bool
    , counter : Int
    , scale : Float
    , location : Navigation.Location
    }


devUrl : String
devUrl =
    "http://10.1.8.118:8080/painelps/rest/api/"


initModel : Navigation.Location -> Model
initModel location =
    Model [] 1 0 Nothing True 0 0.65 location


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
    , internacao : Bool
    , sepse : Bool
    , protocolo : Int
    }


type Msg
    = ReceivePacientes (Result Http.Error (List PacientePS))
    | InitialSize Window.Size
    | TickTime Time.Time
    | UpdatePage Time.Time
    | UpdateCounter Time.Time
    | RefreshPacientes Time.Time
    | ReceiveExames Int (Result Http.Error (List String))
    | UrlChange Navigation.Location
