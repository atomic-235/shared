---
name: texlive
description: Use when compiling LaTeX documents via the texlive/texlive Docker container. Covers pdflatex/xelatex/lualatex, latexmk, biber/bibtex, tlmgr package management, common compilation errors, and math article best practices (amsart, amsmath, theorems, multiline equations). Use instead of installing TeX Live natively. Includes a ready-to-use math article template.
---

# TeX Live Docker Skill

Compile LaTeX documents using the `texlive/texlive:latest` Docker image. No local TeX installation needed.

## Container basics

```bash
docker run --rm -v "$PWD:$PWD" -w "$PWD" texlive/texlive:latest <command>
```

- Image: `texlive/texlive:latest` (~5.7GB, TeX Live 2026, scheme-full)
- Mount at same path as host (`$PWD:$PWD`) so `.synctex.gz` stores correct paths for zathura synctex
- All engines available: `pdflatex`, `xelatex`, `lualatex`, `latexmk`, `tectonic`
- Bibliography: `bibtex`, `biber`
- Package manager: `tlmgr` (5000+ packages pre-installed)
- Other tools: `dvips`, `dvipng`, `ps2pdf`, `makeindex`

## User-mapped run (preserves file ownership)

```bash
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD:$PWD" -w "$PWD" texlive/texlive:latest <command>
```

## Compilation

### Single pass

```bash
docker run --rm -v "$PWD:$PWD" -w "$PWD" texlive/texlive:latest \
  pdflatex -interaction=nonstopmode -halt-on-error -synctex=1 document.tex
```

### Multiple passes (for cross-references, TOC)

```bash
docker run --rm -v "$PWD:$PWD" -w "$PWD" texlive/texlive:latest \
  bash -c "pdflatex -interaction=nonstopmode document.tex && pdflatex -interaction=nonstopmode document.tex"
```

### latexmk (recommended — auto-detects passes needed)

```bash
docker run --rm -v "$PWD:$PWD" -w "$PWD" texlive/texlive:latest \
  latexmk -pdf -interaction=nonstopmode -synctex=1 document.tex
```

Engine flags for latexmk:

| Flag | Engine |
|------|--------|
| `-pdf` | pdflatex (default) |
| `-xelatex` | xelatex |
| `-lualatex` | lualatex |
| `-ps` | latex → dvips → ps2pdf |

### With bibliography

```bash
docker run --rm -v "$PWD:$PWD" -w "$PWD" texlive/texlive:latest \
  bash -c "latexmk -pdf -interaction=nonstopmode -synctex=1 -bibtex document.tex"
```

Use `-biber` instead of `-bibtex` if the document uses `biblatex` with biber backend.

### Clean auxiliary files

```bash
docker run --rm -v "$PWD:$PWD" -w "$PWD" texlive/texlive:latest \
  latexmk -c document.tex
```

`-C` also removes the PDF. Or manually:

```bash
rm -f *.aux *.log *.out *.toc *.bbl *.blg *.fls *.fdb_latexmk *.synctex.gz
```

## Package management

### Check if a package is installed

```bash
docker run --rm texlive/texlive:latest tlmgr info <package>
```

`i` prefix in output = installed. `r` = reserved. No prefix = not installed.

### Install a package (ephemeral — lost when container stops)

```bash
docker run --rm -v "$PWD:$PWD" -w "$PWD" texlive/texlive:latest \
  tlmgr install <package>
```

**Note:** Container is ephemeral. Installed packages are lost when the container exits. For persistent packages, create a derived image:

```dockerfile
FROM texlive/texlive:latest
RUN tlmgr install <package1> <package2>
```

Build: `docker build -t texlive-custom .`

### List installed packages

```bash
docker run --rm texlive/texlive:latest tlmgr info --only-installed | head -20
```

### Update all packages

```bash
docker run --rm texlive/texlive:latest tlmgr update --all
```

(Ephemeral — only useful in a derived image.)

## Engine selection

