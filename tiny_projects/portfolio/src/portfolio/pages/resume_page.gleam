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
    projects: List(String),
    tags: List(String),
  )
}

const entries = [
  Entry(
    title: "Platform Software Engineer",
    company: "Biggeo",
    company_url: "https://biggeo.com/",
    date_range: "Jan 2025 – April 2026",
    description: "Worked on the platform team on infrastructure for a high performance geospatial cloud that made use of a custom DGGS",
    projects: [
      "Developed systems with DuckDB to perform analytical querying against terabytes of data in under 10s",
      "Manage development environments and deployments using Docker and Kubernetes",
      "Integrated AI into our development workflows through code review, agentic development, and MCP connections to our services",
    ],
    tags: [
      "Rust",
      "Axum",
      "Sqlx",
      "PostgreSQL",
      "Duckdb",
      "Apache Arrow",
      "Kubernetes",
      "C++",
      "Nix",
      "Docker",
    ],
  ),
  Entry(
    title: "Software Engineer",
    company: "Lockheed Martin Canada - Skunkworks",
    company_url: "https://www.lockheedmartin.com/en-ca/index.html",
    date_range: "Oct 2022 – Dec 2024",
    description: "Worked on the platform team, the application team, and the devops team on numerous aspects of their GCS called VCSi",
    projects: [
      "Redesigned one of the most struggled with systems at the office, the mission system, to be able to add 5 new major features such as relative waypoints in missions using C++ and Qt",
      "Integrated a new vehicle with the GCS",
      "Added support for a new vehicle communication protocol over a TCP connection",
      "Ported existing build system to Bazel",
    ],
    tags: ["C++", "Qt", "QML", "Python", "Waf", "Bazel"],
  ),
  Entry(
    title: "Junior Software Engineer",
    company: "Garmin Canada",
    company_url: "https://www.garmin.com/en-CA/",
    date_range: "Jun 2021 – Oct 2022",
    description: "Worked on the tooling team which were responsible for replacing the office's data analysis pipeline",
    projects: [
      "Wrote a distributed computation framework which enabled system critical global site collaboration. This sped up the data analysis pipeline by ~10x",
      "Integrated layers of devops tooling to the projects which made contributions foolproof and delightful",
    ],
    tags: [
      "C",
      "C++",
      "Nordic NRF52",
      "BLE",
      "ANT",
      "Python",
      "Pandas",
      "Poetry",
      "Make",
      "Mypy",
      "Microsoft HPC",
      "PostgreSQL",
    ],
  ),
  Entry(
    title: "Software Engineering Intern",
    company: "Garmin Canada",
    company_url: "https://www.garmin.com/en-CA/",
    date_range: "Jun 2018 – ?? 2022",
    description: "Worked on the sensor products team on a bike pedal product to measure many aspects of a bike ride",
    projects: [
      "Refactored bluetooth stack to improve mobile connection reliability and data throughput up to 10x using C on a Nordic microcontroller",
      "Wrote a data analysis tool to enable data scientists to rapidly iterate on the daily test data which replace the manual inspection of files which took hours",
      "Championed and practiced test driven development for all new software written at the office",
    ],
    tags: ["C", "C++", "Nordic NRF52", "BLE", "ANT", "Python", "C#"],
  ),
  Entry(
    title: "Software Engineering Summer Student",
    company: "Garmin Canada",
    company_url: "https://www.garmin.com/en-CA/",
    date_range: "Jun 2018 – ?? 2022",
    description: "Worked on the connectivity team to improve the BLE stack for low power sensors",
    projects: [
      "Maintained a small FIT file visualization tool for developers",
      "Integrated and measured code coverage of the BLE embedded stack",
      "Performed BLE compliance tests and fixed issues as they arose",
    ],
    tags: ["C", "Nordic NRF52", "GCOV", "BLE", "ANT", "Python", "C#"],
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
    html.ol([attr.class("c-timeline")], list.map(entries, timeline_entry)),
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
      project_list(entry.projects),
      post_card.tag_list(entry.tags),
    ]),
  ])
}

fn project_list(projects: List(String)) -> Element(Nil) {
  case projects {
    [] -> html.text("")
    _ ->
      html.ul(
        [attr.class("c-timeline__projects")],
        list.map(projects, fn(p) { html.li([], [element.text(p)]) }),
      )
  }
}
