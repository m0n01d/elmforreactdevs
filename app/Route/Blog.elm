module Route.Blog exposing (ActionData, Data, Model, Msg, RouteParams, action, data, route)

import BackendTask exposing (BackendTask)
import BackendTask.Custom
import BackendTask.Http
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
    { posts : List String
    }


type alias ActionData =
    {}


data : BackendTask FatalError Data
data =
    BackendTask.succeed Data
        |> BackendTask.andMap
            (BackendTask.Custom.run "blogPosts"
                Encode.null
                (Decode.list Decode.string)
                |> BackendTask.allowFatal
            )


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
    Html.section []
        [ Html.h2
            [ Attributes.class "fancy-text"
            ]
            [ Html.text "Posts"
            ]
        , viewBlogPosts app.data.posts
        ]


viewBlogPosts posts =
    posts
        |> List.map viewBlogPost
        |> Html.div []


viewBlogPost post =
    Html.div []
        [ Route.Blog__Slug_ { slug = String.replace ".md" "" post }
            |> Route.link []
                [ Html.text
                    post
                ]
        ]


action :
    RouteParams
    -> Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action routeParams request =
    BackendTask.succeed (Server.Response.render {})
