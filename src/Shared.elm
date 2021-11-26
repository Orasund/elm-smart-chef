module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Data.Dish as Meal exposing (Dish)
import Element exposing (..)
import Element.Region as Region
import Request exposing (Request)
import View exposing (View)



-- INIT


type alias Flags =
    ()


type alias Model =
    { meal : Maybe Dish }


init : Request -> Flags -> ( Model, Cmd Msg )
init _ json =
    ( { meal = Nothing }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Noop


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        Noop ->
            ( model
            , Cmd.none
            )


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none



-- VIEW


view :
    Request
    -> { page : View msg, toMsg : Msg -> msg }
    -> Model
    -> View msg
view req { page, toMsg } model =
    { title =
        page.title
    , body =
        column [ Region.mainContent, width fill ] [ page.body ]
    }
