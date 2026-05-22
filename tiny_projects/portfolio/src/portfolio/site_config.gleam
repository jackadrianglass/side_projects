import blogatto/config
import blogatto/config/feed
import blogatto/config/markdown
import blogatto/config/markdown/code
import blogatto/config/robots
import blogatto/config/sitemap
import gleam/option
import lustre/attribute
import lustre/element/html
import portfolio/pages/blog_index_page
import portfolio/pages/blog_post_page
import portfolio/pages/home_page
import portfolio/pages/projects_index_page
import portfolio/pages/resume_page
import smalto/lustre/themes

const site_url = "https://jackadrianglass.github.io"

pub fn config() -> config.Config(Nil) {
  // Syntax highlighting configuration using CSS classes
  let syntax_config =
    code.default()
    |> code.smalto_config(themes.material_dark())

  // Markdown configuration: search the blog/ directory for posts
  let md_config =
    markdown.default()
    |> markdown.markdown_path("./blog")
    |> markdown.route_prefix("pages")
    |> markdown.template(blog_post_page.template)
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
  |> config.route("/", home_page.view)
  |> config.route("/blog/", blog_index_page.view)
  |> config.route("/projects/", projects_index_page.view)
  |> config.route("/cv/", resume_page.view)
  |> config.feed(rss)
  |> config.sitemap(sitemap_config)
  |> config.robots(robots_config)
}
