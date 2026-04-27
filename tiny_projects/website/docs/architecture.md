### Architecture overview

This repository is an `elm-pages` application.

### Main structure

- `app/`: Route modules and app-level wiring (`Shared`, `Site`, `View`, `Effect`, API/error routes).
- `src/`: Supporting Elm modules used by routes/pages.
- `public/`: Static assets copied into the built site.

### Build and development

- Local runtime/build commands are in `package.json` (`npm start`, `npm run build`).
- Project tooling and verification tasks are configured in `devenv.nix`.
- Canonical checks are `verify:lint`, `verify:review`, and `verify:build`.

### Deployment assumptions

- Netlify configuration is in `netlify.toml`.
- Build publishes `dist/` and uses `npm install && npm run build` in Netlify.