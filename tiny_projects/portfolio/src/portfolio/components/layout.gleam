import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn top_nav(breadcrumb_items: List(Element(Nil))) -> Element(Nil) {
  html.nav([attribute.class("c-site-nav")], [
    html.ul([attribute.class("c-site-nav__crumbs")], breadcrumb_items),
    html.nav([attribute.class("c-site-nav__links")], [
      html.a([attribute.href("/blog/")], [element.text("Blog")]),
      html.a([attribute.href("/cv/")], [element.text("CV")]),
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
        html.a([attribute.href("/blog/")], [
          element.text("Blog"),
        ]),
      ]),
    ]),
  ])
}
