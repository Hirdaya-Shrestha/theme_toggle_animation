# Contributing to theme_toggle_animation

Thanks for your interest in contributing! This guide covers how to set up the project, the checks your changes must pass, and how releases are published.

## Table of Contents

- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Required Checks](#required-checks)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Opening a Pull Request](#opening-a-pull-request)
- [Code of Conduct](#code-of-conduct)

## Getting Started

```bash
# Clone the repo
git clone https://github.com/Hirdaya-Shrestha/theme_toggle_animation.git
cd theme_toggle_animation

# Fetch dependencies
flutter pub get

# Fetch example app dependencies
cd example && flutter pub get && cd ..
```

> **Requirements:** Flutter stable channel (Dart SDK ^3.13.2).

## Project Structure

```
lib/            # Package source
  src/          # Implementation (widget, animation types, clippers)
  theme_toggle_animation.dart  # Public API barrel export
test/           # Package tests
example/        # Demo app showcasing all features
demo_gifs/      # Demo GIFs used in the README
```

## Development Workflow

1. Create a feature branch: `git checkout -b feat/your-feature`
2. Make your changes
3. Run all the required checks (below)
4. Commit with a descriptive message
5. Push and open a pull request against `main`

## Required Checks

Every contribution **must** pass all of the following before it can be merged.
The same checks run automatically in CI (`.github/workflows/ci.yml`).

### 1. Format

```bash
dart format lib test example/lib example/test
```

Confirm formatting is clean (fails the build if any file is unformatted):

```bash
dart format --set-exit-if-changed lib test example/lib example/test
```

### 2. Analyze

```bash
flutter analyze
```

Must report **No issues found**. This covers both the package and the example.

### 3. Tests

```bash
# Package tests
flutter test

# Example app tests
cd example && flutter test && cd ..
```

All tests must pass.

### Quick one-liner

```bash
dart format --set-exit-if-changed lib test example/lib example/test \
  && flutter analyze \
  && flutter test
```

## Commit Message Guidelines

Use clear, conventional-style commit messages:

- `feat: add new animation direction`
- `fix: prevent custom mask flash at first frame`
- `docs: update README`
- `refactor: simplify clipper factory`
- `test: cover lifecycle callbacks`

Keep the subject under ~72 characters. Reference issues/PRs when relevant.

## Opening a Pull Request

- PRs should target the `main` branch.
- Keep changes focused; one logical change per PR.
- Update `README.md` and `CHANGELOG.md` if you change public API or behavior.
- Add tests for new behavior — the CI gate will not pass otherwise.
- Ensure all [Required Checks](#required-checks) pass locally before submitting.
- In the PR description, summarize what changed and why.

> **Note:** Package releases are published by the maintainer only.

## Code of Conduct

Please review and adhere to our [Code of Conduct](CODE_OF_CONDUCT.md) — be
respectful and constructive. This project is intended to be a safe, welcoming
space for collaboration. Harassment or abusive behavior will not be tolerated.