| Engine | Use when |
|--------|----------|
| `pdflatex` | Standard LaTeX, ASCII/Cyrillic, fastest |
| `xelatex` | System fonts (TTF/OTF), Unicode, CJK, fontspec |
| `lualatex` | Lua scripting, OTF features, microtype, modern fonts |
| `latexmk` | Auto pass detection, any of the above via flags |

## Common errors and fixes

### "File not found" for a .sty package

Package not installed. Check with `tlmgr info <name>`, install with `tlmgr install <name>`.

### "Undefined control sequence"

Missing package in preamble, or typo. Check `\usepackage{...}` matches the package name.

### "TeX capacity exceeded"

Complex document. Try `\split` or increase `texmf.cnf` pool size. Or use `lualatex` (dynamic memory).

### Cross-references wrong ("??")

Need multiple passes. Use `latexmk` (auto-detects) or run pdflatex 2-3 times.

### Bibliography not appearing

1. Run `bibtex` or `biber` after first `pdflatex` pass
2. Run `pdflatex` twice more
3. Or use `latexmk -pdf -bibtex` (does all passes automatically)

### Font not found (xelatex/lualatex)

System fonts not available in container. Either:
- Install font in derived image: `RUN apt-get install fonts-<name>`
- Or mount host fonts: `-v /usr/share/fonts:/usr/share/fonts:ro`

### Chinese/CJK text

Use `xelatex` with `ctex` package:

```latex
\documentclass{ctexart}
\begin{document}
中文文本
\end{document}
```

Compile: `latexmk -xelatex document.tex`

### minted package fails

`minted` requires `--shell-escape` and Python Pygments:

```bash
docker run --rm -v "$PWD:$PWD" -w "$PWD" texlive/texlive:latest \
  pdflatex -shell-escape -interaction=nonstopmode document.tex
```

Pygments is pre-installed in the container.

## Performance tips

- **Use `latexmk`** — auto-detects correct number of passes, no manual reruns
- **Mount only the document directory** — not the entire home
- **`-halt-on-error`** — stops at first error instead of cascading
- **`-interaction=nonstopmode`** — no interactive prompts, doesn't hang on errors
- **Persistent container for iterative work:**

```bash
docker run -d --name texlive -v "$PWD:$PWD" -w "$PWD" texlive/texlive:latest sleep infinity
docker exec texlive latexmk -pdf document.tex
docker stop texlive && docker rm texlive
```

## Math article best practices

### Document class

| Class | Use when |
|-------|----------|
| `amsart` | AMS journal submissions, pure math papers (auto-loads amsmath + amsthm) |
| `article` | Portability, preprints, non-AMS journals (add `\usepackage{amsmath,amsthm}`) |

`amsart` defaults: 10pt, left equation numbers, structured top matter (`\author`, `\address`, `\email`, `\subjclass`, `\keywords`).

### Standard package stack (pdflatex)

```latex
\usepackage{mathtools}  % loads amsmath, fixes bugs, adds extensions
\usepackage{amssymb}     % loads amsfonts: \mathbb, \mathfrak, extra symbols
\usepackage{amsthm}      % theorem environments (skip if using amsart)
\usepackage{bm}          % bold math symbols (superior to \boldsymbol)
```

For `lualatex`/`xelatex`: use `unicode-math` with a math font instead:
```latex
\usepackage{unicode-math}
\setmathfont{Latin Modern Math}  % or Libertinus Math, New Computer Modern Math
```

### Packages to avoid

| Package | Problem | Alternative |
|---------|---------|-------------|
| `physics` | Spacing issues, counter-intuitive syntax | Define custom macros |
| `eqnarray` | Deprecated, broken spacing around `=` | `align` from amsmath |
| `$$ ... $$` | Deprecated (plain TeX relic) | `\[ ... \]` or `equation` env |

### Theorem environments (amsthm)

Three built-in styles:

| Style | Body font | Use for |
|-------|-----------|---------|
| `plain` | Italic | Theorem, Lemma, Proposition, Corollary |
| `definition` | Upright | Definition, Example |
| `remark` | Upright | Remark, Note |

