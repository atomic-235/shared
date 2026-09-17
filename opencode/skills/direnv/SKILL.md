---
name: direnv
description: >
  Use when writing, editing, or reviewing `.envrc` files (direnv). Covers
  requirements for highlighting important per-project commands in the direnv
  banner: ANSI-colored separator lines, a ▶ marker with the command label,
  and a green-highlighted copy-paste-ready command. Applies to any project
  using direnv for per-project environments.
---

# direnv .envrc: Highlighting Important Project Commands

## Requirement

Every `.envrc` MUST print a highlighted banner listing the important commands
to run in that project (dev server, TUI, build, deploy, etc.). When the user
`cd`s into the project, direnv executes the `.envrc` and the banner shows them
exactly what to run — no digging through READMEs.

## Banner format

Use this exact pattern for each command:

```bash
echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "\e[1;33m  ▶ TUI (cloud): \e[1;32mwith-secrets cloud ./packages/tui/cloud.sh pnpm --filter @inventory/tui start\e[0m"
echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
```

Rules:

- **Separator lines**: bold cyan (`\e[1;36m`) box-drawing characters (`━`). Do
  NOT use ASCII `-` or `=`.
- **Label**: bold yellow (`\e[1;33m`), prefixed with `▶ `. Short, descriptive
  name including the environment/target when there are variants, e.g.
  `TUI (cloud)`, `Dev server`, `Tests`.
- **Command**: bold green (`\e[1;32m`), the FULL command exactly as the user
  should type it — copy-paste-ready, including wrappers like `with-secrets`,
  `nix develop`, `pnpm exec`, etc. Each command line ends with `\e[0m` to
  reset.
- Always use `echo -e` (or `printf`), never plain `echo` — escape sequences
  must be interpreted.
- Put banner output in a shell function or emit it unconditionally as the last
  block of `.envrc` (direnv only prints output when the env changes or on
  `direnv reload`, so it won't spam every prompt).

## Multiple commands

One banner block per command. Group related variants:

```bash
banner() {
  echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "\e[1;33m  ▶ TUI (cloud): \e[1;32mwith-secrets cloud ./packages/tui/cloud.sh pnpm --filter @inventory/tui start\e[0m"
  echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
  echo -e "\e[1;33m  ▶ Dev server: \e[1;32mpnpm dev\e[0m"
  echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
}
banner
```

## Things to avoid

- Do not print secrets, tokens, or env var values in the banner. Print
  `[set]`/`[missing]` status for required vars instead.
- Do not run anything slow or with side effects at banner time — the banner
  runs on every direnv reload.
- Do not put the banner before `use flake`/`use nix` blocks; place it last so
  it is the final thing the user sees after entering the project.
- Do not rely on the terminal supporting 256-color or truecolor; the banner
  uses only basic bold ANSI colors that work everywhere.
