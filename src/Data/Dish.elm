module Data.Dish exposing (Dish, fromBase)

import Data.Base as Base exposing (Base)
import Data.Ingredient exposing (Ingredient)


type alias Dish =
    { base : String
    , ingredients : List Ingredient
    }


fromBase : Base -> Dish
fromBase base =
    { base = base.name
    , ingredients = []
    }
