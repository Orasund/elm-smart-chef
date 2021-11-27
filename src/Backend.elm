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
    ( { dish = Dish.fromBase Base.rice
      , chef =
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

                newDish =
                    { dish | ingredients = ingredients }

                newModel =
                    { model
                        | dish = newDish
                        , avaiableIngredients = avaiableIngredients
                    }
            in
            if ingredients |> List.length |> (==) Config.maxIngredients then
                ( newModel
                , newDish
                    |> FinishedDish
                    |> Lamdera.sendToFrontend clientId
                )

            else
                suggestIngredient
                    (avaiableIngredients
                        |> Chef.chooseIngredient model.chef
                    )
                    clientId
                    newModel

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
            case Chef.list of
                head :: tail ->
                    model.seed
                        |> Random.step
                            (tail
                                |> Random.uniform head
                                |> Random.andThen
                                    (\chef ->
                                        let
                                            ( b1, b2 ) =
                                                chef.bases
                                        in
                                        Random.uniform b1 b2
                                            |> Random.map
                                                (\base ->
                                                    { model
                                                        | chef = chef
                                                        , dish = Dish.fromBase base
                                                    }
                                                )
                                    )
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
