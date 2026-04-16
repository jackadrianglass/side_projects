module Main exposing (main)

import Boids
import Browser
import Browser.Events as Events
import FeatherIcons as Icons
import Html exposing (Html)
import Html.Attributes as Attr
import Random
import Theme
import TiledLines



-- Main --


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions =
            \model ->
                Sub.batch
                    [ Events.onResize
                        (\width height ->
                            WindowResized
                                { width = toFloat width
                                , height = toFloat height
                                }
                        )
                    , Sub.map BoidsMsg (Events.onAnimationFrameDelta Boids.OnFrame)
                    ]
        }



-- Init --


type alias Model =
    { drawingModel : TiledLines.Model
    , boidsModel : Boids.Model
    , scrollBarWidth : Float
    }


type alias Flags =
    { windowWidth : Float, windowHeight : Float, scrollBarWidth : Float }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        drawingSettings : TiledLines.Settings
        drawingSettings =
            { width = flags.windowWidth - flags.scrollBarWidth
            , height = flags.windowHeight
            , stepSize = 20
            , strokeColor = Theme.theme.highlightHigh
            , backgroundColor = Theme.theme.base
            }

        boidsConfig : Boids.Config
        boidsConfig =
            let
                default =
                    Boids.defaultConfig
            in
            { default
                | numBoids = 100
                , boidColor = Theme.theme.rose
                , backgroundColor = Nothing
            }

        ( initialBoidsModel, boidsCmd ) =
            Boids.init { boidsConfig | width = drawingSettings.width, height = drawingSettings.height }

        model : Model
        model =
            { drawingModel = { settings = drawingSettings, drawingDirections = Nothing }
            , boidsModel = initialBoidsModel
            , scrollBarWidth = flags.scrollBarWidth
            }
    in
    ( model
    , Cmd.batch
        [ Random.generate Ready <| TiledLines.generateDirections drawingSettings
        , Cmd.map BoidsMsg boidsCmd
        ]
    )



-- View --


view : Model -> Html Msg
view model =
    Html.div []
        [ splashScreen model
        , Html.br [] []
        , Html.br [] []
        , about
        , Html.br [] []
        , Html.br [] []
        , skills
        ]


linkTreeIcon : Icons.Icon -> String -> Html Msg
linkTreeIcon icon url =
    Html.a [ Attr.href url ]
        [ icon
            |> Icons.withSize 1.5
            |> Icons.withSizeUnit "em"
            |> Icons.withClass "link-tree-icon"
            |> Icons.toHtml []
        ]


splashScreen : Model -> Html Msg
splashScreen model =
    Html.div
        [ Attr.class "splash-screen" ]
        [ Html.div [ Attr.class "splash-screen-background" ]
            [ TiledLines.view model.drawingModel
            , Html.div
                [ Attr.style "position" "absolute"
                , Attr.style "top" "0"
                , Attr.style "left" "0"
                ]
                [ Html.map BoidsMsg (Boids.viewOverlay model.boidsModel) ]
            ]
        , Html.div [ Attr.class "splash-screen-foreground" ]
            [ Html.div [ Attr.class "splash-screen-box" ]
                [ Html.h1 [] [ Html.text "Jack Glass" ]
                , Html.div [ Attr.class "splash-screen-linktree" ]
                    [ linkTreeIcon Icons.github "https://github.com/jackadrianglass"
                    , linkTreeIcon Icons.linkedin "https://www.linkedin.com/in/jack-glass-561944129/"
                    , linkTreeIcon Icons.mail "mailto:jackadrianglass@gmail.com"
                    ]
                ]
            ]
        ]


about : Html Msg
about =
    Html.div [ Attr.class "card" ]
        [ Html.div [ Attr.class "card-content" ]
            [ Html.h1 [] [ Html.text "About" ]
            , Html.p []
                [ Html.text
                    """
I’m a Calgary-based software engineer with 6+ years of development experience
building applications ranging from embedded systems programming on a cycling dynamics
pedal, to distributed backend development for high performance geospatial computation.
My work has involved many languages and libraries including
"""
                ]
            , Html.ul []
                -- todo: Ideally I'd like some iconography for the technologies that I've used but this is good enough for now
                [ Html.li [] [ Html.text "Rust, Axum, and protobuf for backend web development" ]
                , Html.li [] [ Html.text "C++ and Qt for gui application development" ]
                , Html.li [] [ Html.text "Python and FastApi for distributed computation" ]
                , Html.li [] [ Html.text "Devops tooling including Bazel, Waf, Python, Bash, Powershell, Docker, Jenkins, etc." ]
                , Html.li [] [ Html.text "C, ANT and BLE for low resource embedded systems" ]
                ]
            , Html.p [] [ Html.text """
I'm also actively involved in the Calgary software community. I host a weekly coworking
session as a recurring space for folks to work on their side projects. I'm also involved
with the Software Developers of Calgary group helping host a monthly meetup to help working
developers hone their craft.
            """ ]
            ]
        , Html.img
            [ Attr.class "card-img"
            , Attr.src "headshot.png"
            ]
            [ Html.text "Jack's Beautiful Face" ]
        ]


