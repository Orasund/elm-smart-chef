module Data.Chef exposing (Chef, chooseFirstIngredient, chooseIngredient, list)

import Data.Base as Base exposing (Base)
import Data.Ingredient as Ingredient exposing (Ingredient)
import Data.Property as Property exposing (Property)
import Random exposing (Generator)
import Random.List
import Set exposing (Set)
import Set.Any as AnySet exposing (AnySet)


type alias Chef =
    { startWith : Maybe Property
    , include : List Property
    , exclude : List Property
    , bases : ( Base, List Base )
    }


list : List Chef
list =
    [ { startWith = Just Property.carb
      , include = [ Property.vegetable, Property.sauce ]
      , exclude = []
      , bases = ( Base.rice, [] )
      }
    , { startWith = Just Property.fish
      , include = [ Property.vegetable, Property.sauce ]
      , exclude = []
      , bases = ( Base.rice, [ Base.wrap ] )
      }
    , { startWith = Just Property.beans
      , include = [ Property.vegetable, Property.sauce ]
      , exclude = []
      , bases = ( Base.rice, [ Base.wrap ] )
      }
    , { startWith = Nothing
      , include = [ Property.vegetable, Property.sauce ]
      , exclude = []
      , bases = ( Base.rice, [ Base.wrap ] )
      }
    , { startWith = Just Property.sauce
      , include = [ Property.vegetable, Property.beans ]
      , exclude = [ Property.sauce ]
      , bases = ( Base.wrap, [] )
      }
    ]


chooseFirstIngredient : Chef -> Set String -> Generator (Maybe Ingredient)
chooseFirstIngredient chef avaiableIngredientsList =
    let
        avaiableIngredients =
            Ingredient.set
                |> AnySet.filter (\{ name } -> avaiableIngredientsList |> Set.member name)
    in
    case chef.startWith of
        Just property ->
            avaiableIngredients
                |> AnySet.filter
                    (\ingredient ->
                        ingredient.properties
                            |> Set.member property.name
                    )
                |> AnySet.toList
                |> Random.List.choose
                |> Random.map Tuple.first

        Nothing ->
            chooseIngredient chef avaiableIngredientsList


chooseIngredient : Chef -> Set String -> Generator (Maybe Ingredient)
chooseIngredient chef avaiableIngredientsList =
    let
        avaiableIngredients =
            Ingredient.set
                |> AnySet.filter (\{ name } -> avaiableIngredientsList |> Set.member name)

        include =
            chef.include |> List.map .name |> Set.fromList

        exclude =
            chef.exclude |> List.map .name |> Set.fromList
    in
    avaiableIngredients
        |> AnySet.filter (\i -> avaiableIngredients |> AnySet.member i)
        |> AnySet.filter
            (\ingredient ->
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
        |> AnySet.toList
        |> Random.List.choose
        |> Random.map Tuple.first
