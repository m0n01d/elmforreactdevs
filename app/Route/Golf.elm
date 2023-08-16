module Route.Golf exposing (Model, Msg, RouteParams, route, Data, ActionData)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

import Angle
import Axis2d
import BackendTask
import Browser.Events as BrowserEvents
import Circle2d
import Direction2d
import Effect
import EllipticalArc2d
import ErrorPage
import FatalError
import Frame2d
import Geometry.Svg as Geometry
import Head
import Html
import Html.Attributes exposing (start)
import Html.Events as Events
import Html.Extra as Html
import Json.Decode as Decode
import LanguageTag.Country exposing (n_145)
import Length exposing (Meters)
import LineSegment2d
import PagesMsg
import Pixels
import Point2d exposing (Point2d)
import Polygon2d
import Polyline2d
import QuadraticSpline2d
import Quantity
import Random
import RouteBuilder
import Server.Request
import Server.Response
import Shared
import Simplex exposing (PermutationTable)
import Svg
import Svg.Attributes as SvgAttributes
import Svg.Events as SvgEvents
import SweptAngle
import UrlPath
import Vector2d exposing (Vector2d)
import View


type Coordinates
    = Coordinates


type alias Point =
    Point2d Meters Coordinates


type Swing
    = NotTouching
    | StartedSwing { start : Point }
    | Drawing { start : Point, end : Point }
    | InFlight


type alias Model =
    { randomPoints : List ( Point, Point )
    , swing : Swing
    , ball : Ball
    }


type alias Ball =
    { point : Point }


type Msg
    = NoOp
    | GotPoints (List Float)
    | StartedClick Point
    | TouchDragged Point Point
    | Swung


type alias RouteParams =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single { data = data, head = head }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


ysGen : Random.Generator (List Float)
ysGen =
    Random.list 10 (Random.float 0 30)


init :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect.Effect Msg )
init app shared =
    ( { randomPoints = []
      , ball = { point = ballStartPoint }
      , swing = NotTouching
      }
    , Effect.fromCmd <|
        Random.generate GotPoints ysGen
    )


chunks : Float
chunks =
    sceneX / 10


exes : List Float
exes =
    List.range 1 10
        |> List.map (Basics.toFloat >> (*) chunks)


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update app shared msg model =
    case Debug.log "debug msg" msg of
        GotPoints whys ->
            let
                points =
                    toPoints exes whys
                        |> List.map
                            (\( s, e ) ->
                                ( Point2d.fromTuple Length.meters s
                                , Point2d.fromTuple Length.meters e
                                )
                            )
            in
            ( { model | randomPoints = points }
            , Effect.none
            )

        StartedClick start ->
            ( { model
                | swing = StartedSwing { start = start }
              }
            , Effect.none
            )

        TouchDragged start end ->
            ( { model | swing = Drawing { start = start, end = end } }
            , Effect.none
            )

        Swung ->
            ( { model | swing = NotTouching }
            , Effect.none
            )

        NoOp ->
            ( model, Effect.none )


toPoints : List Float -> List Float -> List ( ( Float, Float ), ( Float, Float ) )
toPoints xs ys =
    case ( xs, ys ) of
        ( lastX :: [], lastY :: [] ) ->
            [ ( ( lastX, lastY ), ( Basics.toFloat sceneX, 0.0 ) ) ]

        ( x1 :: x2 :: restX, y1 :: y2 :: restY ) ->
            ( ( x1, y1 ), ( x2, y2 ) ) :: toPoints (x2 :: restX) (y2 :: restY)

        ( _, _ ) ->
            []


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions routeParams path shared model =
    [ [ BrowserEvents.onMouseUp (Decode.succeed Swung) ]
    , case model.swing of
        NotTouching ->
            []

        StartedSwing touch ->
            [ BrowserEvents.onMouseMove (Decode.map (TouchDragged touch.start) decodeStart)
            ]

        Drawing { start } ->
            [ BrowserEvents.onMouseMove (Decode.map (TouchDragged start) decodeStart)
            ]

        InFlight ->
            []
    ]
        |> List.concat
        |> Sub.batch


type alias Data =
    {}


type alias ActionData =
    {}


data =
    BackendTask.succeed {}


head app =
    []



-- Constants


sceneX : number
sceneX =
    1024


sceneY : number
sceneY =
    768


topLeftFrame : Frame2d.Frame2d Pixels.Pixels coordinates defines2
topLeftFrame =
    Frame2d.atPoint (Point2d.pixels 0 sceneY)
        |> Frame2d.reverseY



-- Views


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
    { title = "Golf"
    , body =
        [ Html.div []
            [ viewScene model
            ]
        ]
    }



--loggingDecoder : Decoder a -> Decoder a


loggingDecoder realDecoder =
    Decode.value
        |> Decode.andThen
            (\event ->
                case Decode.decodeValue realDecoder event of
                    Ok decoded ->
                        Decode.succeed decoded

                    Err error ->
                        error
                            |> Decode.errorToString
                            |> Debug.log "decoding error"
                            |> Decode.fail
            )


decodeStart =
    Decode.map2 Tuple.pair
        (Decode.at [ "offsetX" ] Decode.float)
        (Decode.map ((-) sceneY) (Decode.at [ "offsetY" ] Decode.float))
        |> Decode.map (Point2d.fromTuple Length.meters)


