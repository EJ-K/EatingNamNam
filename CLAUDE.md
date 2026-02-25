# EatingNamNam - Development Notes

## Project Overview

EatingNamNam is a World of Warcraft addon (retail) that announces eating/drinking in group instances via SAY chat. It is a single-file Lua addon (`EatingNamNam.lua`) with saved variables stored in `EatingNamNamDB`.

## Release & Versioning

- **Versioning:** Semantic versioning (`vMAJOR.MINOR.PATCH`). The `.toc` file uses `@project-version@`, which is replaced at package time by the BigWigsMods packager.
- **Release process:** Push a git tag matching `v*` (e.g. `v1.0.0`). The GitHub Actions workflow (`.github/workflows/release.yml`) runs the BigWigsMods packager, which builds the zip and publishes to configured platforms.
- **Distribution:** Published to [wago.io](https://wago.io). The `X-Wago-ID` field in the `.toc` must be updated with the actual project ID once created. The `WAGO_API_TOKEN` secret must be configured in the GitHub repo.
- **Packaging:** Configured via `.pkgmeta`. The packager strips `.github/`, `.gitignore`, `README.md`, and `CHANGELOG.md` from the release zip.

## Git

- Committer: `EJ-K <elliot@clerwood.dev>` (set via local git config)
- Branch: `main`

## WoW API

- An MCP tool is available for looking up WoW API functions, events, enums, widgets, and namespaces. Use it when working with game APIs.
