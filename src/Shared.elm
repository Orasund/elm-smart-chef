module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Config
import Data.Base as Base
import Data.Chef as Chef exposing (Chef)
import Data.Cooking as Cooking exposing (Cooking(..), CookingState)
import Data.Dish as Meal exposing (Dish)
import Data.Ingredient exposing (Ingredient)
import Element exposing (..)
import Element.Region as Region
import Random exposing (Seed)
import Request exposing (Request)
import Set exposing (Set)
import View exposing (View)



-- INIT


type alias Flags =
    ()


type alias Model =
    { ingredient : Maybe Ingredient
    , ingredientList : List String
    , cooking : Maybe Cooking
    , seed : Seed
    }


init : Request -> Flags -> ( Model, Cmd Msg )
init _ json =
    ( { ingredient = Nothing
      , ingredientList = []
      , cooking = Nothing
      , seed = Random.initialSeed 42
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = IncludeIngredient
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
update _ msg model =
    case msg of
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
