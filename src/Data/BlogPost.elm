module Data.BlogPost exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as Decode
import Markdown.Block
import Markdown.Parser
import Markdown.Renderer


type alias BlogPost =
    { body : List Markdown.Block.Block
    , date : String
    , name : String
    , tags : List String
    , title : String
    }


decoder : String -> Decoder BlogPost
decoder =
    \mdString ->
        Decode.map4
            (\date name title body ->
                { body = body
                , date = date
                , name = name
                , tags = []
                , title = title
                }
            )
            (Decode.field "date" Decode.string)
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
