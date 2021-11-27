module Pages.Ingredients exposing (Model, Msg(..), page)

import Bridge exposing (..)
import Browser.Navigation as Nav
import Config
import Data.Cooking exposing (Cooking(..))
import Data.Dish exposing (Dish)
import Data.Ingredient as Ingredient exposing (Ingredient)
import Effect exposing (Effect)
import Element exposing (Element)
import Element.Font as Font
import Element.Input as Input
import Gen.Route as Route exposing (Route)
import Lamdera
import Page
import Request exposing (Request)
import Shared exposing (Msg(..))
import View exposing (View)
import View.Navigation as Navigation
import Widget
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
    = CreateMeal
    | UseIngredient Bool
    | Navigate Route


update : Request -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update request shared msg model =
    case msg of
        Navigate route ->
            ( model
            , Route.toHref route |> Nav.pushUrl request.key |> Effect.fromCmd
            )

        CreateMeal ->
            ( model
            , StartCooking
                |> sendToBackend
                |> Effect.fromCmd
            )

        UseIngredient bool ->
            ( model
            , (if bool then
                IncludeIngredient

               else
                ExcludeIngredient
              )
                |> Effect.fromShared
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


viewFinal : Dish -> List (Element Msg)
viewFinal meal =
    [ Widget.button (Material.containedButton Config.palette)
        { text = "Noch ein Gericht"
        , icon = always Element.none
        , onPress = Just CreateMeal
        }
        |> Element.el [ Element.alignTop, Element.centerX ]
        |> List.singleton
    , meal.base
        ++ (case meal.ingredients of
                [] ->
                    ""

                [ a ] ->
                    " mit " ++ a.name

                head :: tail ->
                    " mit "
                        ++ (tail
                                |> List.map .name
                                |> String.join ", "
                           )
                        ++ " und "
                        ++ head.name
           )
        |> Element.text
        |> Element.el [ Element.centerX, Element.centerY ]
        |> List.singleton
    , Element.el [] Element.none
        |> List.singleton
    ]
        |> List.concat


viewIngredientPicker : Ingredient -> List (Element Msg)
viewIngredientPicker ingredient =
    [ "Hast du "
        ++ ingredient.name
        ++ " zuhause?"
        |> Element.text
        |> Element.el [ Element.centerX, Element.alignTop ]
    , Element.el [] Element.none
    , [ Widget.button (Material.containedButton Config.palette)
            { onPress = Just <| UseIngredient False
            , icon = always Element.none
            , text = "Nein"
            }
      , Widget.button (Material.containedButton Config.palette)
            { onPress = Just <| UseIngredient True
            , icon = always Element.none
            , text = "Ja"
            }
      ]
        |> Element.row
            [ Element.centerX
            , Element.alignBottom
            , Element.spacing 16
            ]
    ]


viewList : (Element Msg -> Element Msg) -> List String -> List (Element Msg)
viewList navigation list =
    [ list
        |> List.map
            (\text ->
                Widget.fullBleedItem (Material.fullBleedItem Config.palette)
                    { text = text
                    , onPress = Nothing
                    , icon = always Element.none
                    }
            )
        |> Widget.itemList Material.column
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
            Navigation.view Navigate request.route
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
