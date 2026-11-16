# ToLooks

Exploratory scratchpad for backlog ideas, investigative spikes, architectural inquiries, and future refactors.

---

## Active ToLooks

- [ ] **1. Convert Stale PRs (>3 Months) Using `pr-to-tolook` Skill**
  - **Idea**: Review and convert open pull requests older than 3 months into structured ToLooks in `TOLOOKS.md` using the `pr-to-tolook` skill, then cleanly close the stale PRs after confirmation.
  - **Context**: As of 2026-11-14, 4 open PRs in `sqliteraw.dart` have been hanging for more than 3 months (created before 2026-08-14), adding noise to health audits and accumulating merge drift.
  - **Investigation**:
    - [ ] [#92](https://github.com/TarasMazepa/sqliteraw.dart/pull/92) [2026-08-07] *Update dependencies and adapt to native_toolchain_c changes* — inspect diff/comments, distill into a ToLook entry in `TOLOOKS.md`, and close PR once captured.
    - [ ] [#88](https://github.com/TarasMazepa/sqliteraw.dart/pull/88) [2026-07-22] *Use forked ffigen and ffi from dart-lang-native* — inspect diff/comments, distill into a ToLook entry in `TOLOOKS.md`, and close PR once captured.
    - [ ] [#85](https://github.com/TarasMazepa/sqliteraw.dart/pull/85) [2026-07-11] *Share open database example between Dart and Flutter web* — inspect diff/comments, distill into a ToLook entry in `TOLOOKS.md`, and close PR once captured.
    - [ ] [#84](https://github.com/TarasMazepa/sqliteraw.dart/pull/84) [2026-07-11] *Add WASM build and web bindings for Flutter web* — inspect diff/comments, distill into a ToLook entry in `TOLOOKS.md`, and close PR once captured.

---

- [ ] **2. Migrate Non-Kebab-Case Markdown Files to `kebab-case`**
  - **Idea**: Rename remaining uppercase/underscore markdown files to pure `kebab-case` per `agents.md` and update any internal or workflow references to them.
  - **Context**: `repository-seed` standardized markdown naming to pure `kebab-case` (`agents.md`, `readme.md`, `tolooks.md`, `more-agents.md`).
  - **Investigation**:
    - [ ] Rename `README.md` → `readme.md` and update references
    - [ ] Rename `TOLOOKS.md` → `tolooks.md` and update references
    - [ ] Rename `sample/flutter/ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md` → `sample/flutter/ios/Runner/Assets.xcassets/LaunchImage.imageset/readme.md` and update references

## Resolved Architectural Decisions

*(No resolved architectural decisions recorded yet.)*

---

## Related Documentation

- [AGENTS.md](AGENTS.md) — Agent guidelines and ToLooks rules.
- [docs/seeded/tolooks/README.md](docs/seeded/tolooks/README.md) — ToLooks concept and lifecycle guide.
