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
        , siteName = "elm-pages"
        , image =
            { url = [ "images", "icon-png.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Welcome to elm-pages!"
        , locale = Nothing
        , title = "elm-pages is running"
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
            [ Attributes.class "py-3 text-center md:py-12 md:px-16 xl:px-36"
            ]
            [ Html.h1
                [ Attributes.class "fancy-text" ]
                [ Html.text "Welcome to ElmForReactDevs" ]
            , Html.div
                [ Attributes.class "flex flex-col mt-16 md:flex-row"
                ]
                [ Html.div
                    [ Attributes.class "flex-1"
                    ]
                    [ Html.h2
                        [ Attributes.class "my-8 text-xl font-bold md:text-3xl fancy-text"
                        ]
                        [ Html.text "Are you a React.js developer looking to expand your skills and harness the power of Elm?" ]
                    , Html.p
                        [ Attributes.class "text-lg font-bold md:text-2xl fancy-text"
                        ]
                        [ Html.text "Look no further than ElmForReactDevs, a blog designed to help React.js developers seamlessly transition into the world of static types!" ]
                    ]
                , Html.div
                    [ Attributes.class "flex-1"
                    ]
                    [ Html.img
                        [ Attributes.class "block mx-auto my-12"
                        , Attributes.src "/public/384.jpeg"
                        ]
                        []
                    , Html.caption
                        [ Attributes.class "block text-center"
                        ]
                        [ Html.text "Pretend thats ^ a video" ]
                    ]
                ]
            ]
        , Html.section
            [ Attributes.class "my-8 leading-7"
            ]
            [ Html.p [] [ Html.text "Starting in 2017, I experienced first hand the journey of switching from React development to ", Html.span [ Attributes.class "monospace" ] [ Html.text "Elm fulltime." ] ]
            , Html.p [] [ Html.text "And it ", Html.span [ Attributes.class "fancy-text " ] [ Html.text "completely changed" ], Html.text " the way I think about programming." ]
            ]
        , Html.section
            [ Attributes.class "flex flex-col justify-center my-12 md:w-1/2 leading-7"
            ]
            [ Html.div []
                [ Html.p []
                    [ Html.text "Most recently i was challenged with hiring Elm engineers to help rewrite a React app in Elm."
                    ]
                , Html.p
                    [ Attributes.class "my-2"
                    ]
                    [ Html.text "I want to help more React developers better understand elm and static typed purely functional languages." ]
                , Html.p []
                    [ Html.text "I saw "
                    , Html.span
                        [ Attributes.class "fancy-text"
                        ]
                        [ Html.text "again and again" ]
                    , Html.text " some of the same stumbling blocks and "
                    , Html.span [ Attributes.class "monospace" ] [ Html.text "lightbulb moments 💡" ]
                    ]
                , Html.p [] [ Html.text "Those of which I hope to cover here in a series of articles and videos." ]
                ]
            ]
        , Html.section []
            [ Html.div
                [ Attributes.class "flex flex-col items-center justify-around mb-8 md:flex-row"
                ]
                [ Html.div
                    [ Attributes.class "my-8"
                    ]
                    [ Html.img
                        [ Attributes.class "block mx-auto md:w-72"
                        , Attributes.src "/public/me/teaching.jpg"
                        , Attributes.alt "teaching react"
                        ]
                        []
                    , Html.caption
                        [ Attributes.class "block pl-4 text-sm monospace md:w-96"
                        ]
                        [ Html.text "My first experience teaching was working at the UCF Coding Bootcamp in 2016 teaching React and JavaScript."
                        ]
                    ]
                ]
            ]
        , Html.section
            [ Attributes.class "flex flex-col justify-center mx-auto my-12 md:w-3/5 leading-7"
            ]
            [ Html.p []
                [ Html.span [ Attributes.class "fancy-text" ] [ Html.text "ElmForReactDevs" ]
                , Html.text " is here to help other JavaScript and React developers get up to speed on Elm."
                ]
            , Html.p []
                [ Html.text "And along the way learn "
                , Html.span [ Attributes.class "monospace" ] [ Html.text "functional programming concepts and patterns" ]
                ]
            , Html.p
                [ Attributes.class "mt-12 mb-4 text-lg"
                ]
                [ Html.text "In my experience, there are "
                , Html.span
                    [ Attributes.class "fancy-text"
                    ]
                    [ Html.text "3 pillars to Elm mastery:" ]
                ]
            , Html.ul
                [ Attributes.class "list-decimal "
                ]
                [ Html.li
                    [ Attributes.class "mb-4"
                    ]
                    [ Html.p
                        [ Attributes.class "fancy-text"
                        ]
                        [ Html.text "Basics Syntax - " ]
                    , Html.text "Understanding type signatures, operators, 'let in' blocks, currying, using custom types, writing Html, structuring modules."
                    ]
                , Html.li
                    [ Attributes.class "mb-4"
                    ]
                    [ Html.p
                        [ Attributes.class "fancy-text"
                        ]
                        [ Html.text "The Elm Architecture - " ]
                    , Html.text "How "
                    , [ "Msg", "Cmd Msg", "Html Msg", "Sub Msg" ]
                        |> List.map
                            (\s -> Html.span [ Attributes.class "mr-2 monospace" ] [ Html.text <| String.concat [ "`", s, "`," ] ])
                        |> Html.span []
                    , Html.text "are all connected."
                    , Html.p []
                        [ Html.text "The Model View Update cycle, storing state, and responding to internal and external events"
                        ]
                    ]
                , Html.li
                    [ Attributes.class "mb-4"
                    ]
                    [ Html.p
                        [ Attributes.class "fancy-text"
                        ]
                        [ Html.text "The Compiler - " ]
                    , Html.text "Reading compiler errors, walking through refactors."
                    ]
                ]
            , Html.hr [ Attributes.class "my-4" ] []
            , Html.p [] [ Html.text "Here I will share the tools and techniques I've acquired over the years working with Elm at various startups across industries from HealthTech saving lives to music and live streaming, and more." ]
            , Html.p [] [ Html.text "Hopefully this content helps you start to think in Elm and you can begin to use it in your personal and professional lives" ]
            ]
        , Html.section
            [ Attributes.class "my-8 md:w-4/5 leading-7"
            ]
            [ Html.div
                [ Attributes.class "flex flex-col items-center my-12 md:flex-row"
                ]
                [ Html.div []
                    [ Html.p [] [ Html.text "By nature Elm is very different from React." ]
                    , Html.p [] [ Html.text "But some things are also very similar." ]
                    , Html.p [] [ Html.text "In the end they're both JavaScript frontends for building web applications." ]
                    , Html.p [] [ Html.text "And both are great at creating declarative UI's" ]
                    , Html.p
                        [ Attributes.class "mt-4 md:w-2/3"
                        ]
                        [ Html.text "Paired with Redux, there are even more parallels like: unidirectional data flow, data normalization and centralized state" ]
                    ]
                , Html.ul
                    [ Attributes.class "flex flex-col items-center justify-center flex-1 my-4 list-disc md:pl-8"
                    ]
                    [ Html.li [] [ Html.text "Single source of truth" ], Html.li [] [ Html.text "read-only state" ], Html.li [] [ Html.text "updates from pure functions" ], Html.li [] [ Html.text "immutability" ] ]
                ]
            , Html.p []
                [ Html.text "\"React is a "
                , Html.span [ Attributes.class "fancy-text" ] [ Html.text "library.\"" ]
                , Html.text ", Elm however is not. It's a "
                , Html.span [ Attributes.class "fancy-text" ] [ Html.text "language" ]
                , Html.text " that compiles to JavaScript."
                ]
            , Html.p
                []
                [ Html.text "Thankfully it's a rather small language and you can learn the basics quickly and build robust applications with a handful of patterns" ]
            ]
        , Html.section
            [ Attributes.class "flex flex-col justify-center my-8"
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
        , Html.section [ Attributes.class "mx-auto mb-24 md:w-3/5" ]
            [ Html.p [] [ Html.text "Elm is very idiomatic and pattern heavy." ]
            , Html.p [] [ Html.text "So once you learn some of these patterns and practices you'll be well on your way to being effective." ]
            , Html.p [] [ Html.text "I'm here to help you ", Html.span [ Attributes.class "italic" ] [ Html.text "bridge the gap." ] ]
            , Html.p [ Attributes.class "my-2 fancy-text" ] [ Html.text "You've been using functors this whole time!" ]
            , Html.p []
                [ Html.small []
                    [ Html.text "I'm not saying \"Elm will make you a better programmer\", but I'm not not saying it either. ;)"
                    ]
                ]
            ]
        ]
    }
