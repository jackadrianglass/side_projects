module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Boids
import Browser.Events as Events
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import FeatherIcons as Icons
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Pages.Url
import PagesMsg exposing (PagesMsg)
import Random
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import Theme
import TiledLines
import UrlPath exposing (UrlPath)
import View exposing (View)


type alias Icon =
    Html Msg


type alias Model =
    { drawingModel : TiledLines.Model
    , boidsModel : Boids.Model
    , showSettings : Bool
    }


type Msg
    = Ready (List Int)
    | WindowResized { width : Float, height : Float }
    | BoidsMsg Boids.Msg
    | ToggleSettings


type alias RouteParams =
    {}


type alias Data =
    {}


type alias ActionData =
    {}


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


init :
    App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect Msg )
init _ shared =
    let
        drawingSettings : TiledLines.Settings
        drawingSettings =
            { width = shared.windowWidth - shared.scrollBarWidth
            , height = shared.windowHeight
            , stepSize = 20
            , strokeColor = Theme.theme.highlightHigh
            , backgroundColor = Theme.theme.base
            }

        ( initialBoidsModel, boidsCmd ) =
            let
                defaultConfig =
                    Boids.defaultConfig
            in
            Boids.init
                { defaultConfig
                    | boidColor = Theme.theme.rose
                    , backgroundColor = Nothing
                    , width = drawingSettings.width
                    , height = drawingSettings.height
                }

        model : Model
        model =
            { drawingModel = { settings = drawingSettings, drawingDirections = Nothing }
            , boidsModel = initialBoidsModel
            , showSettings = False
            }
    in
    ( model
    , Effect.batch
        [ Random.generate Ready (TiledLines.generateDirections drawingSettings) |> Effect.fromCmd
        , Effect.fromCmd boidsCmd |> Effect.map BoidsMsg
        ]
    )


update :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect Msg )
update _ shared msg model =
    case msg of
        ToggleSettings ->
            ( { model | showSettings = not model.showSettings }, Effect.none )

        Ready directions ->
            let
                old =
                    model.drawingModel

                newDrawing =
                    { old | drawingDirections = Just directions }
            in
            ( { model | drawingModel = newDrawing }, Effect.none )

        WindowResized dimensions ->
            let
                oldSettings =
                    model.drawingModel.settings

                newSettings =
                    { oldSettings | width = dimensions.width - shared.scrollBarWidth, height = dimensions.height }

                oldDrawingModel =
                    model.drawingModel

                newDrawingModel =
                    { oldDrawingModel | settings = newSettings, drawingDirections = Nothing }

                ( newBoidsModel, boidsCmd ) =
                    Boids.update (Boids.Resize newSettings.width newSettings.height) model.boidsModel

                newModel =
                    { model | drawingModel = newDrawingModel, boidsModel = newBoidsModel }
            in
            ( newModel
            , Effect.batch
                [ Random.generate Ready (TiledLines.generateDirections newSettings) |> Effect.fromCmd
                , Effect.fromCmd boidsCmd |> Effect.map BoidsMsg
                ]
            )

        BoidsMsg bMsg ->
            let
                ( newBoidsModel, bCmd ) =
                    Boids.update bMsg model.boidsModel
            in
            ( { model | boidsModel = newBoidsModel }, Effect.fromCmd bCmd |> Effect.map BoidsMsg )


subscriptions :
    RouteParams
    -> UrlPath
    -> Shared.Model
    -> Model
    -> Sub Msg
subscriptions _ _ _ _ =
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


data : BackendTask FatalError Data
data =
    BackendTask.succeed {}


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head _ =
    [ Head.canonicalLink (Just "https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap")
    , Head.canonicalLink (Just "https://cdn.jsdelivr.net/gh/devicons/devicon@latest/devicon.min.css")
    , Head.canonicalLink (Just "/style.css")
    ]
        ++ (Seo.summary
                { canonicalUrlOverride = Nothing
                , siteName = "Jack Glass"
                , image =
                    { url = Pages.Url.external "headshot.png"
                    , alt = "Jack Glass headshot"
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = "Jack Glass - Software Engineer"
                , locale = Nothing
                , title = "Jack Glass"
                }
                |> Seo.website
           )


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view _ _ model =
    { title = "Jack Glass"
    , body =
        [ Html.div []
            [ splashScreen model
            , if model.showSettings then
                Html.div [ Attr.class "settings-overlay" ]
                    [ Html.div [ Attr.class "settings-menu" ]
                        [ Html.div [ Attr.class "settings-header" ]
                            [ Html.h2 [] [ Html.text "Boid Settings" ]
                            , Html.button [ Attr.class "close-button", Html.Events.onClick ToggleSettings ] [ Icons.toHtml [] Icons.x ]
                            ]
                        , Html.map BoidsMsg (Boids.viewSettings model.boidsModel.config)
                        ]
                    ]

              else
                Html.text ""
            , Html.br [] []
            , Html.br [] []
            , about
            , Html.br [] []
            , Html.br [] []
            , skills
            ]
        ]
            |> List.map (Html.map PagesMsg.fromMsg)
    }


linkTreeIcon : Icons.Icon -> String -> Html Msg
linkTreeIcon icon url =
    Html.a [ Attr.href url ]
        [ Icons.toHtml [] icon
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
        , if not model.showSettings then
            Html.button [ Attr.class "settings-toggle", Html.Events.onClick ToggleSettings ]
                [ Icons.toHtml [] Icons.settings ]

          else
            Html.text ""
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
            , Html.p []
                [ Html.text """
I'm also actively involved in the Calgary software community. I host a weekly coworking
session as a recurring space for folks to work on their side projects. I'm also involved
with the Software Developers of Calgary group helping host a monthly meetup to help working
developers hone their craft.
            """
                ]
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
