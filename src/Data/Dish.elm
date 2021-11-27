module Data.Dish exposing (Dish)

import Data.Base as Base exposing (Base)
import Data.Ingredient exposing (Ingredient)


type alias Dish =
    { base : String
    , ingredients : List Ingredient
    }
