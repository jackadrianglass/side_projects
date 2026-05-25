import blogatto/post.{type Post}
import gleam/dict
import gleam/list
import gleam/option
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import portfolio/components/layout
import portfolio/components/nav
import portfolio/components/post_card

/// Blog post template: renders a full HTML page for a single blog post
/// with a navigation link back to the homepage.
pub fn template(p: Post(Nil), all_posts: List(Post(Nil))) -> Element(Nil) {
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
    html.body([attribute.class("page-blog-post")], [
      nav.top_nav(all_posts, {
        let #(section_href, section_label) = case post_card.is_project_post(p) {
          True -> #("/projects/", "projects")
          False -> #("/blog/", "blog")
        }
        [
          html.li([], [html.a([attribute.href("/")], [element.text("~")])]),
          html.li([], [element.text("/")]),
          html.li([], [
            html.a([attribute.href(section_href)], [element.text(section_label)]),
          ]),
          html.li([], [element.text("/")]),
          html.li([], [html.strong([], [element.text(p.slug)])]),
        ]
      }),
      html.main([attribute.class("l-content")], [
        html.article([attribute.class("c-post-content")], [
          html.h1([attribute.class("c-post-content__title")], [
            element.text(p.title),
          ]),
          html.p([attribute.class("c-post-content__description")], [
            html.em([], [element.text(p.description)]),
          ]),
          case dict.get(p.extras, "repo") {
            Ok(url) ->
              html.p([attribute.class("c-post-content__repo")], [
                element.text("Source code: "),
                html.a([attribute.href(url)], [element.text(url)]),
              ])
            Error(_) -> element.none()
          },
          html.div([attribute.class("c-post-content__body")], p.contents),
        ]),
      ]),
      layout.page_footer(),
    ]),
  ])
}
