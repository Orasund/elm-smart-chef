module Data.Chef exposing (Chef, cook, list)

import Data.Ingredient as Ingredient exposing (Ingredient)
import Data.Property as Property exposing (Property)
import Random exposing (Generator)
import Random.List
import Set


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
    chooseFirstIngredient chef
        |> Random.map
            (\first ->
                first
                    |> Maybe.map List.singleton
                    |> Maybe.withDefault []
            )
        |> Random.andThen (chooseIngredient chef)
        |> Random.andThen (chooseIngredient chef)


chooseFirstIngredient : Chef -> Generator (Maybe Ingredient)
chooseFirstIngredient chef =
    Ingredient.list
        |> (case chef.startWith of
                Just property ->
                    List.filter
                        (\ingredient ->
                            ingredient.properties
                                |> Set.member property.name
                        )

                Nothing ->
                    identity
           )
        |> Random.List.choose
        |> Random.map Tuple.first


chooseIngredient : Chef -> List Ingredient -> Generator (List Ingredient)
chooseIngredient chef used =
    let
        include =
            chef.include |> List.map .name |> Set.fromList

        exclude =
            chef.exclude |> List.map .name |> Set.fromList

        usedItems =
            used |> List.map .name |> Set.fromList
    in
    Ingredient.list
        |> List.filter (\i -> usedItems |> Set.member i.name |> not)
        |> List.filter
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
        |> Random.List.choose
        |> Random.map
            (\( t, _ ) ->
                t
                    |> Maybe.map (\a -> a :: used)
                    |> Maybe.withDefault used
            )
