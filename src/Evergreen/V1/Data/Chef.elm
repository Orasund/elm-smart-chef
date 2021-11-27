module Evergreen.V1.Data.Chef exposing (..)

import Evergreen.V1.Data.Base
import Evergreen.V1.Data.Property


type alias Chef =
    { startWith : Maybe Evergreen.V1.Data.Property.Property
    , include : List Evergreen.V1.Data.Property.Property
    , exclude : List Evergreen.V1.Data.Property.Property
    , bases : ( Evergreen.V1.Data.Base.Base, List Evergreen.V1.Data.Base.Base )
    }
