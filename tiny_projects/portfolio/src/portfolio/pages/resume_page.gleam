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

type SkillGroup {
  SkillGroup(category: String, skills: List(String))
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
    date_range: "May 2019 – Aug 2020",
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
    date_range: "May 2018 – Aug 2018",
    description: "Worked on the connectivity team to improve the BLE stack for low power sensors",
    projects: [
      "Maintained a small FIT file visualization tool for developers",
      "Integrated and measured code coverage of the BLE embedded stack",
      "Performed BLE compliance tests and fixed issues as they arose",
    ],
    tags: ["C", "Nordic NRF52", "GCOV", "BLE", "ANT", "Python", "C#"],
  ),
]

const skill_groups: List(SkillGroup) = [
  SkillGroup(
    category: "Systems & Performance",
    skills: ["Rust", "C", "C++", "DuckDB", "Apache Arrow", "PostgreSQL"],
  ),
  SkillGroup(
    category: "Embedded & Desktop",
    skills: ["C", "C++", "Qt", "QML", "Nordic NRF52", "BLE", "ANT"],
  ),
  SkillGroup(
    category: "Infrastructure & Tooling",
    skills: ["Docker", "Kubernetes", "Nix", "Bazel", "Python"],
  ),
  SkillGroup(
    category: "Graphics & Creative Coding (Learning)",
    skills: ["wgpu", "nannou"],
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
      html.main([attr.class("l-content")], [
        summary_section(),
        timeline(),
        education_section(),
        contact_section(),
      ]),
      layout.page_footer(),
    ]),
  ])
}

fn summary_section() -> Element(Nil) {
  html.section([attr.id("summary"), attr.class("c-card-section")], [
    html.h2([], [element.text("Summary")]),
    html.p([], [
      element.text(
        "I build software where the machine matters. My career has spanned embedded sensors, desktop GCS applications, and high-throughput cloud data systems — the common thread being that the interesting problems were always about using resources well and mistakes have real consequences.",
      ),
    ]),
    html.p([], [
      element.text(
        "Currently working in Rust, exploring graphics programming with wgpu, and exploring programming languages that provide layers of reliability ergonomically. I'm looking for roles where performance is a genuine constraint, not an afterthought.",
      ),
    ]),
    html.a(
      [
        attr.href("/files/2026-jack-glass-resume.pdf"),
        attr.class("c-button"),
        attr.attribute("download", ""),
      ],
      [element.text("Download Resume (PDF)")],
    ),
    html.h3([], [html.text("Skills at a glance")]),
    html.div([], list.map(skill_groups, skill_group)),
  ])
}

fn skill_group(group: SkillGroup) -> Element(Nil) {
  html.div([], [
    html.h5([], [
      element.text(group.category),
    ]),
    post_card.tag_list(group.skills),
  ])
}

fn education_section() -> Element(Nil) {
  html.section([attr.id("education"), attr.class("c-card-section")], [
    html.h2([], [element.text("Education")]),
    html.h3([], [
      element.text("B.Sc. Software Engineering"),
    ]),
    html.i([], [
      element.text("University of Calgary - 2021"),
    ]),
    html.p([], [
      element.text("Graduated with distinction. Took courses in graphics, compilers, distributed systems, and machine learning amongst others."),
    ]),
  ])
}

fn timeline() -> Element(Nil) {
  html.section([attr.id("experience"), attr.class("c-card-section")], [
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

fn contact_section() -> Element(Nil) {
  html.section([attr.id("contact"), attr.class("c-card-section")], [
    html.h2([], [element.text("Contact")]),
    html.p([], [
      element.text(
        "Interested in working with me? Send me an email or find me in person at the Calgary software meetups",
      ),
    ]),
    html.a([attr.href("mailto:jack.glass.contact@proton.me")], [
      element.text("Send to: jack.glass.contact@proton.me"),
    ]),
  ])
}
