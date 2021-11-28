module Evergreen.V2.Pages.Ingredients exposing (..)

import Evergreen.V2.Bridge
import Evergreen.V2.Gen.Route
import Evergreen.V2.Shared


type alias Model =
    ()


type Msg
    = ToBackend Evergreen.V2.Bridge.ToBackend
    | ToShared Evergreen.V2.Shared.Msg
    | Navigate Evergreen.V2.Gen.Route.Route
