module Gen.Msg exposing (Msg(..))

import Gen.Params.Home_
import Gen.Params.Ingredients
import Gen.Params.NotFound
import Pages.Home_
import Pages.Ingredients
import Pages.NotFound


type Msg
    = Home_ Pages.Home_.Msg
    | Ingredients Pages.Ingredients.Msg

