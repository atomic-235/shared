---
name: texlive
description: Use when compiling LaTeX documents via the texlive/texlive Docker container. Covers pdflatex/xelatex/lualatex, latexmk, biber/bibtex, tlmgr package management, and common compilation errors. Use instead of installing TeX Live natively.
---

# TeX Live Docker Skill

Compile LaTeX documents using the `texlive/texlive:latest` Docker image. No local TeX installation needed.

## Container basics

```bash
docker run --rm -v "$PWD:/workdir" -w /workdir texlive/texlive:latest <command>
```

- Image: `texlive/texlive:latest` (~5.7GB, TeX Live 2026, scheme-full)
- Default workdir: `/workdir`
- Runs as root — output files owned by root (fix with `--user $(id -u):$(id -g)` if needed)
- All engines available: `pdflatex`, `xelatex`, `lualatex`, `latexmk`, `tectonic`
- Bibliography: `bibtex`, `biber`
- Package manager: `tlmgr` (5000+ packages pre-installed)
- Other tools: `dvips`, `dvipng`, `ps2pdf`, `makeindex`

## User-mapped run (preserves file ownership)

```bash
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD:/workdir" -w /workdir texlive/texlive:latest <command>
```

## Compilation

### Single pass

```bash
docker run --rm -v "$PWD:/workdir" -w /workdir texlive/texlive:latest \
  pdflatex -interaction=nonstopmode -halt-on-error document.tex
```

### Multiple passes (for cross-references, TOC)

```bash
docker run --rm -v "$PWD:/workdir" -w /workdir texlive/texlive:latest \
  bash -c "pdflatex -interaction=nonstopmode document.tex && pdflatex -interaction=nonstopmode document.tex"
```

### latexmk (recommended — auto-detects passes needed)

```bash
docker run --rm -v "$PWD:/workdir" -w /workdir texlive/texlive:latest \
  latexmk -pdf -interaction=nonstopmode document.tex
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
docker run --rm -v "$PWD:/workdir" -w /workdir texlive/texlive:latest \
  bash -c "latexmk -pdf -interaction=nonstopmode -bibtex document.tex"
```

Use `-biber` instead of `-bibtex` if the document uses `biblatex` with biber backend.

### Clean auxiliary files

```bash
docker run --rm -v "$PWD:/workdir" -w /workdir texlive/texlive:latest \
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
docker run --rm -v "$PWD:/workdir" -w /workdir texlive/texlive:latest \
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
docker run --rm -v "$PWD:/workdir" -w /workdir texlive/texlive:latest \
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
docker run -d --name texlive -v "$PWD:/workdir" -w /workdir texlive/texlive:latest sleep infinity
docker exec texlive latexmk -pdf document.tex
docker stop texlive && docker rm texlive
```

## Quick reference

```bash
# Compile (auto passes + bib)
docker run --rm -v "$PWD:/workdir" -w /workdir texlive/texlive:latest \
  latexmk -pdf -interaction=nonstopmode document.tex

# XeLaTeX
docker run --rm -v "$PWD:/workdir" -w /workdir texlive/texlive:latest \
  latexmk -xelatex -interaction=nonstopmode document.tex

# Clean aux files
docker run --rm -v "$PWD:/workdir" -w /workdir texlive/texlive:latest \
  latexmk -c

# Check package
docker run --rm texlive/texlive:latest tlmgr info <package>
```
