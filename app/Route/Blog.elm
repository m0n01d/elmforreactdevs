module Route.Blog exposing (ActionData, Data, Model, Msg, RouteParams, action, data, route)

import BackendTask exposing (BackendTask)
import BackendTask.Custom
import BackendTask.File
import BackendTask.Http
import Data.BlogPost as BlogPost exposing (BlogPost)
import Effect exposing (Effect)
import ErrorPage exposing (ErrorPage)
import FatalError exposing (FatalError)
import Head
import Html
import Html.Attributes as Attributes
import Json.Decode as Decode
import Json.Encode as Encode
import PagesMsg exposing (PagesMsg)
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Server.Request exposing (Request)
import Server.Response
import Shared
import String.Extra as String
import UrlPath exposing (UrlPath)
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


init :
    App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect Msg )
init app shared =
    ( {}, Effect.none )


subscriptions :
    RouteParams
    -> UrlPath
    -> Shared.Model
    -> Model
    -> Sub Msg
subscriptions routeParams path shared model =
    Sub.none


type alias Data =
    { posts : List BlogPost
    }


type alias ActionData =
    {}


data : BackendTask FatalError Data
data =
    (BackendTask.Custom.run "blogPosts"
        Encode.null
        (Decode.list Decode.string)
        |> BackendTask.allowFatal
    )
        |> BackendTask.map
            (\files ->
                files
                    |> Debug.log "files"
                    |> List.filter (String.contains ".md")
                    |> Debug.log "filtered files"
                    |> List.map
                        (\file ->
                            [ "./posts/", file ]
                                |> String.concat
                                |> BackendTask.File.bodyWithFrontmatter BlogPost.decoder
                                |> BackendTask.allowFatal
                        )
            )
        |> BackendTask.andThen BackendTask.combine
        |> BackendTask.map Data


x =
    Decode.list (Decode.string |> Decode.andThen BlogPost.decoder)


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app shared =
    { title = "Blog Archive", body = [ viewContent app ] }


viewContent app =
    Html.section
        [ Attributes.class "px-4 py-3 border rounded shadow-xl md:w-5/6 "
        ]
        [ Html.div []
            [ Html.button
                [ Attributes.class "mr-2"
                ]
                [ Html.text "<"
                ]
            , Html.text ">"
            , Html.span [ Attributes.class "ml-2" ] [ Html.text "Posts" ]
            ]
        , Html.h2
            [ Attributes.class "text-sm text-center fancy-text"
            ]
            [ Html.text "Posts"
            ]
        , viewBlogPosts app.data.posts
        ]


viewBlogPosts posts =
    Html.div
        [ Attributes.class ""
        ]
        [ [ "Name", "Date Modified", "Size", "Kind" ]
            |> List.indexedMap
                (\i col ->
                    Html.button
                        [ Attributes.class "flex items-center flex-1 px-3 text-left"
                        ]
                        [ Html.text col
                        , Html.span
                            [ Attributes.classList
                                [ ( "hidden", i /= 1 )
                                , ( "ml-auto", True )
                                ]
                            ]
                            [ Html.text "^"
                            ]
                        ]
                )
            |> Html.div [ Attributes.class "flex items-center my-4 text-sm divide-x" ]
        , posts
            |> List.map viewBlogPost
            |> Html.div []
        ]


viewBlogPost post =
    Html.div [ Attributes.class "flex items-center justify-between" ]
        [ Route.Blog__Slug_ { slug = String.replace ".md" "" post.name }
            |> Route.link [ Attributes.class "flex-1 px-3 " ]
                [ Html.text post.name
                ]
        , Html.time [ Attributes.class "flex-1 px-3 " ] [ Html.text post.date ]
        , Html.span [ Attributes.class "flex-1 px-3 " ] [ Html.text "420kb" ]
        , Html.span [ Attributes.class "flex-1 px-3 " ] [ Html.text "Markdown Text" ]
        ]


action :
    RouteParams
    -> Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action routeParams request =
    BackendTask.succeed (Server.Response.render {})
