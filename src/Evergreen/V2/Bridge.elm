module Evergreen.V2.Bridge exposing (..)

import Evergreen.V2.Data.Ingredient


type ToBackend
    = StartCooking (Maybe String)
    | SyncIngredients
    | RemoveIngredient String
    | UpdateIngredient String Evergreen.V2.Data.Ingredient.Ingredient
