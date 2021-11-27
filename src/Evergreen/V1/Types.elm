module Evergreen.V1.Types exposing (..)

import Browser
import Browser.Navigation
import Evergreen.V1.Bridge
import Evergreen.V1.Data.Chef
import Evergreen.V1.Data.Dish
import Evergreen.V1.Data.Ingredient
import Evergreen.V1.Gen.Pages
import Evergreen.V1.Shared
import Random
import Set
import Url


type alias FrontendModel =
    { url : Url.Url
    , key : Browser.Navigation.Key
    , shared : Evergreen.V1.Shared.Model
    , page : Evergreen.V1.Gen.Pages.Model
    }


type alias BackendModel =
    { dish : Evergreen.V1.Data.Dish.Dish
    , chef : Evergreen.V1.Data.Chef.Chef
    , avaiableIngredients : Set.Set String
    , seed : Random.Seed
    }


type FrontendMsg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | Shared Evergreen.V1.Shared.Msg
    | Page Evergreen.V1.Gen.Pages.Msg
    | Noop


type alias ToBackend =
    Evergreen.V1.Bridge.ToBackend


type BackendMsg
    = NewSeed Random.Seed


type ToFrontend
    = NewDish Evergreen.V1.Data.Dish.Dish Evergreen.V1.Data.Ingredient.Ingredient
    | FinishedDish Evergreen.V1.Data.Dish.Dish
    | NoDishFound
