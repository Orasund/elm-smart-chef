module Data.Property exposing (Property, beans, carb, fish, vegetable)


type alias Property =
    { name : String }


vegetable : Property
vegetable =
    { name = "vegetable" }


fish : Property
fish =
    { name = "fish" }


carb : Property
carb =
    { name = "carb" }


beans : Property
beans =
    { name = "beans" }
