import blogatto/post.{type Post}
import gleam/list
import gleam/time/timestamp
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import portfolio/components/post_card

pub fn top_nav(
  posts: List(Post(Nil)),
  breadcrumb_items: List(Element(Nil)),
) -> Element(Nil) {
  let sorted = list.sort(posts, fn(a, b) { timestamp.compare(b.date, a.date) })

  let recent_blog =
    sorted
    |> list.filter(fn(p) { !post_card.is_project_post(p) })
    |> list.take(3)

  let recent_projects =
    sorted
    |> list.filter(post_card.is_project_post)
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
      tree_post_items(blog_posts, "/pages/"),
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
      tree_post_items(project_posts, "/pages/"),
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

fn tree_post_items(
  posts: List(Post(Nil)),
  base_path: String,
) -> List(Element(Nil)) {
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
          attribute.href(base_path <> post.slug <> "/"),
          attribute.title(post.description),
        ],
        [element.text(post.title)],
      ),
      element.text("\n"),
    ]
  })
  |> list.flatten
}
