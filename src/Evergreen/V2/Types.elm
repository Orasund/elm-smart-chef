module Evergreen.V2.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V2.Bridge
import Evergreen.V2.Data.Chef
import Evergreen.V2.Data.Ingredient
import Evergreen.V2.Gen.Pages
import Evergreen.V2.Shared
import Random
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V2.Shared.Model
    , page : Evergreen.V2.Gen.Pages.Model
    }


type alias BackendModel =
    { chef : Evergreen.V2.Data.Chef.Chef
    , avaiableIngredients : Dict.Dict String Evergreen.V2.Data.Ingredient.Ingredient
    , seed : Random.Seed
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V2.Shared.Msg
    | Page Evergreen.V2.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V2.Bridge.ToBackend


type BackendMsg
    = NewSeed Random.Seed


type ToFrontend
    = NewChef Evergreen.V2.Data.Chef.Chef (Dict.Dict String Evergreen.V2.Data.Ingredient.Ingredient)
    | GotIngredientList (Dict.Dict String Evergreen.V2.Data.Ingredient.Ingredient)
    | NoDishFound
