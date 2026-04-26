### Contributing

### Development environment

- Enter the project environment with `devenv shell`.
- Use Node/Elm tooling from the environment instead of globally installed tools.

### Before opening a PR

Run the standard verification tasks:

1. `devenv tasks run verify:lint`
2. `devenv tasks run verify:review`
3. `devenv tasks run verify:build`

### Pull request expectations

- Keep changes focused and small.
- Describe what changed and why.
- Include verification output or note the exact commands run.