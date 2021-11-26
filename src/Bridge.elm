module Bridge exposing (ToBackend(..), sendToBackend)

import Lamdera


sendToBackend =
    Lamdera.sendToBackend


type ToBackend
    = StartCooking
