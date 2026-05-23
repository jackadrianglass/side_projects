import blogatto/post.{type Post}
import gleam/list
import lustre/attribute as attr
import lustre/element.{type Element}
import lustre/element/html
import portfolio/components/layout
import portfolio/components/nav
import portfolio/components/post_card

type Entry {
  Entry(
    title: String,
    company: String,
    company_url: String,
    date_range: String,
    description: String,
    tags: List(String),
  )
}

const entries = [
  Entry(
    title: "Platform Software Engineer",
    company: "Biggeo",
    company_url: "https://biggeo.com/",
    date_range: "Jan 2025 – April 2026",
    description: "todo",
    tags: ["Rust", "Axum", "Sqlx", "PostgreSQL", "Duckdb", "Apache Arrow", "Kubernetes", "C++", "Nix", "Docker"],
  ),
  Entry(
    title: "Software Engineer",
    company: "Lockheed Martin Canada - Skunkworks",
    company_url: "https://www.lockheedmartin.com/en-ca/index.html",
    date_range: "?? 2022 – Dec 2024",
    description: "todo",
    tags: ["C++", "Qt", "QML", "Python", "Waf", "Bazel"],
  ),
  Entry(
    title: "Junior Software Engineer",
    company: "Garmin Canada",
    company_url: "https://www.garmin.com/en-CA/",
    date_range: "Jun 2018 – ?? 2022",
    description: "todo",
    tags: ["C", "C++", "Nordic NRF52", "BLE", "ANT", "Python", "Pandas", "Microsoft HPC", "PostgreSQL"],
  ),
  Entry(
    title: "Software Engineering Intern",
    company: "Garmin Canada",
    company_url: "https://www.garmin.com/en-CA/",
    date_range: "Jun 2018 – ?? 2022",
    description: "todo",
    tags: ["C", "C++", "Nordic NRF52", "BLE", "ANT", "Python", "C#"],
  ),
  Entry(
    title: "Software Engineering Summer Student",
    company: "Garmin Canada",
    company_url: "https://www.garmin.com/en-CA/",
    date_range: "Jun 2018 – ?? 2022",
    description: "todo",
    tags: ["C", "Nordic NRF52", "BLE", "ANT", "Python", "C#"],
  ),
]

pub fn view(posts: List(Post(Nil))) -> Element(Nil) {
  html.html([attr.lang("en")], [
    html.head([], layout.page_head("CV")),
    html.body([], [
      nav.top_nav(posts, [
        html.li([], [html.a([attr.href("/")], [element.text("~")])]),
        html.li([], [element.text("/")]),
        html.li([], [html.a([attr.href("/cv/")], [element.text("CV")])]),
      ]),
      html.main([attr.class("l-content")], [timeline()]),
      layout.page_footer(),
    ]),
  ])
}

fn timeline() -> Element(Nil) {
  html.section([attr.class("c-card-section")], [
    html.h2([], [element.text("Work Experience")]),
    html.ol(
      [attr.class("c-timeline")],
      list.map(entries, timeline_entry),
    ),
  ])
}

fn timeline_entry(entry: Entry) -> Element(Nil) {
  html.li([attr.class("c-timeline__entry")], [
    html.div([attr.class("c-timeline__marker")], []),
    html.div([attr.class("c-timeline__content")], [
      html.div([attr.class("c-timeline__header")], [
        html.div([attr.class("c-timeline__title-group")], [
          html.h3([attr.class("c-timeline__title")], [element.text(entry.title)]),
          html.a(
            [attr.href(entry.company_url), attr.class("c-timeline__company")],
            [element.text(entry.company)],
          ),
        ]),
        html.span([attr.class("c-timeline__date")], [
          element.text(entry.date_range),
        ]),
      ]),
      html.p([attr.class("c-timeline__description")], [
        element.text(entry.description),
      ]),
      post_card.tag_list(entry.tags),
    ]),
  ])
}
