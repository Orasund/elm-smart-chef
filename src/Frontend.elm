module Frontend exposing (..)

import Bridge exposing (ToBackend(..))
import Browser
import Browser.Dom
import Browser.Navigation as Nav exposing (Key)
import Color
import Data.Cooking as Cooking exposing (Cooking(..))
import Effect
import Element
import Element.Background as Background
import Gen.Model
import Gen.Pages as Pages
import Gen.Route as Route
import Lamdera
import Random
import Request
import Set
import Shared
import Task
import Types exposing (FrontendModel, FrontendMsg(..), ToFrontend(..))
import Url exposing (Url)
import View


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


init : Url -> Key -> ( Model, Cmd Msg )
init url key =
    let
        ( shared, sharedCmd ) =
            Shared.init (Request.create () url key) ()

        ( page, effect ) =
            Pages.init (Route.fromUrl url) shared url key
    in
    ( { url = url
      , key = key
      , shared = shared
      , page = page
      }
    , Cmd.batch
        [ Cmd.map Shared sharedCmd
        , Effect.toCmd ( Shared, Page ) effect
        ]
    )



-- UPDATE


scrollPageToTop =
    Task.perform (\_ -> Noop) (Browser.Dom.setViewport 0 0)


type alias Msg =
    FrontendMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink (Browser.Internal url) ->
            ( model
            , Nav.pushUrl model.key (Url.toString url)
            )

        ClickedLink (Browser.External url) ->
            ( model
            , Nav.load url
            )

        ChangedUrl url ->
            if url.path /= model.url.path then
                let
                    ( page, effect ) =
                        Pages.init (Route.fromUrl url) model.shared url model.key
                in
                ( { model | url = url, page = page }
                , Cmd.batch [ Effect.toCmd ( Shared, Page ) effect, scrollPageToTop ]
                )

            else
                ( { model | url = url }, Cmd.none )

        Shared sharedMsg ->
            let
                ( shared, sharedCmd ) =
                    Shared.update (Request.create () model.url model.key) sharedMsg model.shared

                ( page, effect ) =
                    Pages.init (Route.fromUrl model.url) shared model.url model.key
            in
            if page == Gen.Model.Redirecting_ then
                ( { model | shared = shared, page = page }
                , Cmd.batch
                    [ Cmd.map Shared sharedCmd
                    , Effect.toCmd ( Shared, Page ) effect
                    ]
                )

            else
                ( { model | shared = shared }
                , Cmd.map Shared sharedCmd
                )

        Page pageMsg ->
            let
                ( page, effect ) =
                    Pages.update pageMsg model.page model.shared model.url model.key
            in
            ( { model | page = page }
            , Effect.toCmd ( Shared, Page ) effect
            )

        Noop ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    let
        shared =
            model.shared
    in
    case msg of
        NewChef chef avaiableIngredients ->
            let
                ( ( cooking, maybeIngredient ), seed ) =
                    model.shared.seed
                        |> Random.step
                            (chef
                                |> Cooking.start avaiableIngredients
                                |> Random.andThen
                                    (\c ->
                                        c
                                            |> Cooking.chooseIngredient
                                            |> Random.map (\i -> ( c, i ))
                                    )
                            )
            in
            case maybeIngredient of
                Just ingredient ->
                    ( { model
                        | shared =
                            { shared
                                | cooking = Just (Prepairing cooking)
                                , ingredient = Just ingredient
                                , ingredientList =
                                    avaiableIngredients
                                        |> Set.toList
                                        |> List.sort
                                , seed = seed
                            }
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model
                    , StartCooking
                        |> Lamdera.sendToBackend
                    )

        NoDishFound ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    model.shared
        |> Shared.view (Request.create () model.url model.key)
            { page = Pages.view model.page model.shared model.url model.key |> View.map Page
            , toMsg = Shared
            }
        |> (\{ title, body } ->
                { title = title
                , body =
                    [ body
                        |> Element.el
                            [ Element.centerX
                            , Element.centerY
                            , Element.padding 32
                            ]
                        |> Element.layoutWith
                            { options =
                                [ Element.focusStyle
                                    { borderColor = Nothing
                                    , backgroundColor = Nothing
                                    , shadow = Nothing
                                    }
                                ]
                            }
                            [ Element.width Element.fill
                            , Element.height Element.fill
                            , Color.rgb255 203 191 122
                                |> Color.toRgba
                                |> Element.fromRgb
                                |> Background.color
                            ]
                    ]
                }
           )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Pages.subscriptions model.page model.shared model.url model.key |> Sub.map Page
        , Shared.subscriptions (Request.create () model.url model.key) model.shared |> Sub.map Shared
        ]
