module Pages.Home_ exposing (Model, Msg(..), page)

import Bridge exposing (..)
import Config
import Data.Cooking exposing (Cooking(..))
import Data.Dish exposing (Dish)
import Data.Ingredient as Ingredient exposing (Ingredient)
import Effect exposing (Effect)
import Element exposing (Element)
import Element.Font as Font
import Element.Input as Input
import Lamdera
import Page
import Request exposing (Request)
import Shared exposing (Msg(..))
import View exposing (View)
import Widget
import Widget.Material as Material
import Widget.Material.Typography as Typography


page : Shared.Model -> Request -> Page.With Model Msg
page shared _ =
    Page.advanced
        { init = init shared
        , update = update shared
        , subscriptions = subscriptions
        , view = view shared
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


update : Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update shared msg model =
    case msg of
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


viewStart : List (Element Msg)
viewStart =
    [ "Quick Chef"
        |> Element.text
        |> List.singleton
        |> Element.paragraph Typography.h1
        |> Element.el
            [ Element.centerX
            , Element.alignTop
            , Font.family [ Font.serif ]
            , Font.center
            ]
        |> List.singleton
    , ("Hunger?"
        |> Element.text
      )
        |> Element.el [ Element.centerX, Element.centerY ]
        |> List.singleton
    , Widget.button (Material.containedButton Config.palette)
        { text = "Start"
        , icon = always Element.none
        , onPress = Just CreateMeal
        }
        |> Element.el [ Element.centerX ]
        |> List.singleton
    ]
        |> List.concat


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = ""
    , body =
        (case ( shared.cooking, shared.ingredient ) of
            ( Just (Done dish), _ ) ->
                viewFinal dish

            ( _, Just ingredient ) ->
                viewIngredientPicker ingredient

            ( _, _ ) ->
                viewStart
        )
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
