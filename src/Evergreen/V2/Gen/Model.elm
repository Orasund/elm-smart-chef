module Evergreen.V2.Gen.Model exposing (..)

import Evergreen.V2.Gen.Params.Home_
import Evergreen.V2.Gen.Params.Ingredients
import Evergreen.V2.Gen.Params.Ingredients.Name_
import Evergreen.V2.Gen.Params.NotFound
import Evergreen.V2.Pages.Home_
import Evergreen.V2.Pages.Ingredients
import Evergreen.V2.Pages.Ingredients.Name_


type Model
    = Redirecting_
    | Home_ Evergreen.V2.Gen.Params.Home_.Params Evergreen.V2.Pages.Home_.Model
    | Ingredients Evergreen.V2.Gen.Params.Ingredients.Params Evergreen.V2.Pages.Ingredients.Model
    | NotFound Evergreen.V2.Gen.Params.NotFound.Params
    | Ingredients__Name_ Evergreen.V2.Gen.Params.Ingredients.Name_.Params Evergreen.V2.Pages.Ingredients.Name_.Model
