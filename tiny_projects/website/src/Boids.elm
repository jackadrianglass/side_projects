module Boids exposing (..)

import Browser
import Browser.Events
import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Advanced exposing (rotate, transform, translate)
import Canvas.Settings.Line exposing (lineWidth)
import Color
import Html exposing (Html)
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
    }


defaultConfig : Config
defaultConfig =
    { width = 400
    , height = 400
    , numBoids = 50
    , visualRange = 40
    , minDistance = 20
    , cohesionFactor = 0.005
    , alignmentFactor = 0.05
    , separationFactor = 0.05
    , maxSpeed = 3
    , minSpeed = 1.5
    , maxForce = 0.1
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


dist : Vector -> Vector -> Float
dist v1 v2 =
    sqrt ((v1.x - v2.x) ^ 2 + (v1.y - v2.y) ^ 2)


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
    , config : Config
    }


init : Config -> ( Model, Cmd Msg )
init config =
    ( { boids = [], config = config }
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitBoids boids ->
            ( { model | boids = boids }, Cmd.none )

        OnFrame delta ->
            let
                -- We normalize the update based on 60fps (~16.6ms per frame)
                dt =
                    delta / 16.6
            in
            ( { model | boids = List.map (updateBoid model.config dt model.boids) model.boids }, Cmd.none )


updateBoid : Config -> Float -> List Boid -> Boid -> Boid
updateBoid config dt allBoids boid =
    let
        neighbors =
            List.filter (\other -> other /= boid && dist boid.position other.position < config.visualRange) allBoids

        vCohesion =
            cohesion boid neighbors
                |> mul config.cohesionFactor

        vAlignment =
            alignment boid neighbors
                |> mul config.alignmentFactor

        vSeparation =
            separation config boid allBoids
                |> mul config.separationFactor

        steering =
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


cohesion : Boid -> List Boid -> Vector
cohesion boid neighbors =
    if List.isEmpty neighbors then
        { x = 0, y = 0 }

    else
        let
            center =
                List.foldl (\other acc -> add other.position acc) { x = 0, y = 0 } neighbors
                    |> mul (1 / toFloat (List.length neighbors))
        in
        sub center boid.position


alignment : Boid -> List Boid -> Vector
alignment boid neighbors =
    if List.isEmpty neighbors then
        { x = 0, y = 0 }

    else
        let
            avgVelocity =
                List.foldl (\other acc -> add other.velocity acc) { x = 0, y = 0 } neighbors
                    |> mul (1 / toFloat (List.length neighbors))
        in
        sub avgVelocity boid.velocity


separation : Config -> Boid -> List Boid -> Vector
separation config boid allBoids =
    let
        move =
            List.foldl
                (\other acc ->
                    if other /= boid && dist boid.position other.position < config.minDistance then
                        add acc (sub boid.position other.position)

                    else
                        acc
                )
                { x = 0, y = 0 }
                allBoids
    in
    move


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
        (clearCanvas model.config :: List.map drawBoid model.boids)


clearCanvas : Config -> Renderable
clearCanvas config =
    shapes [ fill Color.white ] [ rect ( 0, 0 ) config.width config.height ]


drawBoid : Boid -> Renderable
drawBoid boid =
    let
        angle =
            atan2 boid.velocity.y boid.velocity.x
    in
    shapes
        [ fill Color.black
        , transform
            [ translate boid.position.x boid.position.y
            , rotate angle
            ]
        ]
        [ path ( -5, -3 )
            [ lineTo ( 7, 0 )
            , lineTo ( -5, 3 )
            , lineTo ( -5, -3 )
            ]
        ]



-- MAIN --


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init defaultConfig
        , view = view
        , update = update
        , subscriptions = \_ -> Browser.Events.onAnimationFrameDelta OnFrame
        }
