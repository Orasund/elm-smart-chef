module Evergreen.V2.Gen.Msg exposing (..)

import Evergreen.V2.Pages.Home_
import Evergreen.V2.Pages.Ingredients
import Evergreen.V2.Pages.Ingredients.Name_


type Msg
    = Home_ Evergreen.V2.Pages.Home_.Msg
    | Ingredients Evergreen.V2.Pages.Ingredients.Msg
    | Ingredients__Name_ Evergreen.V2.Pages.Ingredients.Name_.Msg
