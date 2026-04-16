module BoidsTest exposing (main)

import Boids
import Browser
import Browser.Events
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Random


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { boidsModel : Boids.Model
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        ( boidsModel, boidsCmd ) =
            Boids.init Boids.defaultConfig
    in
    ( { boidsModel = boidsModel }
    , Cmd.map BoidsMsg boidsCmd
    )


type Msg
    = BoidsMsg Boids.Msg
    | UpdateConfig (Boids.Config -> Boids.Config)
    | ResetBoids


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BoidsMsg bMsg ->
            let
                ( newBoidsModel, boidsCmd ) =
                    Boids.update bMsg model.boidsModel
            in
            ( { model | boidsModel = newBoidsModel }
            , Cmd.map BoidsMsg boidsCmd
            )

        UpdateConfig transform ->
            let
                oldConfig =
                    model.boidsModel.config

                newConfig =
                    transform oldConfig

                oldBoidsModel =
                    model.boidsModel

                -- If numBoids changed, we might need to re-init boids or adjust the list.
                -- For simplicity, if numBoids changed, we'll just trigger a reset for now or handle it.
                newBoidsModel =
                    { oldBoidsModel | config = newConfig }
            in
            if newConfig.numBoids /= oldConfig.numBoids then
                update ResetBoids { model | boidsModel = newBoidsModel }

            else
                ( { model | boidsModel = newBoidsModel }, Cmd.none )

        ResetBoids ->
            let
                ( newBoidsModel, boidsCmd ) =
                    Boids.init model.boidsModel.config
            in
            ( { model | boidsModel = newBoidsModel }
            , Cmd.map BoidsMsg boidsCmd
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map BoidsMsg (Browser.Events.onAnimationFrameDelta Boids.OnFrame)


view : Model -> Html Msg
view model =
    div [ style "padding" "20px", style "font-family" "sans-serif" ]
        [ h1 [] [ text "Boids Simulation Test" ]
        , div [ style "display" "flex", style "flex-wrap" "wrap", style "gap" "20px" ]
            [ div []
                [ Html.map BoidsMsg (Boids.view model.boidsModel)
                ]
            , div [ style "flex" "1", style "min-width" "300px" ]
                [ h2 [] [ text "Configuration" ]
                , configSliders model.boidsModel.config
                , button
                    [ onClick ResetBoids
                    , style "margin-top" "20px"
                    , style "padding" "10px"
                    ]
                    [ text "Reset Boids" ]
                ]
            ]
        ]


configSliders : Boids.Config -> Html Msg
configSliders config =
    div [ style "display" "flex", style "flex-direction" "column", style "gap" "10px" ]
        [ slider "Num Boids" 1 200 1 (toFloat config.numBoids) (\v -> UpdateConfig (\c -> { c | numBoids = round v }))
        , slider "Visual Range" 1 200 1 config.visualRange (\v -> UpdateConfig (\c -> { c | visualRange = v }))
        , slider "Min Distance" 1 100 1 config.minDistance (\v -> UpdateConfig (\c -> { c | minDistance = v }))
        , slider "Cohesion Factor" 0 0.05 0.001 config.cohesionFactor (\v -> UpdateConfig (\c -> { c | cohesionFactor = v }))
        , slider "Alignment Factor" 0 0.2 0.01 config.alignmentFactor (\v -> UpdateConfig (\c -> { c | alignmentFactor = v }))
        , slider "Separation Factor" 0 0.2 0.01 config.separationFactor (\v -> UpdateConfig (\c -> { c | separationFactor = v }))
        , slider "Max Speed" 0.1 10 0.1 config.maxSpeed (\v -> UpdateConfig (\c -> { c | maxSpeed = v }))
        , slider "Min Speed" 0 5 0.1 config.minSpeed (\v -> UpdateConfig (\c -> { c | minSpeed = v }))
        , slider "Max Force" 0 1 0.01 config.maxForce (\v -> UpdateConfig (\c -> { c | maxForce = v }))
        , slider "Width" 100 800 10 config.width (\v -> UpdateConfig (\c -> { c | width = v }))
        , slider "Height" 100 800 10 config.height (\v -> UpdateConfig (\c -> { c | height = v }))
        ]


slider : String -> Float -> Float -> Float -> Float -> (Float -> Msg) -> Html Msg
slider labelText minVal maxVal stepVal currentVal toMsg =
    div []
        [ label [ style "display" "block" ]
            [ text (labelText ++ ": " ++ String.fromFloat currentVal) ]
        , input
            [ type_ "range"
            , Html.Attributes.min (String.fromFloat minVal)
            , Html.Attributes.max (String.fromFloat maxVal)
            , step (String.fromFloat stepVal)
            , value (String.fromFloat currentVal)
            , onInput (\val -> toMsg (Maybe.withDefault currentVal (String.toFloat val)))
            , style "width" "100%"
            ]
            []
        ]



-- Helper for onClick since it's not imported


onClick : msg -> Attribute msg
onClick msg =
    Html.Events.onClick msg
