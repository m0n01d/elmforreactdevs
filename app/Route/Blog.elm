module Route.Blog exposing (ActionData, Data, Model, Msg, RouteParams, action, data, route)

import BackendTask exposing (BackendTask)
import BackendTask.Custom
import BackendTask.File as File
import BackendTask.Http
import Data.BlogPost as BlogPost exposing (BlogPost, BlogPostMeta)
import Date
import Dict exposing (Dict)
import Effect exposing (Effect)
import ErrorPage exposing (ErrorPage)
import FatalError exposing (FatalError)
import Filesize
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
    { postsMeta : Dict String BlogPostMeta
    , posts : List BlogPost
    }


type alias ActionData =
    {}


dataPostsMeta : BackendTask FatalError (Dict String BlogPostMeta)
dataPostsMeta =
    let
        decodeHelp =
            Decode.list
                (Decode.map2 Tuple.pair
                    (Decode.field "file" Decode.string)
                    (Decode.field "stats" BlogPost.decodeBlogPostMeta)
                )
                |> Decode.map Dict.fromList
    in
    BackendTask.Custom.run "blogPostsMeta"
        Encode.null
        decodeHelp
        |> BackendTask.allowFatal


dataPosts =
    BlogPost.glob
        |> BackendTask.map
            (\blogPosts ->
                blogPosts
                    |> List.map
                        (\{ filePath, slug } ->
                            File.bodyWithFrontmatter BlogPost.decoder filePath
                        )
            )
        |> BackendTask.resolve
        |> BackendTask.allowFatal


data =
    BackendTask.map2 Data
        dataPostsMeta
        dataPosts


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
        , viewBlogPosts app.data
        ]


viewBlogPosts : Data -> Html.Html msg
viewBlogPosts { posts, postsMeta } =
    Html.div
        [ Attributes.class ""
        ]
        [ [ "Name", "Date Modified", "Size", "Kind" ]
            |> List.indexedMap
                (\i col ->
                    Html.button
                        [ Attributes.classList
                            [ ( "text-slate-800 flex items-center flex-1 px-3 text-left", True )
                            , ( "text-black font-semibold", i == 1 )
                            ]
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
            |> List.map (viewBlogPost postsMeta)
            |> Html.div []
        ]


viewBlogPost postsMeta post =
    let
        viewMeta_ =
            \meta ->
                [ Html.time [ Attributes.class "flex-1 px-3 " ] [ Html.text <| Date.format "YYYY-dd-MM" meta.modifiedDate ]
                , Html.span [ Attributes.class "flex-1 px-3 " ] [ Html.text <| Filesize.format meta.size ]
                , Html.span [ Attributes.class "flex-1 px-3 " ] [ Html.text "Markdown Text" ]
                ]

        viewMeta =
            postsMeta
                |> Dict.get post.name
                |> Maybe.map viewMeta_
                |> Maybe.withDefault []
    in
    [ [ Route.Blog__Slug_ { slug = String.replace ".md" "" post.name }
            |> Route.link [ Attributes.class "flex-1 px-3 " ]
                [ Html.text post.name
                ]
      ]
    , viewMeta
    ]
        |> List.concat
        |> Html.div
            [ Attributes.class "flex items-center justify-between" ]


action :
    RouteParams
    -> Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action routeParams request =
    BackendTask.succeed (Server.Response.render {})
