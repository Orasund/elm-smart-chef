module Gen.Model exposing (Model(..))

import Gen.Params.Home_
import Gen.Params.Ingredients
import Gen.Params.NotFound
import Pages.Home_
import Pages.Ingredients
import Pages.NotFound


type Model
    = Redirecting_
    | Home_ Gen.Params.Home_.Params Pages.Home_.Model
    | Ingredients Gen.Params.Ingredients.Params Pages.Ingredients.Model
    | NotFound Gen.Params.NotFound.Params

