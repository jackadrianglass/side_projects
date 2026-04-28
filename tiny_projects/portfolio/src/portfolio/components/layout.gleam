import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn top_nav(breadcrumb_items: List(Element(Nil))) -> Element(Nil) {
  html.nav([attribute.class("c-site-nav")], [
    html.ul([attribute.class("c-site-nav__crumbs")], breadcrumb_items),
    html.ul([attribute.class("c-site-nav__links")], [
      html.li([attribute.class("c-site-nav__item")], [
        html.a([attribute.href("/")], [element.text("Home")])
      ]),
      html.li([attribute.class("c-site-nav__item")], [
        html.a([attribute.href("/blog/")], [element.text("Blog")]),
      ]),
    ]),
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
  ]
}

pub fn blogatto_footer() -> Element(Nil) {
  html.footer([attribute.class("c-site-footer")], [
    html.p([attribute.class("c-site-footer__content")], [
      element.text("Built with "),
      html.a([attribute.href("https://github.com/veeso/blogatto")], [
        element.text("Blogatto"),
      ]),
    ]),
  ])
}