# AGENTS.md

## Build/Lint/Test Commands
- Build: `swift build`
- Run: `swift run` or `open SpotBar.app`
- Test: No tests implemented
- Lint: No linter configured

## Code Style Guidelines
- **Imports**: Group and sort imports alphabetically at the top of files.
- **Formatting**: Use 4 spaces for indentation; follow Swift standard formatting.
- **Naming**: camelCase for variables/functions/methods; PascalCase for types/classes; UPPER_SNAKE_CASE for constants.
- **Types**: Prefer strong typing; use optionals for nullable values.
- **Error Handling**: Use do-catch for throwing functions; handle errors gracefully without crashing.
- **Comments**: Avoid unnecessary comments; code should be self-explanatory.
- **Structure**: Keep files focused; use extensions for organization.
- **Concurrency**: Use GCD or async/await appropriately.
- **Security**: Avoid hardcoding secrets; validate inputs.