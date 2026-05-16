import blogatto/post.{type Post}
import gleam/list
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
        html.li([], [html.strong([], [element.text("Blog")])]),
      ]),
      html.header([attribute.class("c-blog-index-hero")], [
        html.h1([], [element.text("Simple Blog")]),
        html.p([], [
          element.text(
            "A simple example blog built with Blogatto with love <3.",
          ),
        ]),
      ]),
      html.main([attribute.class("l-content")], [
        html.h2([attribute.class("c-post-list__heading")], [
          element.text("Articles"),
        ]),
        html.ul(
          [attribute.class("c-post-list")],
          list.map(sorted_posts, fn(p) {
            html.li([attribute.class("c-post-list__item")], [
              html.a(
                [
                  attribute.href("/blog/" <> p.slug <> "/"),
                  attribute.class("c-post-list__title"),
                ],
                [
                  element.text(p.title),
                ],
              ),
              element.text(" — "),
              html.em([attribute.class("c-post-list__description")], [
                element.text(p.description),
              ]),
            ])
          }),
        ),
      ]),
      layout.blogatto_footer(),
    ]),
  ])
}
