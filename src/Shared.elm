module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Bridge exposing (..)
import Browser.Navigation as Nav
import Config
import Data.Base as Base
import Data.Chef as Chef exposing (Chef)
import Data.Cooking as Cooking exposing (Cooking(..), CookingState)
import Data.Dish as Meal exposing (Dish)
import Data.Ingredient exposing (Ingredient)
import Dict exposing (Dict)
import Element exposing (..)
import Element.Region as Region
import Gen.Route as Route exposing (Route(..))
import Random exposing (Seed)
import Request exposing (Request)
import Set exposing (Set)
import View exposing (View)



-- INIT


type alias Flags =
    ()


type alias Model =
    { ingredient : Maybe Ingredient
    , ingredientList : Dict String Ingredient
    , cooking : Maybe Cooking
    , seed : Seed
    }


init : Request -> Flags -> ( Model, Cmd Msg )
init _ json =
    ( { ingredient = Nothing
      , ingredientList = Dict.empty
      , cooking = Nothing
      , seed = Random.initialSeed 42
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = StartWith Ingredient
    | IncludeIngredient
    | ExcludeIngredient


cooseIngredient : Model -> CookingState -> ( Model, Cmd Msg )
cooseIngredient model newState =
    let
        generator =
            Cooking.chooseIngredient newState
                |> Random.map
                    (\maybeIngredient ->
                        case maybeIngredient of
                            Just i ->
                                { model
                                    | cooking =
                                        newState
                                            |> Prepairing
                                            |> Just
                                    , ingredient = Just i
                                }

                            Nothing ->
                                { model
                                    | cooking =
                                        newState
                                            |> Cooking.toDish
                                            |> Done
                                            |> Just
                                    , ingredient = Nothing
                                }
                    )
    in
    if (newState.ingredients |> List.length) >= Config.maxIngredients then
        ( { model
            | cooking =
                newState
                    |> Cooking.toDish
                    |> Done
                    |> Just
            , ingredient = Nothing
          }
        , Cmd.none
        )

    else
        ( Random.step generator model.seed
            |> (\( m, s ) -> { m | seed = s })
        , Cmd.none
        )


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update request msg model =
    case msg of
        StartWith ingredient ->
            ( { model | ingredient = Just ingredient }
            , Cmd.batch
                [ Just ingredient.name
                    |> StartCooking
                    |> sendToBackend
                , Route.Home_
                    |> Route.toHref
                    |> Nav.pushUrl request.key
                ]
            )

        IncludeIngredient ->
            case model.cooking of
                Just (Prepairing state) ->
                    case model.ingredient of
                        Just ingredient ->
                            state
                                |> Cooking.includeIngredient ingredient
                                |> cooseIngredient model

                        Nothing ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ExcludeIngredient ->
            case model.cooking of
                Just (Prepairing state) ->
                    case model.ingredient of
                        Just ingredient ->
                            state
                                |> Cooking.excludeIngredient ingredient
                                |> cooseIngredient model

                        Nothing ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )


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
