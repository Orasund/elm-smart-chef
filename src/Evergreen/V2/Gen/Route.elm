module Evergreen.V2.Gen.Route exposing (..)


type Route
    = Home_
    | Ingredients
    | NotFound
    | Ingredients__Name_
        { name : String
        }
