module Evergreen.V1.Shared exposing (..)

import Evergreen.V1.Data.Dish
import Evergreen.V1.Data.Ingredient


type alias Model =
    { meal : Maybe Evergreen.V1.Data.Dish.Dish
    , ingredient : Maybe Evergreen.V1.Data.Ingredient.Ingredient
    }


type Msg
    = Noop
