module View exposing (View, map)

import Html exposing (Html)
import Html.Attributes as Attributes
import Route


{-|

@docs View, map

-}
type alias View msg =
    { title : String
    , body : List (Html msg)
    }


{-| -}
map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn doc =
    { title = doc.title
    , body = viewHeader :: List.map (Html.map fn) doc.body
    }


viewHeader =
    Html.header
        [ Attributes.class "flex items-center px-4 py-2 mb-4 font-semibold shadow monospace md:py-6 "
        ]
        [ Route.Index
            |> Route.link
                [ Attributes.class "mr-auto"
                ]
                [ Html.text "Home" ]
        , Route.Blog
            |> Route.link [] [ Html.text "Blog" ]
        ]
