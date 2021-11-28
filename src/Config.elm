module Config exposing (maxIngredients, palette, title)

import Color
import Widget.Material as Material exposing (Palette, defaultPalette)


maxIngredients : Int
maxIngredients =
    3


palette : Palette
palette =
    { defaultPalette
        | primary = Color.rgb255 63 97 45
        , secondary = Color.rgb255 63 97 45
        , background = Color.rgb255 161 192 132
    }


title : String
title =
    "Quick Chef"
