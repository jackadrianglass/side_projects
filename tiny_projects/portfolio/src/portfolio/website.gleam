import blogatto/config
import blogatto/config/feed
import blogatto/config/markdown
import blogatto/config/markdown/code
import blogatto/config/robots
import blogatto/config/sitemap
import blogatto/post.{type Post}
import gleam/list
import gleam/option
import gleam/time/timestamp
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import smalto/lustre/themes

const site_url = "https://jackadrianglass.github.io"

fn top_nav(breadcrumb_items: List(Element(Nil))) -> Element(Nil) {
  html.nav([], [
    html.ul([], breadcrumb_items),
    html.ul([], [
      html.li([], [html.a([attribute.href("/")], [element.text("Home")])]),
      html.li([], [
        html.a([attribute.href("/blog/")], [element.text("Blog")]),
      ]),
    ]),
  ])
}

fn page_head(title: String) -> List(Element(Nil)) {
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
  ]
}

pub fn config() -> config.Config(Nil) {
  // Syntax highlighting configuration using CSS classes
  let syntax_config =
    code.default()
    |> code.smalto_config(themes.material_dark())

  // Markdown configuration: search the blog/ directory for posts
  let md_config =
    markdown.default()
    |> markdown.markdown_path("./blog")
    |> markdown.route_prefix("blog")
    |> markdown.template(blog_post_template)
    |> markdown.syntax_highlighting(syntax_config)
    |> markdown.pre(fn(children) {
      html.pre([attribute.class("code-block")], children)
    })
    |> markdown.code(fn(language, children) {
      let lang_class = case language {
        option.Some(lang) -> "language-" <> lang
        option.None -> ""
      }
      html.code([attribute.class(lang_class)], children)
    })

  // RSS feed configuration
  let rss =
    feed.new(
      "Simple Blog",
      site_url,
      "A simple example blog built with Blogatto",
    )
    |> feed.language("en-us")
    |> feed.generator("Blogatto")

  // Sitemap configuration
  let sitemap_config = sitemap.new("/sitemap.xml")

  // Robots.txt configuration
  let robots_config =
    robots.RobotsConfig(sitemap_url: site_url <> "/sitemap.xml", robots: [
      robots.Robot(
        user_agent: "*",
        allowed_routes: ["/"],
        disallowed_routes: [],
      ),
    ])

  // Build the full site configuration

  config.new(site_url)
  |> config.output_dir("./dist")
  |> config.static_dir("./static")
  |> config.markdown(md_config)
  |> config.route("/", home_view)
  |> config.route("/blog/", blog_index_view)
  |> config.feed(rss)
  |> config.sitemap(sitemap_config)
  |> config.robots(robots_config)
}

/// Home page view: renders the landing layout and boids sketch.
fn home_view(_posts: List(Post(Nil))) -> Element(Nil) {
  html.html([attribute.lang("en")], [
    html.head([], page_head("Home")),
    html.body([attribute.class("home-page")], [
      top_nav([
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

/// Blog index view: renders a list of all blog posts sorted by date
/// (newest first).
fn blog_index_view(posts: List(Post(Nil))) -> Element(Nil) {
  // Sort posts newest first by comparing dates in reverse
  let sorted_posts =
    list.sort(posts, fn(a, b) { timestamp.compare(b.date, a.date) })

  html.html([attribute.lang("en")], [
    html.head([], page_head("Simple Blog")),
    html.body([], [
      top_nav([
        html.li([], [html.strong([], [element.text("Blog")])]),
      ]),
      html.header([], [
        html.h1([], [element.text("Simple Blog")]),
        html.p([], [
          element.text(
            "A simple example blog built with Blogatto with love <3.",
          ),
        ]),
      ]),
      html.main([], [
        html.h2([], [element.text("Articles")]),
        html.ul(
          [],
          list.map(sorted_posts, fn(p) {
            html.li([], [
              html.a([attribute.href("/blog/" <> p.slug <> "/")], [
                element.text(p.title),
              ]),
              element.text(" — "),
              html.em([], [element.text(p.description)]),
            ])
          }),
        ),
      ]),
      html.footer([], [
        html.p([], [
          element.text("Built with "),
          html.a([attribute.href("https://github.com/veeso/blogatto")], [
            element.text("Blogatto"),
          ]),
        ]),
      ]),
    ]),
  ])
}

/// Blog post template: renders a full HTML page for a single blog post
/// with a navigation link back to the homepage.
fn blog_post_template(p: Post(Nil), _all_posts: List(Post(Nil))) -> Element(Nil) {
  let lang = option.unwrap(p.language, "en")

  html.html([attribute.lang(lang)], [
    html.head(
      [],
      list.append(page_head(p.title), [
        html.meta([
          attribute.name("description"),
          attribute.content(p.description),
        ]),
      ]),
    ),
    html.body([], [
      top_nav([
        html.li([], [html.a([attribute.href("/")], [element.text("Home")])]),
        html.li([], [element.text("/")]),
        html.li([], [html.a([attribute.href("/blog/")], [element.text("Blog")])]),
        html.li([], [element.text("/")]),
        html.li([], [html.strong([], [element.text(p.title)])]),
      ]),
      html.main([], [
        html.article([], [
          html.h1([], [element.text(p.title)]),
          html.p([], [html.em([], [element.text(p.description)])]),
          html.div([], p.contents),
        ]),
      ]),
      html.footer([], [
        html.p([], [
          element.text("Built with "),
          html.a([attribute.href("https://github.com/veeso/blogatto")], [
            element.text("Blogatto"),
          ]),
        ]),
      ]),
    ]),
  ])
}
