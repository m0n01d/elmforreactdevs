module Data.BlogPost exposing (..)

import BackendTask exposing (BackendTask)
import BackendTask.Glob as Glob
import Date exposing (Date)
import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as Decode
import Markdown.Block
import Markdown.Parser
import Markdown.Renderer
import Time


type alias BlogPost =
    { body : List Markdown.Block.Block
    , name : String
    , tags : List String
    , title : String
    }


decoder : String -> Decoder BlogPost
decoder =
    \mdString ->
        Decode.map3
            (\name title body ->
                { body = body
                , name = name
                , tags = []
                , title = title
                }
            )
            (Decode.field "name" Decode.string)
            (Decode.field "title" Decode.string)
            (mdString |> decodeBody)


decodeBody : String -> Decoder (List Markdown.Block.Block)
decodeBody markdownString =
    markdownString
        |> Markdown.Parser.parse
        |> Result.mapError (\_ -> "Markdown error.")
        |> Decode.fromResult


decodeTags : Decoder (List String)
decodeTags =
    Decode.map (String.split " ")
        Decode.string


type alias BlogPostMeta =
    { modifiedDate : Date
    , size : Int
    }


decodeDate =
    Iso8601.decoder
        |> Decode.map
            (\posix ->
                Date.fromPosix Time.utc posix
            )


decodeBlogPostMeta =
    Decode.map2 BlogPostMeta
        (Decode.field "xmtime" decodeDate)
        (Decode.field "size" Decode.int)


type alias Glob =
    { filePath : String
    , slug : String
    }


glob : BackendTask.BackendTask error (List { filePath : String, slug : String })
glob =
    Glob.succeed Glob
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "posts/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toBackendTask
