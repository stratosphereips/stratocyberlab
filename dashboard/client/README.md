# StratoCyberLab Dashboard - Client

## Development

- `npm ci` to install dependencies
- `npm run dev` to run the development server (with hot reload)
- `npm run build` to build (this is done when building the Docker image)

## Code Quality

Before committing your changes, please make sure they do not generate new 
warnings (contain lints) and the code is properly formatted.

### Linting

We use [ESLint](https://eslint.org/) to check client code for lints.
You can either use IDE integration (make sure your IDE supports ESLint **9**) or 
the command `npx eslint src` (in this directory) to run code analysis.

### Formatting

[Prettier](https://prettier.io/) is used for on-the-fly formatting.
We recommend enabling automatic formatting on save using your IDE.
You can also run the command `npx prettier -w src` (in this directory) to 
reformat all code.
