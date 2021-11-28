module Gen.Msg exposing (Msg(..))

import Gen.Params.Home_
import Gen.Params.Ingredients
import Gen.Params.NotFound
import Gen.Params.Ingredients.Name_
import Pages.Home_
import Pages.Ingredients
import Pages.NotFound
import Pages.Ingredients.Name_


type Msg
    = Home_ Pages.Home_.Msg
    | Ingredients Pages.Ingredients.Msg
    | Ingredients__Name_ Pages.Ingredients.Name_.Msg

