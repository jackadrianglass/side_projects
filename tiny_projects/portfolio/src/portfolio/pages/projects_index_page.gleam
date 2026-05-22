import blogatto/post.{type Post}
import gleam/list
import gleam/time/timestamp
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import portfolio/components/layout

pub fn view(posts: List(Post(Nil))) -> Element(Nil) {
  let project_posts =
    posts
    |> list.filter(layout.is_project_post)
    |> list.sort(fn(a, b) { timestamp.compare(b.date, a.date) })

  html.html([attribute.lang("en")], [
    html.head([], layout.page_head("Projects")),
    html.body([attribute.class("page-projects-index")], [
      layout.top_nav(posts, [
        html.li([], [html.a([attribute.href("/")], [element.text("~")])]),
        html.li([], [element.text("/")]),
        html.li([], [html.strong([], [element.text("projects")])]),
      ]),
      html.main([], [
        html.h1([], [element.text("Projects")]),
        html.p([], [element.text("Updates and notes on side projects.")]),
        html.h2([attribute.class("c-post-list__heading")], [
          element.text("Updates"),
        ]),
        html.ul(
          [attribute.class("c-post-list")],
          list.map(project_posts, layout.post_card),
        ),
      ]),
      layout.page_footer(),
    ]),
  ])
}
