module Data.Chef exposing (Chef, chooseFirstIngredient, chooseIngredient, list, using)

import Data.Base as Base exposing (Base)
import Data.Ingredient as Ingredient exposing (Ingredient)
import Data.Property as Property exposing (Property)
import Dict exposing (Dict)
import Random exposing (Generator)
import Random.List
import Set exposing (Set)


type alias Chef =
    { startWith : Maybe Property
    , include : List Property
    , exclude : List Property
    , bases : ( Base, List Base )
    }


list : List Chef
list =
    [ { startWith = Just Property.protein
      , include = [ Property.vegetable, Property.sauce ]
      , exclude = []
      , bases = ( Base.rice, [ Base.potatos ] )
      }
    , { startWith = Just Property.fish
      , include = [ Property.vegetable, Property.sauce ]
      , exclude = []
      , bases = ( Base.rice, [ Base.wrap, Base.potatos ] )
      }
    , { startWith = Just Property.beans
      , include = [ Property.vegetable, Property.sauce ]
      , exclude = []
      , bases = ( Base.rice, [ Base.wrap, Base.couscous, Base.potatos ] )
      }
    , { startWith = Nothing
      , include = [ Property.vegetable, Property.sauce ]
      , exclude = []
      , bases = ( Base.rice, [ Base.wrap, Base.couscous, Base.potatos ] )
      }
    , { startWith = Just Property.sauce
      , include = [ Property.vegetable, Property.beans, Property.fish ]
      , exclude = [ Property.sauce ]
      , bases = ( Base.wrap, [ Base.potatos ] )
      }
    , { startWith = Just Property.sauce
      , include = [ Property.vegetable, Property.fish ]
      , exclude = [ Property.sauce ]
      , bases = ( Base.noodles, [] )
      }
    , { startWith = Just Property.vegetable
      , include = [ Property.vegetable, Property.protein ]
      , exclude = []
      , bases = ( Base.ramen, [] )
      }
    ]


using : Ingredient -> List Chef
using ingredient =
    list
        |> List.filter
            (\chef ->
                case chef.startWith of
                    Just property ->
                        ingredient.properties
                            |> Set.member property.name

                    Nothing ->
                        chef.include
                            |> List.any
                                (\property ->
                                    ingredient.properties
                                        |> Set.member property.name
                                )
            )


chooseFirstIngredient : Chef -> Dict String Ingredient -> Generator (Maybe Ingredient)
chooseFirstIngredient chef avaiableIngredients =
    case chef.startWith of
        Just property ->
            avaiableIngredients
                |> Dict.filter
                    (\_ ingredient ->
                        ingredient.properties
                            |> Set.member property.name
                    )
                |> Dict.values
                |> Random.List.choose
                |> Random.map Tuple.first

        Nothing ->
            chooseIngredient chef avaiableIngredients


chooseIngredient : Chef -> Dict String Ingredient -> Generator (Maybe Ingredient)
chooseIngredient chef avaiableIngredients =
    let
        include =
            chef.include |> List.map .name |> Set.fromList

        exclude =
            chef.exclude |> List.map .name |> Set.fromList
    in
    avaiableIngredients
        |> Dict.filter
            (\_ ingredient ->
                ingredient.properties
                    |> Set.toList
                    |> (\l ->
                            (l
                                |> List.any
                                    (\property ->
                                        include |> Set.member property
                                    )
                            )
                                && (l
                                        |> List.all
                                            (\property ->
                                                exclude
                                                    |> Set.member property
                                                    |> not
                                            )
                                   )
                       )
            )
        |> Dict.values
        |> Random.List.choose
        |> Random.map Tuple.first
