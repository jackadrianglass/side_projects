import blogatto/post.{type Post}
import gleam/list
import lustre/attribute as attr
import lustre/element.{type Element}
import lustre/element/html
import portfolio/components/layout

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
    title: "Senior Software Engineer",
    company: "Acme Corporation",
    company_url: "https://example.com",
    date_range: "Jan 2023 – Present",
    description: "Led backend platform work for the core product, including a rewrite of the job scheduling system that reduced p99 latency by 40%. Mentored junior engineers and drove adoption of stronger type safety patterns across the team.",
    tags: ["Rust", "PostgreSQL", "Kubernetes", "gRPC", "Terraform"],
  ),
  Entry(
    title: "Software Engineer",
    company: "Widget Inc",
    company_url: "https://example.com",
    date_range: "Mar 2020 – Dec 2022",
    description: "Built and maintained data pipeline infrastructure processing millions of events per day. Introduced property-based testing to the team and improved code coverage from 42% to 80% over six months.",
    tags: ["Python", "Apache Kafka", "Redis", "AWS", "Docker"],
  ),
  Entry(
    title: "Junior Developer",
    company: "StartupCo",
    company_url: "https://example.com",
    date_range: "Jun 2018 – Feb 2020",
    description: "Full-stack feature development on a SaaS platform. Owned the notification system end-to-end and integrated a third-party payment provider with zero downtime during the migration.",
    tags: ["TypeScript", "React", "Node.js", "MySQL", "Stripe"],
  ),
]

pub fn view(_posts: List(Post(Nil))) -> Element(Nil) {
  html.html([attr.lang("en")], [
    html.head([], layout.page_head("CV")),
    html.body([], [
      layout.top_nav([
        html.li([], [html.a([attr.href("/")], [element.text("~")])]),
        html.li([], [element.text("/")]),
        html.li([], [html.a([attr.href("/cv/")], [element.text("CV")])]),
      ]),
      html.main([], [timeline()]),
      layout.page_footer(),
    ]),
  ])
}

fn timeline() -> Element(Nil) {
  html.section([attr.class("c-card-section")], [
    html.h2([], [element.text("Experience")]),
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
      layout.tag_list(entry.tags),
    ]),
  ])
}
