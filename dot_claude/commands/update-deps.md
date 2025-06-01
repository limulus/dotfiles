Update the dependencies in this project using the procedure specific to the type
of project.

## JavaScript/TypeScript With `package.json`

1. Run `npm outdated --json` to determine which dependencies can be updated.
2. Use `npm install package1@latest package2@latest` to update every dependency
   that is not a major version bump.
3. Run tests to ensure nothing has broken.
4. Inform the user which packages are major version bumps and therefore were not
   applied.

## All Other Project Types

Formulate a plan given the type of project. Inform the user of your plan before
proceeding.
