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
  let blog_posts =
    posts
    |> list.filter(fn(p) { !post_card.is_project_post(p) })
    |> list.sort(fn(a, b) { timestamp.compare(b.date, a.date) })

  html.html([attribute.lang("en")], [
    html.head([], layout.page_head("Simple Blog")),
    html.body([attribute.class("page-blog-index")], [
      nav.top_nav(posts, [
        html.li([], [html.a([attribute.href("/")], [element.text("~")])]),
        html.li([], [element.text("/")]),
        html.li([], [html.strong([], [element.text("blog")])]),
      ]),
      html.main([attribute.class("l-content")], [
        html.h1([], [element.text("Musings of a Hobbyist")]),
        html.p([], [
          element.text(
            "It's a blog! I'll be writing about all my hobbies, and some little ideas that I encounter at work. We're talking about coding (of course), learning music, thoughts about working out, probably a rant or two, and some responses to the content that I want online.",
          ),
        ]),
        html.p([], [
          element.text(
            "I hope you enjoy! I'll endeavor to post monthly",
          ),
        ]),
        html.h2([attribute.class("c-post-list__heading")], [
          element.text("Posts"),
        ]),
        html.ul(
          [attribute.class("c-post-list")],
          list.map(blog_posts, post_card.post_card),
        ),
      ]),
      layout.page_footer(),
    ]),
  ])
}
