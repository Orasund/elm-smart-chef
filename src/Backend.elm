module Backend exposing (..)

import Bridge exposing (ToBackend(..))
import Data.Chef as Chef
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
    ( { dish =
            { base = "Reis"
            , ingredients = []
            }
      , chef =
            { startWith = Nothing
            , include = []
            , exclude = []
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


suggestIngredient : Generator (Maybe Ingredient) -> ClientId -> Model -> ( Model, Cmd BackendMsg )
suggestIngredient randIngredient clientId model =
    let
        ( maybeIngredient, seed ) =
            Random.step randIngredient model.seed
    in
    ( { model
        | seed = seed
      }
    , case maybeIngredient of
        Just ingredient ->
            NewDish
                model.dish
                ingredient
                |> Lamdera.sendToFrontend clientId

        Nothing ->
            NoDishFound
                |> Lamdera.sendToFrontend clientId
    )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        Include ingredient ->
            let
                dish =
                    model.dish

                ingredients =
                    ingredient :: dish.ingredients

                avaiableIngredients =
                    model.avaiableIngredients
                        |> Set.remove ingredient.name
            in
            { model
                | dish = { dish | ingredients = ingredients }
                , avaiableIngredients = avaiableIngredients
            }
                |> suggestIngredient
                    (avaiableIngredients
                        |> Chef.chooseIngredient model.chef
                    )
                    clientId

        Exclude ingredient ->
            let
                avaiableIngredients =
                    model.avaiableIngredients
                        |> Set.remove ingredient.name
            in
            { model | avaiableIngredients = avaiableIngredients }
                |> suggestIngredient
                    (avaiableIngredients
                        |> Chef.chooseIngredient model.chef
                    )
                    clientId

        StartCooking ->
            let
                dish =
                    { base = "Reis"
                    , ingredients = []
                    }
            in
            case Chef.list of
                head :: tail ->
                    model.seed
                        |> Random.step
                            (tail
                                |> Random.uniform head
                                |> Random.map
                                    (\chef -> { model | chef = chef, dish = dish })
                            )
                        |> (\( m, seed ) ->
                                { m
                                    | seed = seed
                                    , avaiableIngredients = Ingredient.set |> AnySet.toSet
                                }
                                    |> suggestIngredient
                                        (Ingredient.set
                                            |> Chef.chooseFirstIngredient m.chef
                                        )
                                        clientId
                           )

                [] ->
                    ( model
                    , NoDishFound
                        |> Lamdera.sendToFrontend clientId
                    )
