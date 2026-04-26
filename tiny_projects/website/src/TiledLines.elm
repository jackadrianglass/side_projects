module TiledLines exposing
    ( Model
    , Msg
    , Settings
    , generateDirections
    , main
    , update
    , view
    )

import Browser
import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Line exposing (lineWidth)
import Color
import Html exposing (Html)
import Random



-- MODEL --


stepCounts : Float -> Float -> Float -> ( Int, Int )
stepCounts stepSize width height =
    let
        stepCountX =
            floor <| width / stepSize

        stepCountY =
            floor <| height / stepSize
    in
    ( stepCountX, stepCountY )


type alias Settings =
    { width : Float, height : Float, stepSize : Float, strokeColor : Color.Color, backgroundColor : Color.Color }


type alias Model =
    { settings : Settings, drawingDirections : Maybe (List Int) }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        testSettings : Settings
        testSettings =
            { width = 600, height = 400, stepSize = 20, strokeColor = Color.white, backgroundColor = Color.purple }
    in
    ( { settings = testSettings, drawingDirections = Nothing }, Random.generate Direction <| generateDirections testSettings )


generateDirections : Settings -> Random.Generator (List Int)
generateDirections settings =
    let
        ( stepCountX, stepCountY ) =
            stepCounts settings.stepSize settings.width settings.height
    in
    Random.list (stepCountX * stepCountY) (Random.int 0 1)



-- VIEW --


line : Point -> Point -> Shape
line start end =
    path start [ lineTo end ]


lineStep : Point -> Float -> Int -> Shape
lineStep loc length direction =
    let
        start =
            if direction == 0 then
                loc

            else
                ( Tuple.first loc + length, Tuple.second loc )

        end =
            if direction == 0 then
                ( Tuple.first loc + length, Tuple.second loc + length )

            else
                ( Tuple.first loc, Tuple.second loc + length )
    in
    line start end


view : Model -> Html msg
view model =
    let
        canvasElements =
            case model.drawingDirections of
                Nothing ->
                    []

                Just directions ->
                    drawing model.settings directions
    in
    Canvas.toHtml ( round model.settings.width, round model.settings.height ) [] canvasElements


drawing : Settings -> List Int -> List Renderable
drawing settings directions =
    let
        stepSize =
            floor <| settings.stepSize

        ( stepCountX, stepCountY ) =
            stepCounts settings.stepSize settings.width settings.height

        pos =
            \idx jdx -> ( toFloat <| idx * stepSize, toFloat <| jdx * stepSize )

        dir =
            \idx jdx ->
                case List.head (List.drop (idx + jdx * stepCountX) directions) of
                    Just val ->
                        val

                    Nothing ->
                        0

        step =
            \idx jdx ->
                lineStep (pos idx jdx) (toFloat stepSize) (dir idx jdx)

        steps =
            List.range 0 stepCountX
                |> List.concatMap (\idx -> List.range 0 stepCountY |> List.map (\jdx -> step idx jdx))

        shapeSettings =
            [ stroke settings.strokeColor, fill settings.backgroundColor, lineWidth 2 ]
    in
    [ shapes shapeSettings (steps ++ [ rect ( 0, 0 ) settings.width settings.height ]) ]



-- UPDATE --


type Msg
    = Direction (List Int)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Direction val ->
            ( { model | drawingDirections = Just val }, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
