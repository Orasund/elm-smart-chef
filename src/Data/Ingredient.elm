module Data.Ingredient exposing (Ingredient, new)

import Data.Property as Property exposing (Property)
import Dict exposing (Dict)
import Set exposing (Set)


type alias Ingredient =
    { name : String
    , properties : Set String
    }


new : String -> List Property -> Ingredient
new name properties =
    { name = name
    , properties = properties |> List.map .name |> Set.fromList
    }
