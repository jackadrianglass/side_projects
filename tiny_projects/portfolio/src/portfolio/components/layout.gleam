import blogatto/post.{type Post}
import gleam/dict
import gleam/list
import gleam/option
import gleam/string
import gleam/time/timestamp
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn top_nav(
  posts: List(Post(Nil)),
  breadcrumb_items: List(Element(Nil)),
) -> Element(Nil) {
  let sorted = list.sort(posts, fn(a, b) { timestamp.compare(b.date, a.date) })

  let recent_blog =
    sorted
    |> list.filter(fn(p) { !is_project_post(p) })
    |> list.take(3)

  let recent_projects =
    sorted
    |> list.filter(is_project_post)
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
      html.a([attribute.href("/projects/")], [element.text("Projects")]),
      html.a([attribute.href("/cv/")], [element.text("CV")]),
    ]),
    html.div(
      [
        attribute.id("site-tree-dropdown"),
        attribute.class("c-site-nav__tree-dropdown"),
      ],
      [tree_pre(recent_blog, recent_projects)],
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

/// Parse a raw YAML array string into a list of tag strings.
/// e.g. "[\"banana\", \"pancakes\"]" -> ["banana", "pancakes"]
pub fn parse_tags(raw: String) -> List(String) {
  raw
  |> string.drop_start(1)
  |> string.drop_end(1)
  |> string.split(",")
  |> list.map(fn(token) {
    token
    |> string.trim
    |> string.drop_start(1)
    |> string.drop_end(1)
  })
  |> list.filter(fn(t) { t != "" })
}

/// Returns True if the post has type: project in its frontmatter.
pub fn is_project_post(p: Post(Nil)) -> Bool {
  dict.get(p.extras, "type") == Ok("project")
}

/// Renders a single post card for use in index/list pages.
pub fn post_card(p: Post(Nil)) -> Element(Nil) {
  let tldr =
    dict.get(p.extras, "tldr")
    |> option.from_result

  let tags =
    dict.get(p.extras, "tags")
    |> option.from_result
    |> option.map(parse_tags)
    |> option.unwrap([])

  html.li([attribute.class("c-post-list__item")], [
    html.article([attribute.class("c-post-card")], [
      html.a(
        [
          attribute.href("/blog/" <> p.slug <> "/"),
          attribute.class("c-post-card__title"),
        ],
        [element.text(p.title)],
      ),
      case tldr {
        option.Some(t) ->
          html.p([attribute.class("c-post-card__tldr")], [element.text(t)])
        option.None -> element.none()
      },
      case tags {
        [] -> element.none()
        _ -> tag_list(tags)
      },
    ]),
  ])
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
      attribute.attribute("width", "18"),
      attribute.attribute("height", "18"),
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
          attribute.attribute("x1", "3"),
          attribute.attribute("y1", "6"),
          attribute.attribute("x2", "21"),
          attribute.attribute("y2", "6"),
        ],
        [],
      ),
      element.element(
        "line",
        [
          attribute.attribute("x1", "3"),
          attribute.attribute("y1", "12"),
          attribute.attribute("x2", "21"),
          attribute.attribute("y2", "12"),
        ],
        [],
      ),
      element.element(
        "line",
        [
          attribute.attribute("x1", "3"),
          attribute.attribute("y1", "18"),
          attribute.attribute("x2", "21"),
          attribute.attribute("y2", "18"),
        ],
        [],
      ),
    ],
  )
}

fn tree_pre(
  blog_posts: List(Post(Nil)),
  project_posts: List(Post(Nil)),
) -> Element(Nil) {
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
      tree_post_items(blog_posts),
      [
        element.text("├── "),
        html.a(
          [
            attribute.href("/projects/"),
            attribute.title("Side project updates"),
          ],
          [element.text("projects/")],
        ),
        element.text("\n"),
      ],
      tree_post_items(project_posts),
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
