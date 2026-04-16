module Boids exposing (..)

import Browser
import Browser.Events
import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Advanced exposing (rotate, transform, translate)
import Canvas.Settings.Line exposing (lineWidth)
import Color
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Random



-- CONFIG --


type alias Config =
    { width : Float
    , height : Float
    , numBoids : Int
    , visualRange : Float
    , minDistance : Float
    , cohesionFactor : Float
    , alignmentFactor : Float
    , separationFactor : Float
    , maxSpeed : Float
    , minSpeed : Float
    , maxForce : Float
    , boidColor : Color.Color
    , backgroundColor : Maybe Color.Color
    }


defaultConfig : Config
defaultConfig =
    { width = 400
    , height = 400
    , numBoids = 100
    , visualRange = 40
    , minDistance = 20
    , cohesionFactor = 0.005
    , alignmentFactor = 0.05
    , separationFactor = 0.05
    , maxSpeed = 3
    , minSpeed = 1.5
    , maxForce = 0.1
    , boidColor = Color.black
    , backgroundColor = Just Color.white
    }



-- VECTOR --


type alias Vector =
    { x : Float, y : Float }


add : Vector -> Vector -> Vector
add v1 v2 =
    { x = v1.x + v2.x, y = v1.y + v2.y }


sub : Vector -> Vector -> Vector
sub v1 v2 =
    { x = v1.x - v2.x, y = v1.y - v2.y }


mul : Float -> Vector -> Vector
mul s v =
    { x = v.x * s, y = v.y * s }


distSq : Vector -> Vector -> Float
distSq v1 v2 =
    (v1.x - v2.x) ^ 2 + (v1.y - v2.y) ^ 2


mag : Vector -> Float
mag v =
    sqrt (v.x ^ 2 + v.y ^ 2)


limit : Float -> Vector -> Vector
limit max v =
    let
        m =
            mag v
    in
    if m > max then
        mul (max / m) v

    else
        v



-- MODEL --


type alias Boid =
    { position : Vector
    , velocity : Vector
    }


type alias Model =
    { boids : List Boid
    , grid : Dict ( Int, Int ) (List Boid)
    , config : Config
    }


init : Config -> ( Model, Cmd Msg )
init config =
    ( { boids = [], grid = Dict.empty, config = config }
    , Random.generate InitBoids (Random.list config.numBoids (randomBoid config))
    )


randomBoid : Config -> Random.Generator Boid
randomBoid config =
    Random.map2 Boid
        (Random.map2 Vector (Random.float 0 config.width) (Random.float 0 config.height))
        (Random.map2 Vector (Random.float -2 2) (Random.float -2 2))



-- UPDATE --


type Msg
    = OnFrame Float
    | InitBoids (List Boid)
    | Resize Float Float


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitBoids boids ->
            ( { model | boids = boids, grid = buildGrid model.config boids }, Cmd.none )

        Resize width height ->
            let
                oldConfig =
                    model.config

                newConfig =
                    { oldConfig | width = width, height = height }
            in
            ( { model | config = newConfig, grid = buildGrid newConfig model.boids }, Cmd.none )

        OnFrame delta ->
            let
                -- We normalize the update based on 60fps (~16.6ms per frame)
                dt =
                    delta / 16.6

                newBoids =
                    List.map (updateBoid model.config dt model.grid) model.boids
            in
            ( { model | boids = newBoids, grid = buildGrid model.config newBoids }, Cmd.none )


buildGrid : Config -> List Boid -> Dict ( Int, Int ) (List Boid)
buildGrid config boids =
    let
        cellSize =
            config.visualRange

        toGridPos pos =
            ( floor (pos.x / cellSize), floor (pos.y / cellSize) )

        insert boid acc =
            let
                gridPos =
                    toGridPos boid.position
            in
            Dict.update gridPos
                (\maybeBoids ->
                    case maybeBoids of
                        Just bs ->
                            Just (boid :: bs)

                        Nothing ->
                            Just [ boid ]
                )
                acc
    in
    List.foldl insert Dict.empty boids


