module Evergreen.V2.Pages.Home_ exposing (..)

import Evergreen.V2.Gen.Route


type alias Model =
    ()


type Msg
    = CreateMeal
    | UseIngredient Bool
    | Navigate Evergreen.V2.Gen.Route.Route
