module Gen.Model exposing (Model(..))

import Gen.Params.Home_
import Gen.Params.Ingredients
import Gen.Params.NotFound
import Gen.Params.Ingredients.Name_
import Pages.Home_
import Pages.Ingredients
import Pages.NotFound
import Pages.Ingredients.Name_


type Model
    = Redirecting_
    | Home_ Gen.Params.Home_.Params Pages.Home_.Model
    | Ingredients Gen.Params.Ingredients.Params Pages.Ingredients.Model
    | NotFound Gen.Params.NotFound.Params
    | Ingredients__Name_ Gen.Params.Ingredients.Name_.Params Pages.Ingredients.Name_.Model

