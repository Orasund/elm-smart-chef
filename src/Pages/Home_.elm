module Pages.Home_ exposing (Model, Msg(..), page)

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
page shared req =
    Page.advanced
        { init = init shared
        , update = update req shared
        , subscriptions = subscriptions
        , view = view req shared
        }



-- INIT


type alias Model =
    ()


init : Shared.Model -> ( Model, Effect Msg )
init shared =
    ( ()
    , SyncIngredients
        |> sendToBackend
        |> Effect.fromCmd
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


viewFinal : (Element Msg -> Element Msg) -> Dish -> List (Element Msg)
viewFinal navigation meal =
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
        |> navigation
        |> List.singleton
    ]
        |> List.concat


viewIngredientPicker : (Element Msg -> Element Msg) -> Ingredient -> List (Element Msg)
viewIngredientPicker navigation ingredient =
    [ "Hast du "
        ++ ingredient.name
        ++ " zuhause?"
        |> Element.text
        |> Element.el [ Element.centerX, Element.centerY ]
    , [ Widget.button (Material.textButton Config.palette)
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
            [ Element.alignBottom
            , Element.spacing 16
            ]
        |> navigation
    ]


viewStart : (Element Msg -> Element Msg) -> List (Element Msg)
viewStart navigation =
    [ ("Hunger?"
        |> Element.text
      )
        |> Element.el [ Element.centerX, Element.centerY ]
        |> List.singleton
    , Widget.button (Material.containedButton Config.palette)
        { text = "Start"
        , icon = always Element.none
        , onPress = Just CreateMeal
        }
        |> navigation
        |> List.singleton
    ]
        |> List.concat


view : Request -> Shared.Model -> Model -> View Msg
view request shared model =
    let
        navigation =
            Navigation.view Navigate request.route
    in
    { title = Config.title
    , body =
        (("Quick Chef"
            |> Element.text
            |> List.singleton
            |> Element.paragraph Typography.h1
            |> Element.el
                [ Element.centerX
                , Element.alignTop
                , Font.family [ Font.serif ]
                , Font.center
                ]
         )
            :: (case ( shared.cooking, shared.ingredient ) of
                    ( Just (Done dish), _ ) ->
                        viewFinal navigation dish

                    ( _, Just ingredient ) ->
                        viewIngredientPicker navigation ingredient

                    ( _, _ ) ->
                        viewStart navigation
               )
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