updateBoid : Config -> Float -> Dict ( Int, Int ) (List Boid) -> Boid -> Boid
updateBoid config dt grid boid =
    let
        cellSize =
            config.visualRange

        gridX =
            floor (boid.position.x / cellSize)

        gridY =
            floor (boid.position.y / cellSize)

        visualRangeSq =
            config.visualRange * config.visualRange

        minDistanceSq =
            config.minDistance * config.minDistance

        accumulateNeighbors other acc =
            if other == boid then
                acc

            else
                let
                    distanceSq =
                        distSq boid.position other.position
                in
                if distanceSq < visualRangeSq then
                    let
                        newAcc =
                            { acc
                                | count = acc.count + 1
                                , sumPos = add acc.sumPos other.position
                                , sumVel = add acc.sumVel other.velocity
                            }
                    in
                    if distanceSq < minDistanceSq then
                        { newAcc | sumSep = add newAcc.sumSep (sub boid.position other.position) }

                    else
                        newAcc

                else
                    acc

        initialAcc =
            { count = 0, sumPos = { x = 0, y = 0 }, sumVel = { x = 0, y = 0 }, sumSep = { x = 0, y = 0 } }

        checkCell ( dx, dy ) acc =
            case Dict.get ( gridX + dx, gridY + dy ) grid of
                Just bs ->
                    List.foldl accumulateNeighbors acc bs

                Nothing ->
                    acc

        neighborData =
            List.foldl checkCell
                initialAcc
                [ ( -1, -1 ), ( -1, 0 ), ( -1, 1 ), ( 0, -1 ), ( 0, 0 ), ( 0, 1 ), ( 1, -1 ), ( 1, 0 ), ( 1, 1 ) ]

        steering =
            if neighborData.count == 0 then
                neighborData.sumSep
                    |> mul config.separationFactor
                    |> limit config.maxForce

            else
                let
                    invCount =
                        1 / toFloat neighborData.count

                    vCohesion =
                        neighborData.sumPos
                            |> mul invCount
                            |> sub boid.position
                            |> mul config.cohesionFactor

                    vAlignment =
                        neighborData.sumVel
                            |> mul invCount
                            |> sub boid.velocity
                            |> mul config.alignmentFactor

                    vSeparation =
                        neighborData.sumSep
                            |> mul config.separationFactor
                in
                vCohesion
                    |> add vAlignment
                    |> add vSeparation
                    |> limit config.maxForce

        newVelocity =
            boid.velocity
                |> add (mul dt steering)
                |> limitSpeed config

        newPosition =
            boid.position
                |> add (mul dt newVelocity)
                |> wrap config
    in
    { position = newPosition, velocity = newVelocity }


limitSpeed : Config -> Vector -> Vector
limitSpeed config v =
    let
        speed =
            mag v
    in
    if speed > config.maxSpeed then
        mul (config.maxSpeed / speed) v

    else if speed < config.minSpeed then
        mul (config.minSpeed / speed) v

    else
        v


wrap : Config -> Vector -> Vector
wrap config v =
    { x =
        if v.x < 0 then
            v.x + config.width

        else if v.x > config.width then
            v.x - config.width

        else
            v.x
    , y =
        if v.y < 0 then
            v.y + config.height

        else if v.y > config.height then
            v.y - config.height

        else
            v.y
    }



-- VIEW --


view : Model -> Html Msg
view model =
    Canvas.toHtml ( round model.config.width, round model.config.height )
        []
        [ clearCanvas model.config
        , drawBoids model.config model.boids
        ]


{-| An alternative view that allows for pointer events to pass through.
Useful for background animations.
-}
viewOverlay : Model -> Html Msg
viewOverlay model =
    Canvas.toHtml ( round model.config.width, round model.config.height )
        [ Attr.style "pointer-events" "none" ]
        [ clearCanvas model.config
        , drawBoids model.config model.boids
        ]


clearCanvas : Config -> Renderable
clearCanvas config =
    case config.backgroundColor of
        Just color ->
            shapes [ fill color ] [ rect ( 0, 0 ) config.width config.height ]

        Nothing ->
            clear ( 0, 0 ) config.width config.height


drawBoids : Config -> List Boid -> Renderable
drawBoids config boids =
    let
        drawSingleBoid boid =
            let
                angle =
                    atan2 boid.velocity.y boid.velocity.x

                cosA =
                    cos angle

                sinA =
                    sin angle

                {- We manually calculate the rotation and translation for each boid
                   to minimize the number of Renderable objects. Using `transform`
                   for each of 10,000 boids is significantly slower.
                -}
                transformX x y =
                    boid.position.x + (x * cosA - y * sinA)

                transformY x y =
                    boid.position.y + (x * sinA + y * cosA)

                p1x =
                    transformX -5 -3

                p1y =
                    transformY -5 -3

                p2x =
                    transformX 7 0

                p2y =
                    transformY 7 0

                p3x =
                    transformX -5 3

                p3y =
                    transformY -5 3
            in
            path ( p1x, p1y )
                [ lineTo ( p2x, p2y )
                , lineTo ( p3x, p3y )
                , lineTo ( p1x, p1y )
                ]
    in
    shapes [ fill config.boidColor ] (List.map drawSingleBoid boids)



-- MAIN --


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init defaultConfig
        , view = view
        , update = update
        , subscriptions = \_ -> Browser.Events.onAnimationFrameDelta OnFrame
        }
