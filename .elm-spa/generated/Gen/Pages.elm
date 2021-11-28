module Gen.Pages exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation exposing (Key)
import Effect exposing (Effect)
import ElmSpa.Page
import Gen.Params.Home_
import Gen.Params.Ingredients
import Gen.Params.NotFound
import Gen.Params.Ingredients.Name_
import Gen.Model as Model
import Gen.Msg as Msg
import Gen.Route as Route exposing (Route)
import Page exposing (Page)
import Pages.Home_
import Pages.Ingredients
import Pages.NotFound
import Pages.Ingredients.Name_
import Request exposing (Request)
import Shared
import Task
import Url exposing (Url)
import View exposing (View)


type alias Model =
    Model.Model


type alias Msg =
    Msg.Msg


init : Route -> Shared.Model -> Url -> Key -> ( Model, Effect Msg )
init route =
    case route of
        Route.Home_ ->
            pages.home_.init ()
    
        Route.Ingredients ->
            pages.ingredients.init ()
    
        Route.NotFound ->
            pages.notFound.init ()
    
        Route.Ingredients__Name_ params ->
            pages.ingredients__name_.init params


update : Msg -> Model -> Shared.Model -> Url -> Key -> ( Model, Effect Msg )
update msg_ model_ =
    case ( msg_, model_ ) of
        ( Msg.Home_ msg, Model.Home_ params model ) ->
            pages.home_.update params msg model
    
        ( Msg.Ingredients msg, Model.Ingredients params model ) ->
            pages.ingredients.update params msg model
    
        ( Msg.Ingredients__Name_ msg, Model.Ingredients__Name_ params model ) ->
            pages.ingredients__name_.update params msg model

        _ ->
            \_ _ _ -> ( model_, Effect.none )


view : Model -> Shared.Model -> Url -> Key -> View Msg
view model_ =
    case model_ of
        Model.Redirecting_ ->
            \_ _ _ -> View.none
    
        Model.Home_ params model ->
            pages.home_.view params model
    
        Model.Ingredients params model ->
            pages.ingredients.view params model
    
        Model.NotFound params ->
            pages.notFound.view params ()
    
        Model.Ingredients__Name_ params model ->
            pages.ingredients__name_.view params model


subscriptions : Model -> Shared.Model -> Url -> Key -> Sub Msg
subscriptions model_ =
    case model_ of
        Model.Redirecting_ ->
            \_ _ _ -> Sub.none
    
        Model.Home_ params model ->
            pages.home_.subscriptions params model
    
        Model.Ingredients params model ->
            pages.ingredients.subscriptions params model
    
        Model.NotFound params ->
            pages.notFound.subscriptions params ()
    
        Model.Ingredients__Name_ params model ->
            pages.ingredients__name_.subscriptions params model



-- INTERNALS


pages :
    { home_ : Bundle Gen.Params.Home_.Params Pages.Home_.Model Pages.Home_.Msg
    , ingredients : Bundle Gen.Params.Ingredients.Params Pages.Ingredients.Model Pages.Ingredients.Msg
    , notFound : Static Gen.Params.NotFound.Params
    , ingredients__name_ : Bundle Gen.Params.Ingredients.Name_.Params Pages.Ingredients.Name_.Model Pages.Ingredients.Name_.Msg
    }
pages =
    { home_ = bundle Pages.Home_.page Model.Home_ Msg.Home_
    , ingredients = bundle Pages.Ingredients.page Model.Ingredients Msg.Ingredients
    , notFound = static Pages.NotFound.view Model.NotFound
    , ingredients__name_ = bundle Pages.Ingredients.Name_.page Model.Ingredients__Name_ Msg.Ingredients__Name_
    }


type alias Bundle params model msg =
    ElmSpa.Page.Bundle params model msg Shared.Model (Effect Msg) Model Msg (View Msg)


bundle page toModel toMsg =
    ElmSpa.Page.bundle
        { redirecting =
            { model = Model.Redirecting_
            , view = View.none
            }
        , toRoute = Route.fromUrl
        , toUrl = Route.toHref
        , fromCmd = Effect.fromCmd
        , mapEffect = Effect.map toMsg
        , mapView = View.map toMsg
        , toModel = toModel
        , toMsg = toMsg
        , page = page
        }


type alias Static params =
    Bundle params () Never


static : View Never -> (params -> Model) -> Static params
static view_ toModel =
    { init = \params _ _ _ -> ( toModel params, Effect.none )
    , update = \params _ _ _ _ _ -> ( toModel params, Effect.none )
    , view = \_ _ _ _ _ -> View.map never view_
    , subscriptions = \_ _ _ _ _ -> Sub.none
    }
    
