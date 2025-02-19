module Types exposing (..)

import Bridge as ToBackend exposing (ToBackend(..))
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Data.Chef exposing (Chef)
import Data.Dish as Meal exposing (Dish)
import Data.Ingredient exposing (Ingredient)
import Dict exposing (Dict)
import Gen.Model exposing (Model(..))
import Gen.Pages as Pages
import Random exposing (Seed)
import Set exposing (Set)
import Set.Any as AnySet exposing (AnySet)
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
    { chef : Chef
    , avaiableIngredients : Dict String Ingredient
    , seed : Seed
    }


type BackendMsg
    = NewSeed Seed


type ToFrontend
    = NewChef Chef (Dict String Ingredient)
    | GotIngredientList (Dict String Ingredient)
    | NoDishFound


type alias ToBackend =
    ToBackend.ToBackend
