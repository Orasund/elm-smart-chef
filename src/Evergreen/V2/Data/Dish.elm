module Evergreen.V2.Data.Dish exposing (..)

import Evergreen.V2.Data.Ingredient


type alias Dish =
    { base : String
    , ingredients : List Evergreen.V2.Data.Ingredient.Ingredient
    }
