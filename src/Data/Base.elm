module Data.Base exposing (Base, couscous, noodles, potatos, rice, wrap)


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


noodles : Base
noodles =
    new "Nudeln"


couscous : Base
couscous =
    new "Couscous"


potatos : Base
potatos =
    new "Kartoffeln"
