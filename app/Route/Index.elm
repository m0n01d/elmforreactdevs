module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Css exposing (monospace)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html
import Html.Attributes as Attributes
import Pages.Url
import PagesMsg exposing (PagesMsg)
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    { message : String
    }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.succeed Data
        |> BackendTask.andMap
            (BackendTask.succeed "Hello!")


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "ElmForReactDevs"
        , image =
            { url = [ "images", "icon-png.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "ElmForReactDevs logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Teaching FP to React devs"
        , locale = Nothing
        , title = "Functional Programming training for JS devs"
        }
        |> Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app shared =
    { title = "ElmForReactDevs"
    , body =
        [ Html.section
            [ Attributes.class "py-3 text-center md:py-12 md:px-8 "
            ]
            [ Html.h1
                [ Attributes.class "fancy-text" ]
                [ Html.text "ElmForReactDevs" ]
            , Html.div
                [ Attributes.class "flex flex-col items-center mt-8 d:flex-row"
                ]
                [ Html.div
                    [ Attributes.class "flex-1 px-6 "
                    ]
                    [ Html.h2
                        [ Attributes.class "mb-8 text-xl font-bold fancy-text"
                        ]
                        [ Html.text "Learn Functional Programming by building things!" ]
                    , Html.p
                        [ Attributes.class "text-lg "
                        ]
                        [ Html.text "An unlimited series making apps using functional languages and techniques"
                        ]
                    ]
                , Html.div
                    [ Attributes.class "flex-1 mt-2 "
                    ]
                    [ Html.iframe
                        [ Attributes.class "w-full aspect-video"
                        , Attributes.src "https://www.youtube.com/embed/qWHERlLcU94"
                        , Attributes.title "ElmForReactDevs YouTube"
                        , Attributes.attribute "frameborder" "0"
                        , Attributes.attribute "allow" "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                        , Attributes.attribute "allowfullscreen" ""
                        ]
                        []
                    , Html.caption
                        [ Attributes.class "block mt-2 text-center"
                        ]
                        [ Html.text "Let's build a Chrome Extension!" ]
                    ]
                ]
            ]
        , Html.section
            [ Attributes.class "flex flex-col justify-center py-12 mx-auto my-12 md:w-3/5 leading-7"
            ]
            [ Html.p []
                [ Html.span [ Attributes.class "fancy-text" ]
                    [ Html.a
                        [ Attributes.class "text-lg underline"
                        , Attributes.href "https://www.patreon.com/ElmForReactDevs"
                        , Attributes.target "_blank"
                        ]
                        [ Html.text "ElmForReactDevs" ]
                    ]
                , Html.text " is here to help other JavaScript and React developers get up to speed on functional programming using ReScript, JavaScript and Elm."
                ]
            , Html.p
                [ Attributes.class "my-2 text-lg"
                ]
                [ Html.text "You can help support the project by subscribing to the"
                , Html.a
                    [ Attributes.class "inline-flex items-center underline fancy-text"
                    , Attributes.href "https://www.youtube.com/@ElmForReactDevs"
                    , Attributes.target "_blank"
                    ]
                    [ Html.img
                        [ Attributes.class "inline-block w-4 mx-1"
                        , Attributes.src "youtube.png"
                        ]
                        []
                    , Html.text "YouTube Channel."
                    ]
                ]
            , Html.p [] [ Html.text "Not just Elm!" ]
            , Html.hr
                [ Attributes.class "py-6 my-4"
                ]
                []
            , Html.p
                [ Attributes.class "mb-2"
                ]
                [ Html.text "Here I will share the tools and techniques I've acquired over the years working with Elm at various startups across industries from HealthTech saving lives to music and live streaming, and more." ]
            ]
        , Html.section
            [ Attributes.class "flex flex-col justify-center py-12 my-8"
            , Attributes.style "min-height" "50vh"
            ]
            [ Html.p
                [ Attributes.class "mb-4 md:w-1/2"
                ]
                [ Html.text "Coming to Elm some things I've encountered during trainings that might be hard to grasp at first like routing, recursion, pattern matching, and fancy terms like \"functor\". They're not as common in the JavaScript ecosystem." ]
            , Html.p
                [ Attributes.class "mb-2 ml-4 italic"
                ]
                [ Html.text "\"What the heck is a Msg?\"" ]
            , Html.p
                [ Attributes.class "mb-4 ml-4 italic"
                ]
                [ Html.text "\"What's a functor?\"" ]
            , Html.p
                [ Attributes.class "mb-6 ml-4 italic"
                ]
                [ Html.text "\"What is point-free style?\"" ]
            , Html.p
                [ Attributes.class "mb-2 ml-4 italic"
                ]
                [ Html.text "\"How do you make reusable components?\"" ]
            , Html.p
                [ Attributes.class "mb-4 ml-4 italic"
                ]
                [ Html.text "\"What do you mean we don't use components?\"" ]
            , Html.p
                [ Attributes.class "mb-6 ml-4 italic"
                ]
                [ Html.text "\"How do I use this JavaScript library with Elm?\"" ]
            , Html.p
                [ Attributes.class "mb-2 ml-4 italic"
                ]
                [ Html.text "\"How do you do multipage routing?\"" ]
            , Html.p
                [ Attributes.class "mb-4 ml-4 italic"
                ]
                [ Html.text "\"How does ajax and fetch() work in Elm?\"" ]
            ]
        , Html.section [ Attributes.class "mx-auto my-12 mb-24 md:w-3/5" ]
            [ Html.p [] [ Html.text "Elm is very idiomatic and pattern heavy." ]
            , Html.p [] [ Html.text "So once you learn some of these patterns and practices, you can apply them across your career." ]
            , Html.p [] [ Html.text "I'm here to help you ", Html.span [ Attributes.class "italic" ] [ Html.text "bridge the gap." ] ]
            , Html.p [ Attributes.class "my-2 fancy-text" ] [ Html.text "You've been using functors this whole time!" ]
            , Html.p []
                [ Html.small []
                    [ Html.text "I'm not saying \"Functional Programming will make you a better programmer\", but I'm not not saying it either. ;)"
                    ]
                ]
            ]
        , Html.section
            [ Attributes.class "my-12"
            ]
            [ Html.div
                [ Attributes.class "flex flex-col items-center justify-around mb-8 md:flex-row"
                ]
                [ Html.div
                    [ Attributes.class "my-8"
                    ]
                    [ Html.img
                        [ Attributes.class "block mx-auto md:w-72"
                        , Attributes.src "/me/teaching.JPG"
                        , Attributes.alt "teaching react"
                        ]
                        []
                    , Html.caption
                        [ Attributes.class "block mx-auto mt-2 text-sm monospace md:w-48"
                        ]
                        [ Html.text "Teaching React.js since 2016 at the UCF Coding Bootcamp."
                        ]
                    ]
                , Html.div
                    [ Attributes.class "my-8 md:w-1/3 leading-6"
                    ]
                    [ Html.p [] [ Html.text "Hi I'm Dwight" ]
                    , Html.p []
                        [ Html.text "I love "
                        , Html.span
                            [ Attributes.class "fancy-text"
                            ]
                            [ Html.text "Functional Programming." ]
                        ]
                    , Html.p
                        [ Attributes.class "my-1"
                        ]
                        [ Html.text "I've been making web applications for nearly a decade, and FP makes the process of building robust and reliable applications easier." ]
                    , Html.p
                        [ Attributes.class "block mt-2 monospace"
                        ]
                        [ Html.text "Functional programming is "
                        , Html.span
                            [ Attributes.class "fancy-text"
                            ]
                            [ Html.text "fun!" ]
                        ]
                    , Html.p
                        [ Attributes.class "my-4 text-lg"
                        ]
                        [ Html.text "You can help support the project by becoming a "
                        , Html.a
                            [ Attributes.class "underline fancy-text"
                            , Attributes.href "https://www.patreon.com/ElmForReactDevs"
                            , Attributes.target "_blank"
                            ]
                            [ Html.text "Patron." ]
                        ]
                    , Html.p
                        [ Attributes.class "my-4 text-lg"
                        ]
                        [ Html.text "As well as by subscribing on "
                        , Html.a
                            [ Attributes.class "underline fancy-text"
                            , Attributes.href "https://www.youtube.com/@ElmForReactDevs"
                            , Attributes.target "_blank"
                            ]
                            [ Html.text "YouTube." ]
                        ]
                    ]
                , Html.div []
                    [ Html.img
                        [ Attributes.class "block w-full mx-auto md:w-64"
                        , Attributes.src "/me/profile.jpg"
                        ]
                        []
                    , Html.p
                        [ Attributes.class "block mx-auto mt-2 text-sm monospace md:w-52"
                        ]
                        [ Html.text "I'd love to help you on your "
                        , Html.span
                            [ Attributes.class "fancy-text"
                            ]
                            [ Html.text "functional journey!" ]
                        ]
                    ]
                ]
            ]
        ]
    }


viewPatreonLink : Maybe String -> Html.Html msg
viewPatreonLink maybeText =
    Html.a
        [ Attributes.class "inline-flex items-center underline fancy-text"
        , Attributes.href "https://www.patreon.com/ElmForReactDevs"
        , Attributes.target "_blank"
        ]
        [ Html.img
            [ Attributes.class "inline-block w-4 ml-1 mr-2"
            , Attributes.src "patreon.png"
            ]
            []
        , maybeText
            |> Maybe.withDefault "Patreon."
            |> Html.text
        ]
