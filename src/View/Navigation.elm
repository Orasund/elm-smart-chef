module View.Navigation exposing (view)

import Config
import Element exposing (Element)
import Gen.Route exposing (Route(..))
import Widget
import Widget.Material as Material


viewButton : { fun : Route -> msg, route : Route, text : String } -> Route -> Element msg
viewButton args route =
    Widget.button
        (if args.route == route then
            Material.containedButton Config.palette

         else
            Material.outlinedButton Config.palette
        )
        { text = args.text
        , icon = always Element.none
        , onPress = args.route |> args.fun |> Just
        }


view : (Route -> msg) -> Route -> Element msg -> Element msg
view fun route elem =
    [ (case route of
        Home_ ->
            route
                |> viewButton
                    { fun = fun
                    , route = Ingredients
                    , text = "Zutaten"
                    }

        _ ->
            route
                |> viewButton
                    { fun = fun
                    , route = Home_
                    , text = "Zurück"
                    }
      )
        |> Element.el [ Element.alignLeft ]
    , elem |> Element.el [ Element.alignRight ]
    ]
        |> Element.row [ Element.alignBottom, Element.spaceEvenly, Element.width Element.fill ]
