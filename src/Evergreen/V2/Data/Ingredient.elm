module Evergreen.V2.Data.Ingredient exposing (..)

import Set


type alias Ingredient =
    { name : String
    , properties : Set.Set String
    }
