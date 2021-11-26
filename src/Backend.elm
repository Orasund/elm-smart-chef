module Backend exposing (..)

import Bridge exposing (ToBackend(..))
import Data.Chef as Chef
import Data.Ingredient as Ingredients exposing (Ingredient)
import Dict
import Gen.Msg
import Lamdera exposing (ClientId, SessionId)
import Pages.Home_
import Random
import Random.List
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
    ( { meal =
            { base = "Reis"
            , ingredients = []
            }
      , seed = Random.initialSeed 42
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
            let
                ( ingredients, seed ) =
                    case Chef.list of
                        head :: tail ->
                            Random.step
                                (tail
                                    |> Random.uniform head
                                    |> Random.andThen Chef.cook
                                )
                                model.seed

                        _ ->
                            ( [], model.seed )
            in
            ( { model | seed = seed }
            , { base = "Reis"
              , ingredients = ingredients
              }
                |> NewMeal
                |> Lamdera.sendToFrontend clientId
            )
