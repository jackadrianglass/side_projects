module Boids exposing (..)

import Browser
import Browser.Events
import Color
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Random
import WebGL exposing (Entity, Mesh, Shader)



-- CONFIG --


{-| Configuration for the boid simulation.
-}
type alias Config =
    { width : Float
    , height : Float
    , numBoids : Int

    -- Simulation Parameters
    , visualRange : Float -- How far each boid can "see"
    , minDistance : Float -- Distance at which boids start avoiding each other
    , cohesionFactor : Float -- How strongly boids move toward the center of the flock
    , alignmentFactor : Float -- How strongly boids match the velocity of their neighbors
    , separationFactor : Float -- How strongly boids avoid crowding
    , maxSpeed : Float
    , minSpeed : Float
    , maxForce : Float -- Maximum steering force applied in one frame
    , visualFieldOfView : Float -- The angle of the boid's visual cone in radians
    , boidColor : Color.Color
    , backgroundColor : Maybe Color.Color
    }


{-| Default configuration tuned for coherent flocking at typical interactive counts.
-}
defaultConfig : Config
defaultConfig =
    { width = 400
    , height = 400
    , numBoids = 500
    , visualRange = 50
    , minDistance = 30
    , cohesionFactor = 0.001
    , alignmentFactor = 0.04
    , separationFactor = 0.3
    , maxSpeed = 2
    , minSpeed = 1
    , maxForce = 0.15
    , visualFieldOfView = pi
    , boidColor = Color.black
    , backgroundColor = Just Color.white
    }



-- MODEL --


{-| Represents a single boid in the simulation.
-}
type alias Boid =
    { position : Vec2
    , velocity : Vec2
    }


{-| The simulation model.
-}
type alias Model =
    { boids : List Boid

    -- A spatial hash grid used to speed up neighbor lookups.
    -- The boids are grouped into cells based on their position.
    , grid : Dict ( Int, Int ) (List Boid)
    , config : Config
    }


{-| Initialize the simulation with the given configuration.
-}
init : Config -> ( Model, Cmd Msg )
init config =
    ( { boids = [], grid = Dict.empty, config = config }
    , Random.generate InitBoids (List.range 0 (config.numBoids - 1) |> List.map (randomBoid config) |> combineGenerators)
    )


randomBoid : Config -> Int -> Random.Generator Boid
randomBoid config _ =
    Random.map4
        (\x y speed angleOffset ->
            let
                heading =
                    (-pi / 4) + angleOffset
            in
            Boid
                (vec2 x y)
                (vec2 (speed * cos heading) (speed * sin heading))
        )
        (Random.float 0 config.width)
        (Random.float 0 config.height)
        (Random.float config.minSpeed config.maxSpeed)
        (Random.float (-pi / 6) (pi / 6))


combineGenerators : List (Random.Generator a) -> Random.Generator (List a)
combineGenerators generators =
    case generators of
        [] ->
            Random.constant []

        g :: gs ->
            Random.map2 (::) g (combineGenerators gs)



-- UPDATE --


type Msg
    = OnFrame Float
    | InitBoids (List Boid)
    | Resize Float Float
    | UpdateConfig Config


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateConfig config ->
            if config.numBoids /= model.config.numBoids then
                -- If number of boids changed, we need to re-initialize them
                init config

            else
                ( { model | config = config, grid = buildGrid config model.boids }, Cmd.none )

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


{-| Builds a spatial grid from the current list of boids.
Cells are sized according to the `visualRange` to ensure all neighbors are in adjacent cells.
-}
buildGrid : Config -> List Boid -> Dict ( Int, Int ) (List Boid)
buildGrid config boids =
    let
        cellSize =
            config.visualRange

        toGridPos pos =
            ( floor (Vec2.getX pos / cellSize), floor (Vec2.getY pos / cellSize) )

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