```latex
\theoremstyle{plain}
\newtheorem{thm}{Theorem}[section]
\newtheorem{lem}[thm]{Lemma}         % shared counter with thm
\newtheorem{cor}[thm]{Corollary}
\theoremstyle{definition}
\newtheorem{defn}[thm]{Definition}
\theoremstyle{remark}
\newtheorem{rem}[thm]{Remark}
\newtheorem*{note}{Note}             % unnumbered
```

- `\numberwithin{equation}{section}` — section-based equation numbering
- `proof` environment auto-adds QED symbol
- **Proof goes OUTSIDE the theorem environment** — do not nest
- `\newtheorem*` for unnumbered environments

### Multiline equations

| Environment | Use case | Numbering |
|-------------|----------|-----------|
| `equation` | Single equation | One number |
| `align` | Multiple aligned equations | One per line |
| `split` (inside `equation`) | One long equation, aligned | One number |
| `gather` | Centered consecutive equations | One per line |
| `multline` | One long equation, no alignment | One number |
| `aligned` (inside `\[\]` or `equation`) | Like align but inner | No standalone |

- Starred variants (`align*`, `gather*`, `equation*`) suppress numbering
- `\notag` on individual lines to suppress specific numbers
- `\label{eq:name}` + `\eqref{eq:name}` for cross-references (adds parens)

### Text in math mode

| Command | Purpose | Example |
|---------|---------|---------|
| `\operatorname{}` | Function names (proper spacing) | `\operatorname{sgn}` |
| `\DeclareMathOperator` | Define reusable operators | `\DeclareMathOperator{\sgn}{sgn}` |
| `\text{}` | Words in math (uses text font) | `x \text{ if } x > 0` |
| `\mathrm{}` | Upright Roman in math (no op spacing) | `\mathrm{d}` |

- **Do not use `\text` for function names** — use `\operatorname` or `\DeclareMathOperator`
- `\DeclareMathOperator*` for operators with limits below (e.g., `\lim`)

### Dots and ellipsis

With `amsmath` loaded, `\dots` auto-selects baseline vs centered based on context:

| Command | Context | Example |
|---------|---------|---------|
| `\dots` | Auto-detect (preferred) | `a_1, \dots, a_n` |
| `\dotsc` | After commas | `a, \dotsc, z` |
| `\dotsb` | Between binary operators | `a + \dotsb + z` |
| `\dotsm` | Multiplication | `a_1 \dotsm a_n` |
| `\dotsi` | Integrals | `\int \dotsi \int` |

### Bold math

| Command | Source | Handles | Style |
|---------|--------|---------|-------|
| `\bm{}` | bm package | Latin, Greek, symbols | Bold italic |
| `\boldsymbol{}` | amsmath | Latin, Greek, symbols | Bold italic (less robust) |
| `\mathbf{}` | LaTeX kernel | Latin only | Bold upright (no Greek) |

Define semantic macros: `\newcommand{\vect}[1]{\bm{#1}}`, `\newcommand{\mat}[1]{\bm{#1}}`

### Differential d — debated

- **ISO standard**: upright `\mathrm{d}` (physics/applied math)
- **Pure math convention**: italic `d` (Knuth, Tao, most mathematicians)
- **Consistency > choice** — define a macro either way:
```latex
\newcommand{\dd}{\mathrm{d}}  % upright (ISO)
% or
\newcommand{\dd}{\,d}         % italic with thin space (pure math)
```

### Math fonts

| Font | Engine | Notes |
|------|--------|-------|
| Computer Modern | pdflatex | Default, expected by math journals |
| Latin Modern (`lmodern`) | pdflatex | Modern CM replacement, better Unicode |
| New TX Math (`newtxmath`) | pdflatex | Times-style, more glyphs |
| Libertinus Math | lualatex/xelatex | Via `unicode-math`, elegant |
| New Computer Modern Math | lualatex/xelatex | Via `unicode-math`, CM-like |

