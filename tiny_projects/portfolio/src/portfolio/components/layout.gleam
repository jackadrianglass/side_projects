import blogatto/post.{type Post}
import gleam/list
import gleam/time/timestamp
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn top_nav(
  posts: List(Post(Nil)),
  breadcrumb_items: List(Element(Nil)),
) -> Element(Nil) {
  let recent =
    posts
    |> list.sort(fn(a, b) { timestamp.compare(b.date, a.date) })
    |> list.take(3)

  html.nav([attribute.class("c-site-nav")], [
    html.div([attribute.class("c-site-nav__left")], [
      html.button(
        [
          attribute.id("site-tree-toggle"),
          attribute.class("c-site-nav__tree-btn"),
          attribute.attribute("aria-label", "Site navigation"),
        ],
        [tree_icon()],
      ),
      html.span([attribute.class("c-site-nav__sep")], [element.text("|")]),
      html.ul([attribute.class("c-site-nav__crumbs")], breadcrumb_items),
    ]),
    html.nav([attribute.class("c-site-nav__links")], [
      html.a([attribute.href("/blog/")], [element.text("Blog")]),
      html.a([attribute.href("/cv/")], [element.text("CV")]),
    ]),
    html.div(
      [
        attribute.id("site-tree-dropdown"),
        attribute.class("c-site-nav__tree-dropdown"),
      ],
      [tree_pre(recent)],
    ),
  ])
}

pub fn page_head(title: String) -> List(Element(Nil)) {
  [
    html.meta([attribute.charset("UTF-8")]),
    html.meta([
      attribute.name("viewport"),
      attribute.content("width=device-width, initial-scale=1"),
    ]),
    html.title([], title),
    html.link([
      attribute.rel("stylesheet"),
      attribute.href(
        "https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css",
      ),
    ]),
    html.link([
      attribute.rel("stylesheet"),
      attribute.href("/css/style.css"),
    ]),
    html.link([
      attribute.rel("apple-touch-icon"),
      attribute.sizes("180x180"),
      attribute.href("/apple-touch-icon.png"),
    ]),
    html.link([
      attribute.rel("icon"),
      attribute.type_("image/png"),
      attribute.sizes("32x32"),
      attribute.href("/favicon-32x32.png"),
    ]),
    html.link([
      attribute.rel("icon"),
      attribute.type_("image/png"),
      attribute.sizes("16x16"),
      attribute.href("favicon-16x16.png"),
    ]),
    html.link([
      attribute.rel("manifest"),
      attribute.href("/site.webmanifest"),
    ]),
    html.script(
      [attribute.src("/js/site_nav.js"), attribute.attribute("defer", "")],
      "",
    ),
  ]
}

pub fn tag_list(tags: List(String)) -> Element(Nil) {
  html.ul(
    [attribute.class("c-tag-list")],
    list.map(tags, fn(tag) {
      html.li([attribute.class("c-tag")], [element.text(tag)])
    }),
  )
}

pub fn page_footer() -> Element(Nil) {
  html.footer([attribute.class("c-site-footer")], [
    html.div([attribute.class("c-site-footer__inner")], [
      html.span([attribute.class("c-site-footer__name")], [
        element.text("Jack Glass"),
      ]),
      html.span([attribute.class("c-site-footer__sep")], [
        element.text("|"),
      ]),
      html.nav([attribute.class("c-site-footer__links")], [
        html.a([attribute.href("https://github.com/jackadrianglass")], [
          element.text("GitHub"),
        ]),
        html.a([attribute.href("/blog/")], [element.text("Blog")]),
      ]),
    ]),
  ])
}

fn tree_icon() -> Element(Nil) {
  element.element(
    "svg",
    [
      attribute.attribute("viewBox", "0 0 24 24"),
      attribute.attribute("width", "16"),
      attribute.attribute("height", "16"),
      attribute.attribute("fill", "none"),
      attribute.attribute("stroke", "currentColor"),
      attribute.attribute("stroke-width", "2"),
      attribute.attribute("stroke-linecap", "round"),
      attribute.attribute("stroke-linejoin", "round"),
      attribute.attribute("aria-hidden", "true"),
    ],
    [
      element.element(
        "line",
        [
          attribute.attribute("x1", "6"),
          attribute.attribute("y1", "3"),
          attribute.attribute("x2", "6"),
          attribute.attribute("y2", "15"),
        ],
        [],
      ),
      element.element(
        "circle",
        [
          attribute.attribute("cx", "18"),
          attribute.attribute("cy", "6"),
          attribute.attribute("r", "3"),
        ],
        [],
      ),
      element.element(
        "circle",
        [
          attribute.attribute("cx", "6"),
          attribute.attribute("cy", "18"),
          attribute.attribute("r", "3"),
        ],
        [],
      ),
      element.element(
        "path",
        [attribute.attribute("d", "M18 9a9 9 0 0 1-9 9")],
        [],
      ),
    ],
  )
}

fn tree_pre(posts: List(Post(Nil))) -> Element(Nil) {
  html.pre(
    [attribute.class("c-site-tree")],
    list.flatten([
      [
        html.a(
          [attribute.href("/"), attribute.title("Home page")],
          [element.text("~")],
        ),
        element.text("\n"),
      ],
      [
        element.text("├── "),
        html.a(
          [attribute.href("/blog/"), attribute.title("Browse all posts")],
          [element.text("blog/")],
        ),
        element.text("\n"),
      ],
      tree_post_items(posts),
      [
        element.text("└── "),
        html.a(
          [attribute.href("/cv/"), attribute.title("CV and work history")],
          [element.text("cv")],
        ),
      ],
    ]),
  )
}

fn tree_post_items(posts: List(Post(Nil))) -> List(Element(Nil)) {
  let n = list.length(posts)
  posts
  |> list.index_map(fn(post, i) {
    let prefix = case i == n - 1 {
      True -> "│   └── "
      False -> "│   ├── "
    }
    [
      element.text(prefix),
      html.a(
        [
          attribute.href("/blog/" <> post.slug <> "/"),
          attribute.title(post.description),
        ],
        [element.text(post.title)],
      ),
      element.text("\n"),
    ]
  })
  |> list.flatten
}
