module Route.Blog.Slug_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import BackendTask.File
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attributes
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as Decode
import Markdown.Block
import Markdown.Parser
import Markdown.Renderer
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { slug : String }


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


pages : BackendTask FatalError (List RouteParams)
pages =
    BackendTask.succeed
        [ { slug = "understanding_map" }
        ]


type alias Data =
    { post : BlogPostMetadata
    }


type alias BlogPostMetadata =
    { body : List Markdown.Block.Block
    , title : String
    , tags : List String
    }


type alias ActionData =
    {}


data : { a | slug : String } -> BackendTask FatalError Data
data routeParams =
    [ "./posts", "/", routeParams.slug, ".md" ]
        |> String.concat
        |> blogPost
        |> BackendTask.allowFatal
        |> BackendTask.map Data



--blogPost : BackendTask FatalError BlogPostMetadata


blogPost =
    BackendTask.File.bodyWithFrontmatter blogPostDecoder


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "ElmForReactDevs"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "ElmForReactDevs logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "ElmForReactDevs blog post"
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app sharedModel =
    { title = app.data.post.title
    , body =
        renderMd app.data.post.body
            |> Result.withDefault [ Html.text "bad" ]
            |> Html.div [ Attributes.attribute "view-name" "Blog.view" ]
            |> List.singleton
    }


renderMd : List Markdown.Block.Block -> Result String (List (Html msg))
renderMd =
    \blocks ->
        Markdown.Renderer.render
            Markdown.Renderer.defaultHtmlRenderer
            blocks


markdownToView : String -> Decoder (List Markdown.Block.Block)
markdownToView markdownString =
    markdownString
        |> Markdown.Parser.parse
        |> Result.mapError (\_ -> "Markdown error.")
        |> Decode.fromResult


blogPostDecoder =
    \mdString ->
        Decode.map2
            (\title renderedMd ->
                { body = renderedMd
                , tags = []
                , title = title
                }
            )
            (Decode.field "title" Decode.string)
            (mdString |> markdownToView)


tagsDecoder : Decoder (List String)
tagsDecoder =
    Decode.map (String.split " ")
        Decode.string
