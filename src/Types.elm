module Types exposing (..)

import Bridge as ToBackend exposing (ToBackend(..))
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Data.Dish as Meal exposing (Dish)
import Gen.Pages as Pages
import Random exposing (Seed)
import Shared exposing (Flags)
import Url exposing (Url)


type alias FrontendModel =
    { url : Url
    , key : Key
    , shared : Shared.Model
    , page : Pages.Model
    }


type FrontendMsg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | Shared Shared.Msg
    | Page Pages.Msg
    | Noop


type alias BackendModel =
    { meal : Dish
    , seed : Seed
    }


type BackendMsg
    = NewSeed Seed


type ToFrontend
    = NewMeal Dish
    | NoOpToFrontend


type alias ToBackend =
    ToBackend.ToBackend
