module Route.Blog.Slug_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import BackendTask.File
import Data.BlogPost as BlogPost exposing (BlogPost)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Attributes.Extra as Attributes
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as Decode
import Markdown.Block
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import UrlPath exposing (UrlPath)
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
    { post : BlogPost
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


blogPost : String -> BackendTask { fatal : FatalError, recoverable : BackendTask.File.FileReadError Decode.Error } BlogPost
blogPost =
    BackendTask.File.bodyWithFrontmatter BlogPost.decoder


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
        , description = [ app.data.post.title, "ElmForReactDevs" ] |> String.join " - "
        , locale = Nothing
        , title = app.data.post.title
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
            |> Html.node "ui-prism" [ Attributes.attribute "view-name" "Blog.view" ]
            |> List.singleton
    }


renderMd : List Markdown.Block.Block -> Result String (List (Html msg))
renderMd =
    \blocks ->
        Markdown.Renderer.render
            Markdown.Renderer.defaultHtmlRenderer
            blocks