{-| Updates a single boid's position and velocity based on its neighbors and world boundaries.
-}
updateBoid : Config -> Float -> Dict ( Int, Int ) (List Boid) -> Boid -> Boid
updateBoid config dt grid boid =
    let
        cellSize =
            config.visualRange

        cellsX =
            max 1 (ceiling (config.width / cellSize))

        cellsY =
            max 1 (ceiling (config.height / cellSize))

        wrapIndex : Int -> Int -> Int
        wrapIndex size idx =
            modBy size (idx + size)

        gridX =
            floor (Vec2.getX boid.position / cellSize)

        gridY =
            floor (Vec2.getY boid.position / cellSize)

        visualRangeSq =
            config.visualRange * config.visualRange

        minDistanceSq =
            config.minDistance * config.minDistance

        eps =
            0.0001

        wrapDelta : Float -> Float -> Float
        wrapDelta size delta =
            if delta > size / 2 then
                delta - size

            else if delta < -(size / 2) then
                delta + size

            else
                delta

        neighborData =
            let
                accumulateNeighbors other acc =
                    let
                        rawDx =
                            Vec2.getX other.position - Vec2.getX boid.position

                        rawDy =
                            Vec2.getY other.position - Vec2.getY boid.position

                        dx =
                            wrapDelta config.width rawDx

                        dy =
                            wrapDelta config.height rawDy

                        toOther =
                            vec2 dx dy

                        distanceSq =
                            dx * dx + dy * dy
                    in
                    if other /= boid && distanceSq < visualRangeSq then
                        { acc
                            | count =
                                if distanceSq < minDistanceSq then
                                    acc.count

                                else
                                    acc.count + 1
                            , sumPos =
                                if distanceSq < minDistanceSq then
                                    acc.sumPos

                                else
                                    Vec2.add acc.sumPos (Vec2.add boid.position toOther)
                            , sumVel =
                                if distanceSq < minDistanceSq then
                                    acc.sumVel

                                else
                                    Vec2.add acc.sumVel other.velocity
                            , sepCount =
                                if distanceSq < minDistanceSq then
                                    acc.sepCount + 1

                                else
                                    acc.sepCount
                            , sumSep =
                                if distanceSq < minDistanceSq then
                                    let
                                        distance =
                                            sqrt (max distanceSq eps)

                                        weight =
                                            1 / distance
                                    in
                                    Vec2.add acc.sumSep (Vec2.scale weight (vec2 -dx -dy))

                                else
                                    acc.sumSep
                        }

                    else
                        acc
            in
            [ ( -1, -1 ), ( -1, 0 ), ( -1, 1 ), ( 0, -1 ), ( 0, 0 ), ( 0, 1 ), ( 1, -1 ), ( 1, 0 ), ( 1, 1 ) ]
                |> List.foldl
                    (\( dx, dy ) acc ->
                        case Dict.get ( wrapIndex cellsX (gridX + dx), wrapIndex cellsY (gridY + dy) ) grid of
                            Just bs ->
                                List.foldl accumulateNeighbors acc bs

                            Nothing ->
                                acc
                    )
                    { count = 0, sepCount = 0, sumPos = vec2 0 0, sumVel = vec2 0 0, sumSep = vec2 0 0 }

        steering =
            if neighborData.count == 0 then
                -- No neighbors? Just apply separation if we are too close to something (edge case)
                if neighborData.sepCount == 0 then
                    vec2 0 0

                else
                    neighborData.sumSep
                        |> Vec2.scale config.separationFactor
                        |> limitVec2 config.maxForce

            else
                let
                    invCount =
                        1 / toFloat neighborData.count

                    vCohesion =
                        -- Cohesion: Steer toward the average position (center of mass) of local neighbors.
                        neighborData.sumPos
                            |> Vec2.scale invCount
                            |> (\center -> Vec2.sub center boid.position)
                            |> Vec2.scale config.cohesionFactor

                    vAlignment =
                        -- Alignment: Steer towards the average velocity of local neighbors.
                        neighborData.sumVel
                            |> Vec2.scale invCount
                            |> (\avgVelocity -> Vec2.sub avgVelocity boid.velocity)
                            |> Vec2.scale config.alignmentFactor

                    vSeparation =
                        -- Separation: Steer to avoid crowding local neighbors.
                        if neighborData.sepCount == 0 then
                            vec2 0 0

                        else
                            neighborData.sumSep
                                |> Vec2.scale (1 / toFloat neighborData.sepCount)
                                |> Vec2.scale config.separationFactor
                in
                vCohesion
                    |> Vec2.add vAlignment
                    |> Vec2.add vSeparation
                    |> limitVec2 config.maxForce

        newVelocity =
            boid.velocity
                |> Vec2.add (Vec2.scale dt steering)
                |> limitSpeed config

        newPosition =
            boid.position
                |> Vec2.add (Vec2.scale dt newVelocity)
                |> wrap config
    in
    { position = newPosition, velocity = newVelocity }


{-| Constraints a vector to a maximum length.
-}
limitVec2 : Float -> Vec2 -> Vec2
limitVec2 max v =
    let
        m =
            Vec2.length v
    in
    if m > max then
        Vec2.scale (max / m) v

    else
        v


{-| Ensures a boid's speed stays within the configured min and max bounds.
-}
limitSpeed : Config -> Vec2 -> Vec2
limitSpeed config v =
    let
        speed =
            Vec2.length v
    in
    if speed > config.maxSpeed then
        Vec2.scale (config.maxSpeed / speed) v

    else if speed < config.minSpeed then
        Vec2.scale (config.minSpeed / speed) v

    else
        v


