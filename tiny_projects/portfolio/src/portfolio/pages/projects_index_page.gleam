import blogatto/post.{type Post}
import gleam/dict
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

  let active_posts =
    list.filter(project_posts, fn(p) {
      dict.get(p.extras, "status") == Ok("active")
    })

  let finished_posts =
    list.filter(project_posts, fn(p) {
      dict.get(p.extras, "status") != Ok("active")
    })

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
          element.text("Active"),
        ]),
        project_section(active_posts),
        html.h2([attribute.class("c-post-list__heading")], [
          element.text("Finished & Abandoned"),
        ]),
        project_section(finished_posts),
      ]),
      layout.page_footer(),
    ]),
  ])
}

fn project_section(posts: List(Post(Nil))) -> Element(Nil) {
  case posts {
    [] ->
      html.p([attribute.class("c-post-list__empty")], [
        element.text("Nothing here yet"),
      ])
    _ ->
      html.ul(
        [attribute.class("c-post-list")],
        list.map(posts, post_card.post_card),
      )
  }
}
