module Evergreen.V2.Shared exposing (..)

import Dict
import Evergreen.V2.Data.Cooking
import Evergreen.V2.Data.Ingredient
import Random


type alias Model =
    { ingredient : Maybe Evergreen.V2.Data.Ingredient.Ingredient
    , ingredientList : Dict.Dict String Evergreen.V2.Data.Ingredient.Ingredient
    , cooking : Maybe Evergreen.V2.Data.Cooking.Cooking
    , seed : Random.Seed
    }


type Msg
    = StartWith Evergreen.V2.Data.Ingredient.Ingredient
    | IncludeIngredient
    | ExcludeIngredient
