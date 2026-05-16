import blogatto/post.{type Post}
import gleam/list
import gleam/time/timestamp
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import portfolio/components/layout

fn take_posts(posts: List(a), count: Int) -> List(a) {
  case count <= 0 {
    True -> []
    False ->
      case posts {
        [] -> []
        [first, ..rest] -> [first, ..take_posts(rest, count - 1)]
      }
  }
}

fn latest_posts(posts: List(Post(Nil))) -> List(Post(Nil)) {
  posts
  |> list.sort(fn(a, b) { timestamp.compare(b.date, a.date) })
  |> take_posts(3)
}

fn latest_posts_preview(posts: List(Post(Nil))) -> Element(Nil) {
  case posts {
    [] ->
      html.p([attribute.class("c-home-latest-posts__empty")], [
        element.text(
          "Huh... I guess I haven't written anything yet. Stayed tuned!",
        ),
      ])
    _ ->
      html.ul(
        [attribute.class("c-home-latest-posts")],
        list.map(posts, fn(post) {
          html.li([attribute.class("c-home-latest-posts__item")], [
            html.a(
              [
                attribute.href("/blog/" <> post.slug <> "/"),
                attribute.class("c-home-latest-posts__title"),
              ],
              [
                element.text(post.title),
              ],
            ),
            html.p([attribute.class("c-home-latest-posts__description")], [
              element.text(post.description),
            ]),
          ])
        }),
      )
  }
}

/// Home page view: renders the landing layout and boids sketch.
pub fn view(posts: List(Post(Nil))) -> Element(Nil) {
  let featured_posts = latest_posts(posts)

  html.html([attribute.lang("en")], [
    html.head([], layout.page_head("Home")),
    html.body([attribute.class("page-home")], [
      layout.top_nav([
        html.li([], [html.a([attribute.href("/")], [element.text("~")])]),
      ]),
      html.main([attribute.class("page-home__main")], [
        html.section([attribute.class("c-home-hero")], [
          html.div(
            [
              attribute.id("creative-widget"),
              attribute.class("c-home-hero__background"),
            ],
            [],
          ),
          html.div([attribute.class("c-home-hero__overlay")], [
            html.article([attribute.class("c-home-hero__card")], [
              html.h1([], [element.text("Jack Glass")]),
              html.p([attribute.class("c-home-hero__lead")], [
                element.text("Developer, tinkerer, and writer."),
              ]),
              html.div([attribute.class("c-home-hero__actions")], [
                html.a([attribute.href("/blog/")], [element.text("Blog")]),
                html.a(
                  [
                    attribute.href("https://github.com/jackadrianglass"),
                  ],
                  [element.text("GitHub")],
                ),
              ]),
            ]),
          ]),
        ]),
        html.div([attribute.class("l-content c-home-sections")], [
          html.section(
            [attribute.class("c-home-section c-home-section--about")],
            [
              html.h2([], [element.text("About")]),
              html.p([], [
                element.text(
                  "Use this section to introduce who you are as a developer in your own voice.",
                ),
              ]),
              html.ul([], [
                html.li([], [
                  element.text(
                    "Prompt: What kind of software problems do you enjoy solving most?",
                  ),
                ]),
                html.li([], [
                  element.text(
                    "Prompt: What principles shape how you build and learn?",
                  ),
                ]),
                html.li([], [
                  element.text(
                    "Prompt: What should a first-time visitor remember about you after this page?",
                  ),
                ]),
              ]),
            ],
          ),
          html.section(
            [
              attribute.class("c-home-section c-home-section--latest-posts"),
            ],
            [
              html.h2([], [element.text("Latest Blog Posts")]),
              html.p([], [
                element.text(
                  "This section previews your newest writing so visitors can jump directly into your ideas.",
                ),
              ]),
              latest_posts_preview(featured_posts),
            ],
          ),
        ]),
      ]),
      layout.page_footer(),
      html.script(
        [
          attribute.src("https://cdn.jsdelivr.net/npm/p5@2.2.3/lib/p5.js"),
        ],
        "",
      ),
      html.script([attribute.src("/js/sketches/boids.js")], ""),
    ]),
  ])
}
