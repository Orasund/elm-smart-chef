module Evergreen.V1.Bridge exposing (..)

import Evergreen.V1.Data.Ingredient


type ToBackend
    = StartCooking
    | Include Evergreen.V1.Data.Ingredient.Ingredient
    | Exclude Evergreen.V1.Data.Ingredient.Ingredient
