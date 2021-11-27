module Evergreen.V1.Data.Dish exposing (..)

import Evergreen.V1.Data.Ingredient


type alias Dish =
    { base : String
    , ingredients : List Evergreen.V1.Data.Ingredient.Ingredient
    }
