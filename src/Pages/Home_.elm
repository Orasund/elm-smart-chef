module Pages.Home_ exposing (Model, Msg(..), page)

import Bridge exposing (..)
import Data.Dish exposing (Dish)
import Effect exposing (Effect)
import Element
import Element.Input as Input
import Lamdera
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page shared _ =
    Page.element
        { init = init shared
        , update = update shared
        , subscriptions = subscriptions
        , view = view shared
        }



-- INIT


type alias Model =
    ()


init : Shared.Model -> ( Model, Cmd Msg )
init shared =
    ( ()
    , Cmd.none
    )



-- UPDATE


type Msg
    = CreateMeal
    | UseIngredient Bool


update : Shared.Model -> Msg -> Model -> ( Model, Cmd Msg )
update shared msg model =
    case msg of
        CreateMeal ->
            ( model
            , StartCooking |> sendToBackend
            )

        UseIngredient bool ->
            ( model
            , shared.ingredient
                |> Maybe.map
                    (\i ->
                        if bool then
                            Include i

                        else
                            ChooseIngredient
                    )
                |> Maybe.withDefault ChooseIngredient
                |> sendToBackend
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = ""
    , body =
        [ (case shared.meal of
            Nothing ->
                "Hunger?" |> Element.text

            Just meal ->
                meal.base
                    ++ " mit "
                    ++ (case meal.ingredients of
                            [] ->
                                "Sauce"

                            [ a ] ->
                                a.name

                            head :: tail ->
                                (tail
                                    |> List.map .name
                                    |> String.join ", "
                                )
                                    ++ " und "
                                    ++ head.name
                       )
                    |> Element.text
          )
            |> Element.el [ Element.centerX, Element.centerY ]
            |> List.singleton
        , case shared.ingredient of
            Just i ->
                [ "Hast du "
                    ++ i.name
                    ++ " zuhause?"
                    |> Element.text
                , Input.button [ Element.centerX, Element.centerY ]
                    { onPress = Just <| UseIngredient True
                    , label = Element.text "Ja"
                    }
                , Input.button [ Element.centerX, Element.centerY ]
                    { onPress = Just <| UseIngredient False
                    , label = Element.text "Nein"
                    }
                ]

            Nothing ->
                Input.button [ Element.centerX, Element.centerY ]
                    { onPress = Just CreateMeal
                    , label =
                        Element.text
                            (case shared.meal of
                                Just _ ->
                                    "Noch ein Gericht"

                                Nothing ->
                                    "Start"
                            )
                    }
                    |> List.singleton
        ]
            |> List.concat
            |> Element.column
                [ Element.centerY
                , Element.centerX
                , Element.spacing 10
                ]
            |> Element.el
                [ Element.height <| Element.fill
                , Element.width <| Element.fill
                ]
    }
