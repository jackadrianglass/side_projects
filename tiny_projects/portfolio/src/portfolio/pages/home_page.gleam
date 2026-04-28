import blogatto/post.{type Post}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import portfolio/components/layout

/// Home page view: renders the landing layout and boids sketch.
pub fn view(_posts: List(Post(Nil))) -> Element(Nil) {
  html.html([attribute.lang("en")], [
    html.head([], layout.page_head("Home")),
    html.body([attribute.class("home-page")], [
      layout.top_nav([
        html.li([], [html.strong([], [element.text("Home")])]),
      ]),
      html.main([attribute.class("home-main")], [
        html.section([attribute.class("home-hero")], [
          html.div([
            attribute.id("creative-widget"),
            attribute.class("home-hero__background"),
          ], []),
          html.div([attribute.class("home-hero__overlay")], [
            html.article([attribute.class("home-hero__card")], [
              html.h1([], [element.text("Jack Glass")]),
            ]),
          ]),
        ]),
      ]),
      html.script(
        [
          attribute.src("https://cdn.jsdelivr.net/npm/p5@2.2.3/lib/p5.js"),
        ],
        "",
      ),
      html.script([attribute.src("/js/sketches/boids.js")], ""),
    ]),
  ])
}