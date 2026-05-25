import blogatto/post.{type Post}
import gleam/dict
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
    |> list.filter(fn(p) { dict.get(p.extras, "status") == Ok("active") })
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
    social_links(),
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

pub fn social_links() -> Element(Nil) {
  html.div([attribute.class("c-social-links")], [
    html.a(
      [
        attribute.href("https://github.com/jackadrianglass"),
        attribute.attribute("aria-label", "GitHub"),
        attribute.attribute("target", "_blank"),
        attribute.attribute("rel", "noopener noreferrer"),
      ],
      [github_icon()],
    ),
    html.a(
      [
        attribute.href("https://www.linkedin.com/in/jack-glass-561944129/"),
        attribute.attribute("aria-label", "LinkedIn"),
        attribute.attribute("target", "_blank"),
        attribute.attribute("rel", "noopener noreferrer"),
      ],
      [linkedin_icon()],
    ),
    html.a(
      [
        attribute.href("mailto:jack.glass.contact@proton.me"),
        attribute.attribute("aria-label", "Email"),
      ],
      [email_icon()],
    ),
  ])
}

fn github_icon() -> Element(Nil) {
  element.element(
    "svg",
    [
      attribute.attribute("viewBox", "0 0 24 24"),
      attribute.attribute("width", "18"),
      attribute.attribute("height", "18"),
      attribute.attribute("fill", "currentColor"),
      attribute.attribute("aria-hidden", "true"),
    ],
    [
      element.element(
        "path",
        [
          attribute.attribute(
            "d",
            "M12 0.297c-6.63 0-12 5.373-12 12c0 5.303 3.438 9.8 8.205 11.385c.6.113.82-.258.82-.577c0-.285-.01-1.04-.015-2.04c-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729c1.205.084 1.838 1.236 1.838 1.236c1.07 1.835 2.809 1.305 3.495.998c.108-.776.417-1.305.76-1.605c-2.665-.3-5.466-1.332-5.466-5.93c0-1.31.465-2.38 1.235-3.22c-.135-.303-.54-1.523.105-3.176c0 0 1.005-.322 3.3 1.23c.96-.267 1.98-.399 3-.405c1.02.006 2.04.138 3 .405c2.28-1.552 3.285-1.23 3.285-1.23c.645 1.653.24 2.873.12 3.176c.765.84 1.23 1.91 1.23 3.22c0 4.61-2.805 5.625-5.475 5.92c.42.36.81 1.096.81 2.22c0 1.606-.015 2.896-.015 3.286c0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12",
          ),
        ],
        [],
      ),
    ],
  )
}

fn linkedin_icon() -> Element(Nil) {
  element.element(
    "svg",
    [
      attribute.attribute("viewBox", "0 0 24 24"),
      attribute.attribute("width", "18"),
      attribute.attribute("height", "18"),
      attribute.attribute("fill", "currentColor"),
      attribute.attribute("aria-hidden", "true"),
    ],
    [
      element.element(
        "path",
        [
          attribute.attribute(
            "d",
            "M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z",
          ),
        ],
        [],
      ),
    ],
  )
}

fn email_icon() -> Element(Nil) {
  element.element(
    "svg",
    [
      attribute.attribute("viewBox", "0 0 24 24"),
      attribute.attribute("width", "18"),
      attribute.attribute("height", "18"),
      attribute.attribute("fill", "currentColor"),
      attribute.attribute("aria-hidden", "true"),
    ],
    [
      element.element(
        "path",
        [
          attribute.attribute(
            "d",
            "M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z",
          ),
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