{-| Wraps the boid around the edges of the screen.
-}
wrap : Config -> Vec2 -> Vec2
wrap config v =
    let
        vx =
            Vec2.getX v

        vy =
            Vec2.getY v

        newX =
            if vx < 0 then
                vx + config.width

            else if vx > config.width then
                vx - config.width

            else
                vx

        newY =
            if vy < 0 then
                vy + config.height

            else if vy > config.height then
                vy - config.height

            else
                vy
    in
    vec2 newX newY



-- VIEW --


{-| Renders the boid simulation.
-}
view : Model -> Html Msg
view model =
    renderWebGL [] model


{-| An alternative view that allows for pointer events to pass through.
Useful for background animations.
-}
viewOverlay : Model -> Html Msg
viewOverlay model =
    renderWebGL [ Attr.style "pointer-events" "none" ] model


{-| Renders a settings menu for the boid simulation.
-}
viewSettings : Config -> Html Msg
viewSettings config =
    Html.div
        [ Attr.class "boids-settings" ]
        [ slider "Boids" (toFloat config.numBoids) 10 1000 1 (\v -> { config | numBoids = round v })
        , slider "Visual Range" config.visualRange 0 200 1 (\v -> { config | visualRange = v })
        , slider "Min Distance" config.minDistance 0 100 1 (\v -> { config | minDistance = v })
        , slider "Cohesion" config.cohesionFactor 0 0.05 0.001 (\v -> { config | cohesionFactor = v })
        , slider "Alignment" config.alignmentFactor 0 0.2 0.001 (\v -> { config | alignmentFactor = v })
        , slider "Separation" config.separationFactor 0 0.2 0.001 (\v -> { config | separationFactor = v })
        , slider "Max Speed" config.maxSpeed 0 10 0.1 (\v -> { config | maxSpeed = v })
        , slider "Min Speed" config.minSpeed 0 10 0.1 (\v -> { config | minSpeed = v })
        , slider "Max Force" config.maxForce 0 0.5 0.01 (\v -> { config | maxForce = v })
        , slider "Field of View" (config.visualFieldOfView * 180 / pi) 0 360 1 (\v -> { config | visualFieldOfView = v * pi / 180 })
        ]


slider : String -> Float -> Float -> Float -> Float -> (Float -> Config) -> Html Msg
slider labelText val minVal maxVal stepVal toConfig =
    Html.div [ Attr.class "setting-item" ]
        [ Html.label [] [ Html.text labelText ]
        , Html.input
            [ Attr.type_ "range"
            , Attr.min (String.fromFloat minVal)
            , Attr.max (String.fromFloat maxVal)
            , Attr.step (String.fromFloat stepVal)
            , Attr.value (String.fromFloat val)
            , Html.Events.onInput (String.toFloat >> Maybe.withDefault val >> (\v -> UpdateConfig (toConfig v)))
            ]
            []
        , Html.span [ Attr.class "setting-value" ] [ Html.text (String.fromFloat val) ]
        ]


renderWebGL : List (Html.Attribute Msg) -> Model -> Html Msg
renderWebGL additionalAttrs model =
    WebGL.toHtml
        ([ Attr.width (round model.config.width)
         , Attr.height (round model.config.height)
         , Attr.style "display" "block"
         ]
            ++ additionalAttrs
        )
        (backgroundEntities model ++ [ boidsEntity model ])


backgroundEntities : Model -> List Entity
backgroundEntities model =
    case model.config.backgroundColor of
        Just color ->
            let
                rgb =
                    Color.toRgba color
            in
            [ WebGL.entity
                backgroundVertexShader
                backgroundFragmentShader
                backgroundMesh
                { u_projection = projectionMatrix model.config
                , u_color = vec3 rgb.red rgb.green rgb.blue
                }
            ]

        Nothing ->
            []


{-| A full-screen mesh used for the background color.
-}
backgroundMesh : Mesh { a_pos : Vec2 }
backgroundMesh =
    WebGL.triangleStrip
        [ { a_pos = vec2 -1 -1 }
        , { a_pos = vec2 1 -1 }
        , { a_pos = vec2 -1 1 }
        , { a_pos = vec2 1 1 }
        ]


backgroundVertexShader : Shader { a_pos : Vec2 } Uniforms { v_color : Vec3 }
backgroundVertexShader =
    [glsl|
        attribute vec2 a_pos;
        uniform mat4 u_projection;
        uniform vec3 u_color;
        varying vec3 v_color;

        void main() {
            gl_Position = vec4(a_pos, 0.0, 1.0);
            v_color = u_color;
        }
    |]


