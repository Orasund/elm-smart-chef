module Evergreen.V2.Data.Cooking exposing (..)

import Dict
import Evergreen.V2.Data.Base
import Evergreen.V2.Data.Chef
import Evergreen.V2.Data.Dish
import Evergreen.V2.Data.Ingredient


type alias CookingState =
    { base : Evergreen.V2.Data.Base.Base
    , ingredients : List Evergreen.V2.Data.Ingredient.Ingredient
    , chef : Evergreen.V2.Data.Chef.Chef
    , avaiableIngredients : Dict.Dict String Evergreen.V2.Data.Ingredient.Ingredient
    }


type Cooking
    = Done Evergreen.V2.Data.Dish.Dish
    | Prepairing CookingState
