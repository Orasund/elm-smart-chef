module Pages.Ingredients exposing (Model, Msg(..), page)

import Bridge exposing (..)
import Browser.Navigation as Nav
import Config
import Data.Cooking exposing (Cooking(..))
import Data.Dish exposing (Dish)
import Data.Ingredient as Ingredient exposing (Ingredient)
import Dict exposing (Dict)
import Effect exposing (Effect)
import Element exposing (Element)
import Element.Font as Font
import Element.Input as Input
import Gen.Route as Route exposing (Route(..))
import Lamdera
import Page
import Request exposing (Request)
import Shared exposing (Msg(..))
import View exposing (View)
import View.Navigation as Navigation
import Widget
import Widget.Customize as Customize
import Widget.Material as Material
import Widget.Material.Typography as Typography


page : Shared.Model -> Request -> Page.With Model Msg
page shared request =
    Page.advanced
        { init = init shared
        , update = update request shared
        , subscriptions = subscriptions
        , view = view request shared
        }



-- INIT


type alias Model =
    ()


init : Shared.Model -> ( Model, Effect Msg )
init shared =
    ( ()
    , Effect.none
    )



-- UPDATE


type Msg
    = ToBackend ToBackend
    | ToShared Shared.Msg
    | Navigate Route


update : Request -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update request shared msg model =
    case msg of
        Navigate route ->
            ( model
            , Route.toHref route |> Nav.pushUrl request.key |> Effect.fromCmd
            )

        ToShared sharedMsg ->
            ( model
            , sharedMsg
                |> Effect.fromShared
            )

        ToBackend toBackendMsg ->
            ( model
            , toBackendMsg
                |> sendToBackend
                |> Effect.fromCmd
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


viewList : (Element Msg -> Element Msg) -> Dict String Ingredient -> List (Element Msg)
viewList navigation dict =
    [ dict
        |> Dict.values
        |> List.map
            (\ingredient ->
                Widget.fullBleedItem (Material.fullBleedItem Config.palette)
                    { text = ingredient.name
                    , onPress =
                        { name = ingredient.name }
                            |> Route.Ingredients__Name_
                            |> Navigate
                            |> Just
                    , icon =
                        always
                            (Widget.textButton (Material.textButton Config.palette)
                                { text = "Start"
                                , onPress =
                                    ingredient
                                        |> StartWith
                                        |> ToShared
                                        |> Just
                                }
                                |> Element.el [ Element.centerY ]
                            )
                    }
            )
        |> Widget.itemList
            (Material.column
                |> Customize.elementColumn [ Element.width Element.fill ]
                |> Customize.mapContent (Customize.element [ Element.width Element.fill ])
            )
        |> Element.el
            [ Element.scrollbarY
            , Element.height Element.fill
            , Element.width Element.fill
            ]
    , navigation Element.none
    ]


view : Request -> Shared.Model -> Model -> View Msg
view request shared model =
    let
        navigation =
            Navigation.view { fun = Navigate, back = Home_ } request.route
    in
    { title = Config.title
    , body =
        viewList navigation shared.ingredientList
            |> Element.column
                [ Element.centerY
                , Element.centerX
                , Element.spaceEvenly
                , Element.height <| Element.fill
                , Element.width <| Element.fill
                ]
            |> Element.el
                [ Element.width <| Element.px 400
                , Element.height <| Element.px 600
                ]
    }
