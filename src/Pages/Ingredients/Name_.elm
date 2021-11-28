module Pages.Ingredients.Name_ exposing (Model, Msg, page)

import Bridge exposing (..)
import Browser.Navigation as Nav
import Config
import Data.Ingredient exposing (Ingredient)
import Data.Property as Property
import Dict
import Effect exposing (Effect)
import Element exposing (Element)
import Element.Font as Font
import Element.Input as Input
import Gen.Params.Ingredients.Name_ exposing (Params)
import Gen.Route as Route exposing (Route(..))
import Page
import Request
import Set
import Shared
import Url
import View exposing (View)
import View.Navigation as Navigation
import Widget
import Widget.Customize as Customize
import Widget.Material as Material
import Widget.Material.Typography as Typography


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init req shared
        , update = update req shared
        , subscriptions = subscriptions
        , view = view req shared
        }



-- INIT


type alias Model =
    { ingredient : Ingredient }


decodeName : Request.With Params -> String
decodeName request =
    if request.params.name == "new" then
        ""

    else
        request.params.name
            |> Url.percentDecode
            |> Maybe.withDefault ""


init : Request.With Params -> Shared.Model -> ( Model, Effect Msg )
init request shared =
    let
        name =
            request |> decodeName

        ingredient =
            shared.ingredientList
                |> Dict.get name
                |> Maybe.withDefault
                    { name = name
                    , properties = Set.empty
                    }
    in
    ( { ingredient = ingredient }
    , Effect.none
    )



-- UPDATE


type Msg
    = Toggle String
    | ToBackend ToBackend
    | Navigate Route
    | Rename String
    | Save
    | Remove


update : Request.With Params -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update request shared msg model =
    let
        name =
            request |> decodeName

        ingredient =
            model.ingredient
    in
    case msg of
        Rename newName ->
            ( { model | ingredient = { ingredient | name = newName } }
            , Effect.none
            )

        Save ->
            ( model
            , (Route.Ingredients
                |> Route.toHref
                |> Nav.pushUrl request.key
                |> Effect.fromCmd
              )
                :: (if ingredient.name /= "" then
                        [ UpdateIngredient name model.ingredient
                            |> sendToBackend
                            |> Effect.fromCmd
                        ]

                    else
                        []
                   )
                |> Effect.batch
            )

        Remove ->
            ( model
            , (Route.Ingredients
                |> Route.toHref
                |> Nav.pushUrl request.key
                |> Effect.fromCmd
              )
                :: (if name /= "" then
                        [ RemoveIngredient name
                            |> sendToBackend
                            |> Effect.fromCmd
                        ]

                    else
                        []
                   )
                |> Effect.batch
            )

        Navigate route ->
            ( model
            , Route.toHref route |> Nav.pushUrl request.key |> Effect.fromCmd
            )

        Toggle string ->
            ( { model
                | ingredient =
                    { ingredient
                        | properties =
                            ingredient.properties
                                |> (if ingredient.properties |> Set.member string then
                                        Set.remove string

                                    else
                                        Set.insert string
                                   )
                    }
              }
            , Effect.none
            )

        ToBackend toBackendMsg ->
            ( model
            , toBackendMsg
                |> sendToBackend
                |> Effect.fromCmd
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


viewInput : { title : String, value : String, onChange : String -> Msg } -> Element Msg
viewInput args =
    Widget.textInput (Material.textInput Config.palette)
        { chips = []
        , text = args.value
        , placeholder = Nothing
        , label = args.title
        , onChange = args.onChange
        }


viewDetail : Ingredient -> (Element Msg -> Element Msg) -> List (Element Msg)
viewDetail ingredient navigation =
    [ viewInput
        { title = "Name"
        , value = ingredient.name
        , onChange = Rename
        }
    , Property.list
        |> List.map
            (\property ->
                Widget.fullBleedItem (Material.fullBleedItem Config.palette)
                    { text = property.name
                    , onPress = Toggle property.name |> Just
                    , icon =
                        \_ ->
                            Widget.switch (Material.switch Config.palette)
                                { description = "Toggle"
                                , onPress = Toggle property.name |> Just
                                , active =
                                    ingredient.properties
                                        |> Set.member property.name
                                }
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
    , [ Widget.button (Material.textButton Config.palette)
            { text = "Entfernen"
            , icon = always Element.none
            , onPress =
                Remove
                    |> Just
            }
      , Widget.button (Material.containedButton Config.palette)
            { text = "Speichern"
            , icon = always Element.none
            , onPress =
                Save
                    |> Just
            }
      ]
        |> Element.row [ Element.spacing 16 ]
        |> navigation
    ]


view : Request.With Params -> Shared.Model -> Model -> View Msg
view request shared model =
    let
        navigation =
            Navigation.view { fun = Navigate, back = Ingredients } request.route
    in
    { title = Config.title
    , body =
        viewDetail model.ingredient navigation
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
