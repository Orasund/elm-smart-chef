module Backend exposing (..)

import Bridge exposing (ToBackend(..))
import Config
import Data.Base as Base
import Data.Chef as Chef
import Data.Dish as Dish
import Data.Ingredient as Ingredient exposing (Ingredient)
import Dict
import Gen.Msg
import Html exposing (a)
import Lamdera exposing (ClientId, SessionId)
import Pages.Home_
import Random exposing (Generator)
import Random.List
import Set
import Set.Any as AnySet
import Task
import Types exposing (BackendModel, BackendMsg(..), ToFrontend(..))


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { chef =
            { startWith = Nothing
            , include = []
            , exclude = []
            , bases = ( Base.rice, [] )
            }
      , seed = Random.initialSeed 42
      , avaiableIngredients = Ingredient.set |> AnySet.toSet
      }
    , Random.independentSeed |> Random.generate NewSeed
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NewSeed seed ->
            ( { model | seed = seed }, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        StartCooking ->
            case Chef.list of
                head :: tail ->
                    let
                        ( chef, seed ) =
                            model.seed
                                |> Random.step
                                    (tail
                                        |> Random.uniform head
                                    )
                    in
                    ( { model | seed = seed }
                    , NewChef chef (Ingredient.set |> AnySet.toSet)
                        |> Lamdera.sendToFrontend clientId
                    )

                [] ->
                    ( model
                    , NoDishFound
                        |> Lamdera.sendToFrontend clientId
                    )