viewScene { ball, swing, randomPoints } =
    Svg.svg
        [ SvgAttributes.viewBox <|
            String.concat
                [ "0 0 "
                , String.fromInt sceneX
                , " "
                , String.fromInt sceneY
                ]
        , SvgAttributes.width <| String.fromInt sceneX
        , SvgAttributes.height <| String.fromInt sceneY
        , SvgEvents.on "mousedown"
            (loggingDecoder decodeStart
                |> Decode.map (\start -> PagesMsg.fromMsg <| StartedClick start)
            )
        ]
        [ Geometry.relativeTo topLeftFrame <|
            Svg.svg []
                [ viewBall ballStartPoint
                , viewTrajectory ball swing
                , viewGround randomPoints
                , viewSwing swing
                ]
        ]


viewSwing touch =
    case touch of
        NotTouching ->
            Html.text "not"

        StartedSwing { start } ->
            viewBall start

        Drawing { start, end } ->
            Svg.g []
                [ viewBall start
                , viewBall end
                , Geometry.lineSegment2d
                    [ SvgAttributes.strokeWidth "1"
                    , SvgAttributes.stroke "red"
                    ]
                    (LineSegment2d.from start end)
                ]

        InFlight ->
            Svg.g [] []


viewTrajectory : Ball -> Swing -> Svg.Svg msg
viewTrajectory ball swing =
    case swing of
        Drawing { start, end } ->
            let
                swingVector =
                    Vector2d.from start end
                        |> Vector2d.half

                ball_ =
                    Point2d.unwrap ball.point

                vector =
                    Vector2d.meters ball_.x ball_.y
                        |> Vector2d.plus swingVector

                start_ =
                    Point2d.unwrap start

                end_ =
                    Point2d.unwrap end

                firstAngle =
                    Basics.atan2 start_.y start_.x

                secondAngle =
                    Basics.atan2 0 0

                angleRadians =
                    Debug.log "radians" <|
                        Basics.atan2 (start_.y - end_.y) (start_.x - end_.x)

                angle =
                    angleRadians
                        |> (\n -> n * 180 / Basics.pi)
                        |> Debug.log "angle"

                { x, y, theta } =
                    calculateTrajectory vector angle
            in
            Svg.path
                [ SvgAttributes.d <|
                    String.concat
                        [ "M 0 0 C 0 0, "
                        , String.fromFloat (x / 2)
                        , " "
                        , String.fromFloat (y * 2)
                        , " "
                        , String.fromFloat x
                        , " 0"
                        ]
                , SvgAttributes.fill "none"
                , SvgAttributes.strokeWidth "1"
                , SvgAttributes.stroke "red"
                ]
                []

        _ ->
            Svg.g [] []


startPoint : Point2d Meters Coordinates
startPoint =
    Point2d.fromTuple Length.meters ( 0, 0 )


startPos : List (Point2d Meters Coordinates)
startPos =
    [ startPoint ]


ballStartPoint : Point2d Meters Coordinates
ballStartPoint =
    Point2d.meters 10 10


viewBall : Point2d Meters coordinates -> Svg.Svg msg
viewBall point =
    Geometry.circle2d
        [ SvgAttributes.fill "white", SvgAttributes.stroke "black", SvgAttributes.strokeWidth "2" ]
        (Circle2d.withRadius (Length.meters 5) point)


viewGround : List ( Point, Point ) -> Html.Html msg
viewGround points =
    let
        grass : List Point
        grass =
            points
                |> List.concatMap
                    (\( start, end ) ->
                        [ start, end ]
                    )
    in
    [ startPos
    , grass
    ]
        |> List.concat
        |> Polygon2d.singleLoop
        |> Geometry.polygon2d
            [ SvgAttributes.stroke "green"
            , SvgAttributes.fill "none"
            ]
        |> List.singleton
        |> Svg.svg
            []


action :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action routeParams request =
    BackendTask.succeed (Server.Response.render {})



-- Maths


g =
    9.807



-- meters per second squared ??
-- velocity, angle, height


initialVelocity : Float -> Float -> ( Float, Float )
initialVelocity u angle =
    ( u * Basics.cos angle
    , u * Basics.sin angle
    )


time : Float -> Float -> Float
time u angle =
    let
        ( _, uy ) =
            initialVelocity u angle

        h =
            10
    in
    (uy + Basics.sqrt ((uy ^ 2) + (2 * g * h))) / g


range u angle =
    let
        ( ux, uy ) =
            initialVelocity u angle

        t =
            time u angle
    in
    ux * t


calculateTrajectory : Vector2d Meters Coordinates -> Float -> { x : Float, y : Float, theta : Float }
calculateTrajectory vector angle =
    let
        u : Float
        u =
            Vector2d.length vector
                |> Length.inMeters

        time_ =
            time u angle_

        angle_ =
            angle * Basics.pi / 180

        x =
            u
                * Basics.cos angle_
                * time_

        y =
            u * Basics.sin angle_ * time_ - (g * time_ * time_) / 2.0

        t =
            time_ / 2

        y_ =
            u
                * Basics.sin angle_
                * t
                - (g * t * t)
                / 2.0

        vx =
            u
                * Basics.cos angle_

        vy =
            u
                * Basics.sin angle_
                - g
                * time_

        v =
            Basics.sqrt (vx * vx + vy * vy)

        theta =
            Basics.atan (vy / vx) * 180.0 / Basics.pi
    in
    { x = x
    , y = ballStartPoint |> Point2d.unwrap |> .y |> (+) y_
    , theta = theta
    }
