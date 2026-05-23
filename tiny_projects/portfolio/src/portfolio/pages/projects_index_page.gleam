import blogatto/post.{type Post}
import gleam/list
import gleam/time/timestamp
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import portfolio/components/layout
import portfolio/components/nav
import portfolio/components/post_card

pub fn view(posts: List(Post(Nil))) -> Element(Nil) {
  let project_posts =
    posts
    |> list.filter(post_card.is_project_post)
    |> list.sort(fn(a, b) { timestamp.compare(b.date, a.date) })

  html.html([attribute.lang("en")], [
    html.head([], layout.page_head("Projects")),
    html.body([attribute.class("page-projects-index")], [
      nav.top_nav(posts, [
        html.li([], [html.a([attribute.href("/")], [element.text("~")])]),
        html.li([], [element.text("/")]),
        html.li([], [html.strong([], [element.text("projects")])]),
      ]),
      html.main([attribute.class("l-content")], [
        html.h1([], [element.text("Projects")]),
        html.p([], [element.text("In case you're curious as to what I'm working on at the moment, this is a running log of the side projects that I'm working on. They'll be a source of the blog posts, and where I'll be learning more about how computers work.")]),
        html.h2([attribute.class("c-post-list__heading")], [
          element.text("Updates"),
        ]),
        html.ul(
          [attribute.class("c-post-list")],
          list.map(project_posts, post_card.post_card),
        ),
      ]),
      layout.page_footer(),
    ]),
  ])
}
