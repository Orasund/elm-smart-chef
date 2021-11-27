module Data.Ingredient exposing (Ingredient, set)

import Data.Property as Property exposing (Property)
import Set exposing (Set)
import Set.Any as AnySet exposing (AnySet)


type alias Ingredient =
    { name : String
    , properties : Set String
    }


new : String -> List Property -> Ingredient
new name properties =
    { name = name
    , properties = properties |> List.map .name |> Set.fromList
    }


set : AnySet String Ingredient
set =
    [ new "Erbsen" [ Property.vegetable, Property.beans ]
    , new "Thunfish" [ Property.fish ]
    , new "Linsen" [ Property.beans ]
    , new "Roten Bohnen" [ Property.carb, Property.beans ]
    , new "Ei" [ Property.carb ]
    , new "Brokkoli" [ Property.vegetable ]
    , new "Mais" [ Property.vegetable ]
    , new "Pilze" [ Property.carb ]
    , new "Tomaten" [ Property.vegetable ]
    , new "Salat" [ Property.vegetable ]
    , new "Feta" [ Property.sauce ]
    , new "Pesto" [ Property.sauce ]
    , new "Sauerrahm" [ Property.sauce ]
    , new "Tofu" [ Property.carb ]
    ]
        |> AnySet.fromList .name
