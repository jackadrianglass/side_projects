import blogatto/post.{type Post}
import gleam/dict
import gleam/list
import gleam/time/timestamp
import lustre/attribute as attr
import lustre/element.{type Element}
import lustre/element/html
import portfolio/components/layout
import portfolio/components/nav
import portfolio/components/post_card

pub fn view(posts: List(Post(Nil))) -> Element(Nil) {
  let sorted = list.sort(posts, fn(a, b) { timestamp.compare(b.date, a.date) })

  let latest_blog_posts =
    sorted
    |> list.filter(fn(p) { !post_card.is_project_post(p) })
    |> list.take(3)

  let active_projects =
    sorted
    |> list.filter(post_card.is_project_post)
    |> list.filter(fn(p) { dict.get(p.extras, "status") == Ok("active") })

  html.html([attr.lang("en")], [
    html.head([], layout.page_head("Home")),
    html.body([attr.class("page-home")], [
      nav.top_nav(posts, [
        html.li([], [html.a([attr.href("/")], [element.text("~")])]),
      ]),
      html.main([], [
        hero(),
        html.div([attr.class("l-content")], [
          about(),
          latest_post_section(latest_blog_posts),
          active_projects_section(active_projects),
        ]),
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

fn active_projects_section(projects: List(Post(Nil))) -> Element(Nil) {
  case projects {
    [] -> element.none()
    _ ->
      html.section([attr.class("c-card-section")], [
        html.h2([], [element.text("Active Projects")]),
        html.ul(
          [attr.class("c-post-list")],
          list.map(projects, post_card.post_card),
        ),
        html.a([attr.href("/projects/")], [element.text("See All...")]),
      ])
  }
}

fn latest_post_section(posts: List(Post(Nil))) -> Element(Nil) {
  html.section([attr.class("c-card-section")], [
    html.h2([], [element.text("Latest Posts")]),
    html.ul(
      [attr.class("c-post-list")],
      list.map(posts, post_card.post_card),
    ),
    html.a([attr.href("/blog/")], [element.text("See All...")]),
  ])
}

fn about() -> Element(Nil) {
  html.section([attr.class("c-card-section")], [
    html.h2([], [element.text("About")]),
    html.div(
      [attr.style("display", "flex"), attr.style("align-items", "center"), attr.style("gap", "1.5rem")],
      [
        html.img([
          attr.class("c-headshot"),
          attr.src("images/headshot.jpg"),
          attr.alt("My fricken face"),
        ]),
        html.div([], [
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
      ],
    ),
    html.h2([], [element.text("Work With Me")]),
    html.p([], [
      element.text(
        "Want to get in touch? Interested in working with me? I'm equally happy to connect with anyone who wants to nerd out about programming, swap notes on projects, or just chat. Checkout my ",
      ),
      html.a([attr.href("/cv/"), attr.class("c-button")], [
        element.text("CV"),
      ]),
      element.text(" or shoot me an "),
      html.a(
        [
          attr.href("mailto:jack.glass.contact@proton.me"),
          attr.class("c-button"),
        ],
        [element.text("email.")],
      ),
    ]),
  ])
}
