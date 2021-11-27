module Bridge exposing (ToBackend(..), sendToBackend)

import Data.Ingredient exposing (Ingredient)
import Lamdera


sendToBackend =
    Lamdera.sendToBackend


type ToBackend
    = StartCooking
    | Include Ingredient
    | ChooseIngredient