For journal submissions: stick with Computer Modern or Latin Modern.

### Bibliography for math

| Method | Use when |
|--------|----------|
| `bibtex` + `amsplain`/`amsalpha` | AMS journal submissions (expected) |
| `biblatex` + `biber` | Preprints, personal documents (more powerful) |
| `amsrefs` | AMS-native, embeds refs in .tex (niche) |

```latex
% bibtex + amsplain (journal standard)
\bibliographystyle{amsplain}
\bibliography{references}
```

### Common math mistakes to avoid

1. **`$$ ... $$`** — use `\[ ... \]` or `equation` environment
2. **`eqnarray`** — use `align` from amsmath
3. **`\text` for function names** — use `\operatorname` or `\DeclareMathOperator`
4. **No `\,` before `dx` in integrals** — use `\int f(x)\,dx` (thin space)
5. **Inconsistent notation** — define macros for all recurring symbols
6. **Proof inside theorem** — place `proof` after `\end{theorem}`, not nested
7. **Manual spacing** — use semantic spacing commands (`\,` `\;` `\:` `\quad`)
8. **Missing thin space before `\dd`** — `\int f(x)\,\dd x`

### Math article template

A ready-to-use template is in `templates/math-article.tex` alongside this skill. It includes `amsart` document class, standard package stack, theorem environments, common macros (`\R`, `\C`, `\Z`, `\N`, `\Q`, `\norm`, `\abs`, `\inner`), `\DeclareMathOperator` examples, and bibliography setup.

**Always start from the template for math articles:**
```bash
cp ~/.config/opencode/skills/texlive/templates/math-article.tex mypaper.tex
docker run --rm -v "$PWD:$PWD" -w "$PWD" texlive/texlive:latest \
  latexmk -pdf -interaction=nonstopmode -synctex=1 mypaper.tex
```

When the user asks to write a math document, **use this template as the starting point** — do not write LaTeX from scratch. Copy the template, then modify preamble macros and body content as needed.

## Quick reference

```bash
# Compile (auto passes + bib + synctex)
docker run --rm -v "$PWD:$PWD" -w "$PWD" texlive/texlive:latest \
  latexmk -pdf -interaction=nonstopmode -synctex=1 document.tex

# XeLaTeX
docker run --rm -v "$PWD:$PWD" -w "$PWD" texlive/texlive:latest \
  latexmk -xelatex -interaction=nonstopmode -synctex=1 document.tex

# Clean aux files
docker run --rm -v "$PWD:$PWD" -w "$PWD" texlive/texlive:latest \
  latexmk -c

# Check package
docker run --rm texlive/texlive:latest tlmgr info <package>
```

## Build script for projects

For any LaTeX project, create a `build.sh` that uses the same-path mount pattern. This ensures `.synctex.gz` stores correct host paths for zathura forward/inverse search.

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

DOC="document.tex"
[ ! -f "$DOC" ] && { echo "error: $DOC not found"; exit 1; }

export DOCKER_HOST="unix://${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock"
docker run --rm \
    -v "$PWD:$PWD" -w "$PWD" \
    texlive/texlive:latest \
    latexmk -pdf -interaction=nonstopmode -halt-on-error -synctex=1 "$DOC"

echo "Built: $(pwd)/${DOC%.tex}.pdf"
```

**Critical:** Mount at `$PWD:$PWD` (same path inside and outside container), NOT `$PWD:/workdir`. The `.synctex.gz` file stores absolute paths — if they don't match the host path, zathura synctex forward/inverse search breaks.

**Add to `.gitignore`:**
```
*.aux
*.fdb_latexmk
*.fls
*.log
*.synctex.gz
*.out
*.toc
*.bbl
*.blg
document.pdf
```

When creating a new LaTeX project, always:
1. Create `build.sh` with the pattern above (change `DOC` variable)
2. Create `.gitignore` with the patterns above
3. Run `bash build.sh` to compile
4. Use `latexmk -C` to force full rebuild when synctex paths are stale
