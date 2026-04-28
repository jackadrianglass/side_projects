import blogatto/post.{type Post}
import gleam/list
import gleam/option
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import portfolio/components/layout

/// Blog post template: renders a full HTML page for a single blog post
/// with a navigation link back to the homepage.
pub fn template(p: Post(Nil), _all_posts: List(Post(Nil))) -> Element(Nil) {
  let lang = option.unwrap(p.language, "en")

  html.html([attribute.lang(lang)], [
    html.head(
      [],
      list.append(layout.page_head(p.title), [
        html.meta([
          attribute.name("description"),
          attribute.content(p.description),
        ]),
      ]),
    ),
    html.body([], [
      layout.top_nav([
        html.li([], [html.a([attribute.href("/")], [element.text("Home")])]),
        html.li([], [element.text("/")]),
        html.li([], [html.a([attribute.href("/blog/")], [element.text("Blog")])]),
        html.li([], [element.text("/")]),
        html.li([], [html.strong([], [element.text(p.title)])]),
      ]),
      html.main([], [
        html.article([], [
          html.h1([], [element.text(p.title)]),
          html.p([], [html.em([], [element.text(p.description)])]),
          html.div([], p.contents),
        ]),
      ]),
      layout.blogatto_footer(),
    ]),
  ])
}