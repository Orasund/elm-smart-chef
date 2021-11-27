module Data.Base exposing (Base, rice, wrap)


type alias Base =
    { name : String }


new : String -> Base
new name =
    { name = name }


rice : Base
rice =
    new "Reis"


wrap : Base
wrap =
    new "Wrap"
