import blogatto/post.{type Post}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import portfolio/components/layout

/// Home page view: renders the landing layout and boids sketch.
pub fn view(_posts: List(Post(Nil))) -> Element(Nil) {
  html.html([attribute.lang("en")], [
    html.head([], layout.page_head("Home")),
    html.body([attribute.class("page-home")], [
      layout.top_nav([
        html.li([], [html.strong([], [element.text("Home")])]),
      ]),
      html.main([attribute.class("l-screen-fill")], [
        html.section([attribute.class("c-home-hero")], [
          html.div([
            attribute.id("creative-widget"),
            attribute.class("c-home-hero__background"),
          ], []),
          html.div([attribute.class("c-home-hero__overlay")], [
            html.article([attribute.class("c-home-hero__card")], [
              html.h1([], [element.text("Jack Glass")]),
              html.p([attribute.class("c-home-hero__lead")], [
                element.text("Developer, tinkerer, and writer."),
              ]),
              html.div([attribute.class("c-home-hero__actions")], [
                html.a([attribute.href("/blog/")], [element.text("Blog")]),
                html.a([
                  attribute.href("https://github.com/jackadrianglass"),
                ], [element.text("GitHub")]),
              ]),
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