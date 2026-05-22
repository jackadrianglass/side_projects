# Project Description

This is a developer portfolio and blog website written using Gleam. Goals here are
1. Show case me as a developer
2. Have a playground to create wimsical and fun software
3. Have a little blog to write about small ideas that I've been tinkering with

# Project layout

```
root
  blog/                     <- individual blog posts. contains markdown and assets
  build/                    <- gleam build directory. ignore
  dist/                     <- static site target directory. ignore
  src/                      <- gleam code to generate static site
    portfolio/
      components/
        layout.gleam        <- shared page shell pieces (head/nav/footer)
      pages/
        home_page.gleam     <- homepage view
        blog_index_page.gleam <- blog list view
        blog_post_page.gleam <- single post template
      site_config.gleam     <- site config + route wiring (single source of truth)
    portfolio.gleam         <- static build entrypoint (uses `site_config.config()`)
    portfolio_dev.gleam     <- dev server entrypoint (uses `site_config.config()`)
  static/                   <- static assets that get copied to dist/
    css/                    <- custom styling using a primitive itcss organization style
    images/                 <- image assets. ignore
    js/                     <- dynamic page logic in js
  README.md
  devenv.lock               <- devenv lock file
  devenv.nix                <- developer environment configuration
  devenv.yaml
  gleam.toml                <- gleam build config
  manifest.toml             <- gleam lockfile
```

### Layout architecture

- Shared Lustre helpers live in `src/portfolio/components/layout.gleam`.
- Route/page rendering is split by page under `src/portfolio/pages/`.
- `src/portfolio/site_config.gleam` wires markdown, feed/sitemap/robots, static dirs, and routes.
- `src/portfolio.gleam` and `src/portfolio_dev.gleam` both consume the same `site_config.config()`.

# Task regions

When asked to create/modify website layouts
- `src/portfolio/` for the views and layouts
- `static/css/` for the custom styling
- Use lustre for view creation
- Use pico.css for styling and layout
- Use `devenv tasks run basic:build --show-output` to validate code

When asked to review blog posts
- `blog/<blog post>` for the content
- Goal is to let me create the content. You are the editor
- Avoid adding filler content
- Prioritize correctness
- Use `devenv tasks run basic:build --show-output` to validate markdown compatibility

When asked to create creative coding sketches
- `static/js/sketches` for the p5.js sketches
- Goal is to unblock me rather than to outright write the code for me
- No validation step at this time. Prioritize correct and simple JS code

# Important libraries used

- [lustre](https://hexdocs.pm/lustre/5.6.0/index.html) for static view creation
- [pico.css](https://picocss.com/docs) for styling and layout
- [p5.js](https://beta.p5js.org/reference/) for creative coding sketches

## External docs

Gleam documentation is on hexdocs. URL format is
```
https://hexdocs.pm/<package name>/<package version>
```

Example for lustre
```
https://hexdocs.pm/lustre/5.6.0/
```

Use `gleam deps list` to get a complete list of dependencies and their versions
