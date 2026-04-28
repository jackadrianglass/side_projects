# portfolio

A static portfolio/blog site built with `blogatto` and `lustre`.

Styling uses `Pico.css` (loaded via CDN in templates) with project-specific overrides in `static/css/style.css`.

## Quick start

```sh
gleam deps download
gleam run        # Build site into ./dist
gleam test       # Run tests
gleam run -m portfolio_dev  # Start dev server
```

## Agent-focused docs

If you are an AI/code agent contributing to this repo, start here:

- `docs/agent-guide.md` — project map, what-to-edit guidance, and low-token workflow.

## Project docs

- `README.md` (this file) — quick project overview.
- `docs/agent-guide.md` — contributor and architecture guide.
