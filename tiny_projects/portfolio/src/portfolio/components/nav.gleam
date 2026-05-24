import blogatto/post.{type Post}
import gleam/list
import gleam/time/timestamp
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import portfolio/components/post_card

pub type TreeNode {
  TreeNode(label: String, href: String, children: List(TreeNode))
}

pub fn tree(label: String, href: String, nodes: List(TreeNode)) -> Element(Nil) {
  let root = html.a([attribute.href(href)], [element.text(label)])
  html.pre(
    [attribute.class("c-site-tree")],
    list.flatten([[root, element.text("\n")], render_nodes(nodes, "")]),
  )
}

fn render_nodes(nodes: List(TreeNode), indent: String) -> List(Element(Nil)) {
  let count = list.length(nodes)
  nodes
  |> list.index_map(fn(node, i) {
    let is_last = i == count - 1
    let prefix = case is_last {
      True -> indent <> "└── "
      False -> indent <> "├── "
    }
    let child_indent = case is_last {
      True -> indent <> "    "
      False -> indent <> "│   "
    }
    let link = html.a([attribute.href(node.href)], [element.text(node.label)])
    list.flatten([
      [element.text(prefix), link, element.text("\n")],
      render_nodes(node.children, child_indent),
    ])
  })
  |> list.flatten
}

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
  let post_node = fn(p: Post(Nil)) {
    TreeNode(p.title, "/pages/" <> p.slug <> "/", [])
  }
  tree("~", "/", [
    TreeNode("blog/", "/blog/", list.map(blog_posts, post_node)),
    TreeNode("projects/", "/projects/", list.map(project_posts, post_node)),
    TreeNode("cv", "/cv/", []),
  ])
}
