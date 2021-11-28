module Gen.Route exposing
    ( Route(..)
    , fromUrl
    , toHref
    )

import Gen.Params.Home_
import Gen.Params.Ingredients
import Gen.Params.NotFound
import Gen.Params.Ingredients.Name_
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Home_
    | Ingredients
    | NotFound
    | Ingredients__Name_ { name : String }


fromUrl : Url -> Route
fromUrl =
    Parser.parse (Parser.oneOf routes) >> Maybe.withDefault NotFound


routes : List (Parser (Route -> a) a)
routes =
    [ Parser.map Home_ Gen.Params.Home_.parser
    , Parser.map Ingredients Gen.Params.Ingredients.parser
    , Parser.map NotFound Gen.Params.NotFound.parser
    , Parser.map Ingredients__Name_ Gen.Params.Ingredients.Name_.parser
    ]


toHref : Route -> String
toHref route =
    let
        joinAsHref : List String -> String
        joinAsHref segments =
            "/" ++ String.join "/" segments
    in
    case route of
        Home_ ->
            joinAsHref []
    
        Ingredients ->
            joinAsHref [ "ingredients" ]
    
        NotFound ->
            joinAsHref [ "not-found" ]
    
        Ingredients__Name_ params ->
            joinAsHref [ "ingredients", params.name ]

