import blogatto/post.{type Post}
import gleam/dict
import gleam/list
import gleam/option
import gleam/string
import gleam/time/timestamp
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import portfolio/components/layout

/// Blog index view: renders a list of all blog posts sorted by date
/// (newest first).
pub fn view(posts: List(Post(Nil))) -> Element(Nil) {
  // Sort posts newest first by comparing dates in reverse
  let sorted_posts =
    list.sort(posts, fn(a, b) { timestamp.compare(b.date, a.date) })

  html.html([attribute.lang("en")], [
    html.head([], layout.page_head("Simple Blog")),
    html.body([attribute.class("page-blog-index")], [
      layout.top_nav([
        html.li([], [html.a([attribute.href("/")], [element.text("~")])]),
        html.li([], [element.text("/")]),
        html.li([], [html.strong([], [element.text("blog")])]),
      ]),
      html.main([attribute.class("l-content")], [
        html.h1([], [element.text("Simple Blog")]),
        html.p([], [
          element.text(
            "A simple example blog built with Blogatto with love <3.",
          ),
        ]),
        html.h2([attribute.class("c-post-list__heading")], [
          element.text("Articles"),
        ]),
        html.ul(
          [attribute.class("c-post-list")],
          list.map(sorted_posts, fn(p) {
            let tldr =
              dict.get(p.extras, "tldr")
              |> option.from_result

            let tags =
              dict.get(p.extras, "tags")
              |> option.from_result
              |> option.map(parse_tags)
              |> option.unwrap([])

            html.li([attribute.class("c-post-list__item")], [
              html.article([attribute.class("c-post-card")], [
                html.a(
                  [
                    attribute.href("/blog/" <> p.slug <> "/"),
                    attribute.class("c-post-card__title"),
                  ],
                  [element.text(p.title)],
                ),
                case tldr {
                  option.Some(t) ->
                    html.p([attribute.class("c-post-card__tldr")], [
                      element.text(t),
                    ])
                  option.None -> element.none()
                },
                case tags {
                  [] -> element.none()
                  _ ->
                    html.ul(
                      [attribute.class("c-post-card__tags")],
                      list.map(tags, fn(tag) {
                        html.li([attribute.class("c-post-card__tag")], [
                          element.text(tag),
                        ])
                      }),
                    )
                },
              ]),
            ])
          }),
        ),
      ]),
      layout.page_footer(),
    ]),
  ])
}

/// Parse a raw YAML array string into a list of tag strings.
/// e.g. "[\"banana\", \"pancakes\"]" -> ["banana", "pancakes"]
fn parse_tags(raw: String) -> List(String) {
  raw
  |> string.drop_start(1)
  |> string.drop_end(1)
  |> string.split(",")
  |> list.map(fn(token) {
    token
    |> string.trim
    |> string.drop_start(1)
    |> string.drop_end(1)
  })
  |> list.filter(fn(t) { t != "" })
}
