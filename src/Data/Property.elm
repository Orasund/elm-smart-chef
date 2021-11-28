module Data.Property exposing (Property, beans, fish, list, protein, sauce, vegetable)


type alias Property =
    { name : String }


list : List Property
list =
    [ beans
    , protein
    , fish
    , sauce
    , vegetable
    ]


vegetable : Property
vegetable =
    { name = "Gemüse" }


fish : Property
fish =
    { name = "Fisch" }


protein : Property
protein =
    { name = "Protein" }


beans : Property
beans =
    { name = "Hülsenfrüchte" }


sauce : Property
sauce =
    { name = "Saucen Starter" }