skills : Html Msg
skills =
    Html.div [ Attr.class "skill-tree" ]
        [ Html.h1 [] [ Html.text "Languages, Tools & Frameworks" ]
        , Html.div [ Attr.class "skill-tree-row" ]
            [ Html.div [ Attr.class "skill-tree-section" ]
                [ Html.h2 [] [ Html.text "Professional Experience" ]
                , Html.ul []
                    [ Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-rust-original" ] [] ]
                        , Html.p [] [ Html.text "Rust for high performance web backend" ]
                        ]
                    , Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-cplusplus-plain" ] [] ]
                        , Html.p [] [ Html.text "C++ & Qt for GUI application development" ]
                        ]
                    , Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-python-plain" ] [] ]
                        , Html.p [] [ Html.text "Python for distributed computing & infrastructure" ]
                        ]
                    , Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-embeddedc-plain" ] [] ]
                        , Html.p [] [ Html.text "C for resource constrained embedded systems" ]
                        ]
                    ]
                ]
            , Html.div [ Attr.class "skill-tree-section" ]
                [ Html.h2 [] [ Html.text "Devops" ]
                , Html.ul []
                    [ Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-docker-plain" ] [] ]
                        , Html.p [] [ Html.text "Docker for deployment and development" ]
                        ]
                    , Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-poetry-plain" ] [] ]
                        , Html.p [] [ Html.text "Poetry for environment management and caching" ]
                        ]
                    , Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-jenkins-line" ] [] ]
                        , Html.p [] [ Html.text "Jenkins for CI" ]
                        ]
                    , Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-gitlab-plain" ] [] ]
                        , Html.p [] [ Html.text "Gitlab & Github for primary development platforms" ]
                        ]
                    ]
                ]
            ]
        , Html.div [ Attr.class "skill-tree-row" ]
            [ Html.div [ Attr.class "skill-tree-section" ]
                [ Html.h2 [] [ Html.text "Hobby Projects" ]
                , Html.ul []
                    [ Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-elm-plain" ] [] ]
                        , Html.p [] [ Html.text "Elm for web front-end development" ]
                        ]
                    , Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-haskell-plain" ] [] ]
                        , Html.p [] [ Html.text "Haskell to dive deep into functional programming" ]
                        ]
                    , Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-opengl-plain" ] [] ]
                        , Html.p [] [ Html.text "OpenGL, WGPU & Rust to learn graphics programming" ]
                        ]
                    , Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-markdown-original" ] [] ]
                        , Html.p [] [ Html.text "Building a second brain, presentations and notes" ]
                        ]
                    ]
                ]
            , Html.div [ Attr.class "skill-tree-section" ]
                [ Html.h2 [] [ Html.text "Daily Tools" ]
                , Html.ul []
                    [ Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-neovim-plain" ] [] ]
                        , Html.p [] [ Html.text "Neovim for editing most text" ]
                        ]
                    , Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-linux-plain" ] [] ]
                        , Html.p [] [ Html.text "Linux as primary development OS" ]
                        ]
                    , Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-bash-plain" ] [] ]
                        , Html.p [] [ Html.text "Nushell for command piping shenanigans" ]
                        ]
                    , Html.li []
                        [ Html.a [] [ Html.i [ Attr.class "devicon-firefox-plain" ] [] ]
                        , Html.p [] [ Html.text "Firefox to surf the web. Support browser diversity!" ]
                        ]
                    ]
                ]
            ]
        ]



-- Update --


type Msg
    = Ready (List Int)
    | WindowResized { width : Float, height : Float }
    | BoidsMsg Boids.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Ready directions ->
            let
                old =
                    model.drawingModel

                newDrawing =
                    { old | drawingDirections = Just directions }
            in
            ( { model | drawingModel = newDrawing }, Cmd.none )

        WindowResized dimensions ->
            let
                oldSettings =
                    model.drawingModel.settings

                newSettings =
                    { oldSettings | width = dimensions.width - model.scrollBarWidth, height = dimensions.height }

                oldDrawingModel =
                    model.drawingModel

                newDrawingModel =
                    { oldDrawingModel | settings = newSettings, drawingDirections = Nothing }

                oldBoidsModel =
                    model.boidsModel

                oldBoidsConfig =
                    oldBoidsModel.config

                newBoidsConfig =
                    { oldBoidsConfig | width = newSettings.width, height = newSettings.height }

                newBoidsModel =
                    { oldBoidsModel | config = newBoidsConfig }

                newModel =
                    { model | drawingModel = newDrawingModel, boidsModel = newBoidsModel }
            in
            ( newModel, Random.generate Ready <| TiledLines.generateDirections newSettings )

        BoidsMsg bMsg ->
            let
                ( newBoidsModel, bCmd ) =
                    Boids.update bMsg model.boidsModel
            in
            ( { model | boidsModel = newBoidsModel }, Cmd.map BoidsMsg bCmd )
