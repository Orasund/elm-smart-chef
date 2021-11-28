module Evergreen.V2.Data.Chef exposing (..)

import Evergreen.V2.Data.Base
import Evergreen.V2.Data.Property


type alias Chef =
    { startWith : Maybe Evergreen.V2.Data.Property.Property
    , include : List Evergreen.V2.Data.Property.Property
    , exclude : List Evergreen.V2.Data.Property.Property
    , bases : ( Evergreen.V2.Data.Base.Base, List Evergreen.V2.Data.Base.Base )
    }
