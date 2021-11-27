module Data.Cooking exposing (..)

import Config
import Data.Base exposing (Base)
import Data.Chef as Chef exposing (Chef)
import Data.Dish exposing (Dish)
import Data.Ingredient exposing (Ingredient)
import Dict exposing (Dict)
import Random exposing (Generator)
import Set exposing (Set)


type alias CookingState =
    { base : Base
    , ingredients : List Ingredient
    , chef : Chef
    , avaiableIngredients : Dict String Ingredient
    }


type Cooking
    = Done Dish
    | Prepairing CookingState


toDish : CookingState -> Dish
toDish state =
    { base = state.base.name
    , ingredients = state.ingredients
    }


start : Dict String Ingredient -> Chef -> Generator CookingState
start avaiableIngredients chef =
    let
        ( b1, b2 ) =
            chef.bases
    in
    Random.uniform b1 b2
        |> Random.map
            (\base ->
                { base = base
                , ingredients = []
                , chef = chef
                , avaiableIngredients = avaiableIngredients
                }
            )


chooseIngredient : CookingState -> Generator (Maybe Ingredient)
chooseIngredient state =
    state.avaiableIngredients
        |> (if state.ingredients |> List.isEmpty then
                Chef.chooseFirstIngredient state.chef

            else
                Chef.chooseIngredient state.chef
           )


includeIngredient : Ingredient -> CookingState -> CookingState
includeIngredient ingredient state =
    let
        ingredients =
            ingredient :: state.ingredients

        avaiableIngredients =
            state.avaiableIngredients
                |> Dict.remove ingredient.name

        newModel =
            { state
                | ingredients = ingredients
                , avaiableIngredients = avaiableIngredients
            }
    in
    { state
        | ingredients = ingredients
        , avaiableIngredients = avaiableIngredients
    }


excludeIngredient : Ingredient -> CookingState -> CookingState
excludeIngredient ingredient state =
    let
        avaiableIngredients =
            state.avaiableIngredients
                |> Dict.remove ingredient.name
    in
    { state | avaiableIngredients = avaiableIngredients }
