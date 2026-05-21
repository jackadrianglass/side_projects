import blogatto/post.{type Post}
import gleam/list
import gleam/time/timestamp
import lustre/attribute as attr
import lustre/element.{type Element}
import lustre/element/html
import portfolio/components/layout

pub fn view(posts: List(Post(Nil))) -> Element(Nil) {
  html.html([attr.lang("en")], [
    html.head([], layout.page_head("Home")),
    html.body([attr.class("page-home")], [
      layout.top_nav([
        html.li([], [html.a([attr.href("/")], [element.text("~")])]),
      ]),
      html.main([], [
        hero(),
        about(),
        latest_posts(posts),
      ]),
      layout.page_footer(),
      html.script(
        [
          attr.src("https://cdn.jsdelivr.net/npm/p5@2.2.3/lib/p5.js"),
        ],
        "",
      ),
      html.script([attr.src("/js/sketches/boids.js")], ""),
    ]),
  ])
}

fn hero() -> Element(Nil) {
  html.section([attr.class("c-home-hero")], [
    html.div(
      [
        attr.id("creative-widget"),
        attr.class("c-home-hero__background"),
      ],
      [],
    ),
    html.div([attr.class("c-home-hero__overlay")], [
      html.article([attr.class("c-home-hero__card")], [
        html.h1([], [element.text("Jack Glass")]),
      ]),
    ]),
  ])
}

fn about() -> Element(Nil) {
  html.section([attr.class("c-card-section")], [

    html.div([attr.style("display", "flex"), attr.style("align-children", "center")], [
      html.img([
        attr.class("c-headshot"),
        attr.src("images/headshot.jpg"),
        attr.alt("My fricken face"),
      ]),

      html.div([], [
      html.h2([], [element.text("About")]),
      html.p([], [
        element.text(
          "I'm a Canadian programmer with a love for learning, novel programming languages, and well designed software. One could say that I'm trying to live up to \"Jack of all trades, master of none but often better than master of one\". I love programming, weight lifting, biking, playing drums and the guitar, and everything else.",
        ),
      ]),

      html.p([], [
        element.text(
          "Welcome to my little corner of the internet where I'm hoping to share my thoughts about all of it with you",
        ),
      ]),
      ]),
    ]),
  ])
}

fn latest_posts(posts: List(Post(Nil))) -> Element(Nil) {
  let latest_posts =
    posts
    |> list.sort(fn(a, b) { timestamp.compare(b.date, a.date) })
    |> list.take(3)

  html.section(
    [
      attr.class("c-card-section"),
    ],
    [
      html.h2([], [element.text("Latest Blog Posts")]),
      case latest_posts {
        [] ->
          html.p([attr.class("c-home-latest-posts__empty")], [
            element.text(
              "Huh... I guess I haven't written anything yet. Stayed tuned!",
            ),
          ])
        _ ->
          html.ul(
            [attr.class("c-post-list")],
            list.map(posts, fn(post) {
              html.li([attr.class("c-post-card")], [
                html.a(
                  [
                    attr.href("/blog/" <> post.slug <> "/"),
                    attr.class("c-post-card__title"),
                  ],
                  [
                    element.text(post.title),
                  ],
                ),
                html.p([attr.class("c-post-card__tldr")], [
                  element.text(post.description),
                ]),
              ])
            }),
          )
      },
    ],
  )
}
