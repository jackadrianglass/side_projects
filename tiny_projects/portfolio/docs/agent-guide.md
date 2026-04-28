# Agent contributor guide

This guide is optimized for fast, low-token onboarding.

## What this project does

- Builds a static website into `dist/`.
- Uses `blogatto` to render markdown posts from `blog/`.
- Uses `lustre` for HTML view rendering in Gleam templates.
- Serves static assets from `static/`.

## Fast project map

- `src/portfolio.gleam`
  - Main build entrypoint (`gleam run`).
  - Calls `portfolio/website.config()` and runs `blogatto.build`.
- `src/portfolio_dev.gleam`
  - Dev server entrypoint (`gleam run -m portfolio_dev`).
  - Wraps the same config with `blogatto/dev`.
- `src/portfolio/website.gleam`
  - Core site definition.
  - Configures markdown ingestion (`./blog`, route prefix `blog`).
  - Defines home page HTML and blog post template.
  - Registers RSS, sitemap, robots, and `/` route.
- `blog/`
  - Markdown posts with frontmatter (`title`, `description`, `date`, etc.).
  - Example: `blog/hello-world/index.md`.
- `static/`
  - Public assets copied to output.
  - `static/css/style.css` contains Pico.css theme tokens and project-specific styles.
  - Pico.css is loaded via CDN in `src/portfolio/website.gleam` for both home and blog post pages.
  - `static/js/home-widget.js` mounts the small interactive home widget.
- `test/portfolio_test.gleam`
  - Placeholder test scaffold (`gleam test`).

## Contribution workflow (minimal tokens)

1. Read only these files first:
   - `README.md`
   - `src/portfolio.gleam`
   - `src/portfolio/website.gleam`
2. If task is content-only, edit under `blog/` and (optionally) `static/`.
3. If task is layout/routing/site behavior, edit `src/portfolio/website.gleam`.
4. If task is dev/build behavior, edit `src/portfolio.gleam` and/or `src/portfolio_dev.gleam`.
5. Validate with the smallest useful command:
   - `gleam test` for tests.
   - `gleam run` for static build result.
   - `gleam run -m portfolio_dev` for local preview.

## Where to change what

- Add a new post: create `blog/<slug>/index.md` with frontmatter.
- Change homepage markup: `home_view` in `src/portfolio/website.gleam`.
- Change per-post page shell: `blog_post_template` in `src/portfolio/website.gleam`.
- Change markdown parsing behavior: markdown config pipeline in `config()`.
- Change RSS/sitemap/robots behavior: same `config()` function.
- Change interactive home widget behavior: `static/js/home-widget.js`.
- Change visual design: `static/css/style.css`.

## External docs

Gleam documentation is on hexdocs. URL format is
```
https://hexdocs.pm/<package name>/<package version>
```

Example for lustre
```
https://hexdocs.pm/lustre/5.6.0/
```
