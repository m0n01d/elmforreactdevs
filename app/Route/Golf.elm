module Route.Golf exposing (Model, Msg, RouteParams, route, Data, ActionData)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

import BackendTask
import Effect
import ErrorPage
import FatalError
import Geometry.Svg as Geometry
import Head
import Html
import LineSegment2d
import PagesMsg
import Pixels
import Point2d
import Random
import RouteBuilder
import Server.Request
import Server.Response
import Shared
import Simplex exposing (PermutationTable)
import Svg
import Svg.Attributes as SvgAttributes
import UrlPath
import View


type alias Model =
    { randomPoints : List ( Point, Point )
    }


type alias Point =
    ( Float, Float )


type Msg
    = NoOp
    | GotPoints (List Float)


type alias RouteParams =
    {}


route =
    RouteBuilder.single { data = data, head = head }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


ysGen =
    Random.list 10 (Random.float 0 50)


init :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect.Effect Msg )
init app shared =
    ( { randomPoints = [] }
    , Effect.fromCmd <|
        Random.generate GotPoints ysGen
    )


chunks =
    1024 / 10


exes =
    List.range 0 9
        |> List.map (Basics.toFloat >> (*) chunks)


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update app shared msg model =
    case msg of
        GotPoints whys ->
            let
                points =
                    toPoints exes whys
            in
            ( { model | randomPoints = points }
            , Effect.none
            )

        NoOp ->
            ( model, Effect.none )


toPoints : List Float -> List Float -> List ( Point, Point )
toPoints xs ys =
    case ( xs, ys ) of
        ( lastX :: [], lastY :: [] ) ->
            ( ( lastX, lastY ), ( 1024, 0 ) ) :: []

        ( x1 :: x2 :: restX, y1 :: y2 :: restY ) ->
            ( ( x1, y1 ), ( x2, y2 ) ) :: toPoints (x2 :: restX) (y2 :: restY)

        ( _, _ ) ->
            []


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions routeParams path shared model =
    Sub.none


type alias Data =
    {}


type alias ActionData =
    {}


data =
    BackendTask.succeed {}


head app =
    []


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
    { title = "Golf", body = [ viewScene model.randomPoints ] }


viewScene randomYs =
    Svg.svg
        [ SvgAttributes.viewBox "0 0 1024 768"
        ]
        [ viewGround randomYs ]



--Create a permutation table, using 42 as the seed


permTable : PermutationTable
permTable =
    Simplex.permutationTableFromInt 42


noise x y =
    Simplex.noise2d permTable x y
        |> (*) 10


viewGround points =
    points
        |> List.map
            (\( ( x1, y1 ), ( x2, y2 ) ) ->
                LineSegment2d.from (Point2d.pixels x1 y1) (Point2d.pixels x2 y2)
                    |> Geometry.lineSegment2d
                        [ SvgAttributes.stroke "green"
                        , SvgAttributes.strokeWidth "5"
                        ]
            )
        |> Svg.svg
            [ SvgAttributes.y "700"
            ]


action :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action routeParams request =
    BackendTask.succeed (Server.Response.render {})