{-| Attributes for each boid vertex.
To optimize rendering, we pass the boid's position and velocity as attributes
so the GPU can handle the transformation (rotation/translation) in the vertex shader.
-}
type alias Vertex =
    { a_pos : Vec2 -- Vertex position relative to boid center
    , a_boidPos : Vec2 -- World position of the boid
    , a_boidVel : Vec2 -- Velocity of the boid (used for rotation)
    , a_localPos : Vec2 -- Coordinate for SDF calculation
    }


type alias Uniforms =
    { u_projection : Mat4
    , u_color : Vec3
    }


{-| The WebGL entity representing all boids.
-}
boidsEntity : Model -> Entity
boidsEntity model =
    let
        color =
            Color.toRgba model.config.boidColor

        uniforms =
            { u_projection = projectionMatrix model.config
            , u_color = vec3 color.red color.green color.blue
            }
    in
    WebGL.entity
        vertexShader
        fragmentShader
        (boidsMesh model.boids)
        uniforms


{-| Creates an orthographic projection matrix for 2D rendering.
-}
projectionMatrix : Config -> Mat4
projectionMatrix config =
    Mat4.makeOrtho 0 config.width config.height 0 -1 1


{-| Generates a single mesh containing all boids as individual triangles.
-}
boidsMesh : List Boid -> Mesh Vertex
boidsMesh boids =
    let
        -- A triangle large enough to encompass our SDF shape
        size =
            15

        toVertices boid =
            [ ( Vertex (vec2 size 0) boid.position boid.velocity (vec2 1 0)
              , Vertex (vec2 -size -size) boid.position boid.velocity (vec2 -1 -1)
              , Vertex (vec2 -size size) boid.position boid.velocity (vec2 -1 1)
              )
            ]
    in
    boids
        |> List.concatMap toVertices
        |> WebGL.triangles


backgroundFragmentShader : Shader {} Uniforms { v_color : Vec3 }
backgroundFragmentShader =
    [glsl|
        precision mediump float;
        varying vec3 v_color;

        void main() {
            gl_FragColor = vec4(v_color, 1.0);
        }
    |]


vertexShader : Shader Vertex Uniforms { v_color : Vec3, v_localPos : Vec2 }
vertexShader =
    [glsl|
        attribute vec2 a_pos;
        attribute vec2 a_boidPos;
        attribute vec2 a_boidVel;
        attribute vec2 a_localPos;
        uniform mat4 u_projection;
        uniform vec3 u_color;
        varying vec3 v_color;
        varying vec2 v_localPos;

        void main() {
            float angle = atan(a_boidVel.y, a_boidVel.x);
            float cosA = cos(angle);
            float sinA = sin(angle);
            
            // Rotation matrix
            mat2 rot = mat2(cosA, sinA, -sinA, cosA);
            
            vec2 rotatedPos = rot * a_pos;
            vec2 finalPos = rotatedPos + a_boidPos;
            
            gl_Position = u_projection * vec4(finalPos, 0.0, 1.0);
            v_color = u_color;
            v_localPos = a_localPos;
        }
    |]


fragmentShader : Shader {} Uniforms { v_color : Vec3, v_localPos : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec3 v_color;
        varying vec2 v_localPos;

        // SDF for a teardrop shape
        // Based on: https://www.shadertoy.com/view/tdS3WG
        float sdTeardrop(vec2 p, float h, float r) {
            p.x = abs(p.x);
            float a = r / h;
            float b = sqrt(1.0 - a * a);
            float k = dot(p, vec2(-b, a));
            if (k < 0.0) return length(p) - r;
            if (k > a * h) return length(p - vec2(0.0, h)) - 0.0;
            return dot(p, vec2(a, b)) - r;
        }

        void main() {
            // v_localPos ranges from roughly (-1, -1) to (1, 1) inside the triangle
            // We adjust p for the teardrop SDF: pointed part up (positive Y)
            vec2 p = vec2(v_localPos.y, -v_localPos.x); 
            float dist = sdTeardrop(p + vec2(0.0, 0.4), 1.5, 0.6);
            
            // Discard pixels outside the teardrop
            if (dist > 0.0) {
                discard;
            }

            // Simple shading for a rounded look
            float shade = 1.0 - smoothstep(-0.5, 0.0, dist);
            gl_FragColor = vec4(v_color * (0.8 + 0.2 * shade), 1.0);
        }
    |]



-- MAIN --


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init defaultConfig
        , view = view
        , update = update
        , subscriptions = \_ -> Browser.Events.onAnimationFrameDelta OnFrame
        }
