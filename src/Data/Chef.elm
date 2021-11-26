module Data.Chef exposing (Chef, cook, list)

import Data.Ingredient as Ingredient exposing (Ingredient)
import Data.Property as Property exposing (Property)
import Random exposing (Generator)
import Random.List


type alias Chef =
    { startWith : Maybe Property
    , include : List Property
    , exclude : List Property
    }


list : List Chef
list =
    [ { startWith = Just Property.carb
      , include = [ Property.vegetable ]
      , exclude = []
      }
    , { startWith = Just Property.fish
      , include = [ Property.vegetable ]
      , exclude = []
      }
    , { startWith = Just Property.beans
      , include = [ Property.vegetable ]
      , exclude = []
      }
    , { startWith = Just Property.vegetable
      , include = [ Property.vegetable ]
      , exclude = []
      }
    ]


cook : Chef -> Generator (List Ingredient)
cook chef =
    Ingredient.list
        |> Random.List.choices 2
        |> Random.map Tuple.first
