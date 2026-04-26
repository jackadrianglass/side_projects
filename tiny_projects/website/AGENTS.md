### Agent quick guide

This project is an `elm-pages` site using `devenv.sh` for local tooling.

### Where to work

- Elm app code: `src/` and `app/`
- Backend task hooks: `custom-backend-task.ts` and `custom-backend-task.js`
- Build/deploy config: `package.json`, `devenv.nix`, `netlify.toml`

### Canonical verification flow

Run checks inside the project environment with:

1. `devenv tasks run verify:lint`
2. `devenv tasks run verify:review`
3. `devenv tasks run verify:build`

Task definitions live in `devenv.nix`.

### Change boundaries

- Prefer minimal, focused edits.
- Do not commit generated/build artifacts from `dist/`, `elm-stuff/`, `.elm-pages/`, or `node_modules/`.
- Keep formatting and naming consistent with surrounding code.