module Evergreen.V2.Pages.Ingredients.Name_ exposing (..)

import Evergreen.V2.Bridge
import Evergreen.V2.Data.Ingredient
import Evergreen.V2.Gen.Route


type alias Model =
    { ingredient : Evergreen.V2.Data.Ingredient.Ingredient
    }


type Msg
    = Toggle String
    | ToBackend Evergreen.V2.Bridge.ToBackend
    | Navigate Evergreen.V2.Gen.Route.Route
    | Rename String
    | Save
    | Remove
