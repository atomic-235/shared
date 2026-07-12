---
name: typst
description: Use when writing, editing, or compiling Typst documents (.typ files). Covers Typst markup syntax, code mode, math mode, set/show rules, bibliography setup, citation syntax (@key), Hayagriva YAML format, BibTeX .bib format, citation styles (IEEE, APA, MLA, etc.), and common gotchas vs LaTeX.
---

# Typst Reference Skill

Typst is a modern typesetting system. Compile with `typst compile document.typ` or watch with `typst watch document.typ`.

---

## Three Modes

| Mode | Entry | Example |
|------|-------|---------|
| **Markup** | Default | `*bold* _italic_` |
| **Code** | Prefix `#` | `#rect(width: 1cm)` |
| **Math** | Wrap `$...$` | `$x^2 + y^2$` |

Once in code mode via `#`, no further `#` needed until returning to markup.

---

## Markup Syntax

```typst
= Heading 1
== Heading 2
=== Heading 3

*strong/bold*
_emphasis/italic_

- bullet item
+ numbered item
/ Term: description list

`inline code`
```code block```

https://example.com              // auto-link
#link("https://...")[link text]  // named link

<label-name>    // define a label
@label-name     // reference a label OR cite a source

Blank line = paragraph break
\               // forced line break (backslash at end of line)
```

### Escape sequences

```typst
\$  \*  \_  \@  \#  \~  \---
\u{1f600}   // Unicode codepoint
```

---

## Code Mode

```typst
#let x = 5
#let f(x) = 2 * x
#if x == 1 { [yes] } else { [no] }
#for item in (1, 2, 3) { [#item] }
#import "file.typ": func
#import "@preview/pkg:0.1.0": func
```

Square brackets `[...]` create content values inside code mode:

```typst
#underline[underlined text]
#rect(fill: aqua)[content here]
```

---

## Set Rules and Show Rules

```typst
// Set rules: change defaults for a function
#set text(font: "New Computer Modern", size: 12pt)
#set page(margin: 1.75in)
#set par(justify: true, leading: 0.55em)

// Show rules: transform elements
#show heading: set block(above: 1.4em, below: 1em)
#show raw: set text(font: "New Computer Modern Mono")
#show: smallcaps   // apply to everything that follows
```

---

## Math Mode

```typst
$x^2$                         // inline
$ x^2 + y^2 = r^2 $           // display (spaces around content)
$x_1$                         // subscript
$(a+b)/c$                     // fraction (auto-detected)
$sum_(k=1)^n k$               // sum with limits
$mat(1, 0; 0, 1)$             // matrix (semicolons = new row)
$cases(1 "if" x > 0, 0 "else")$
$alpha, beta, gamma$          // Greek letters by name
$->$  $!=$  $<=$              // symbol shorthands
$"text in math"$              // literal text
```

### CRITICAL: No Backslash Commands in Math

Typst is NOT LaTeX. **There are no `\command` sequences in math mode.** Backslash in markup mode is a forced line break, and in math mode it is not a command prefix. Writing `\models`, `\sqsubseteq`, `\circ`, `\neg`, `\;`, `\,` will cause parse errors or wrong output.

### Multi-Letter Identifiers Must Be Quoted

Typst treats each letter in math as a separate variable. `models`, `iff`, `Mod`, `inf`, `sup` will all fail with "unknown variable" errors. **Always quote multi-letter words:**

```typst
$T models phi$          // ERROR: "unknown variable: odels"
$T "models" phi$        // CORRECT
$"Mod"(T)$              // CORRECT
$"iff"$                 // CORRECT
$"Sen" : bold("Sign") -> bold("Set")$   // CORRECT
```

### Math Spacing

Typst math spacing uses punctuation characters, not LaTeX commands:

| Typst | Width | LaTeX equivalent |
|-------|-------|------------------|
| `thin` | thin space | `\,` |
| `;` | medium space | `\;` |
| `:` | thick space | `\:` |
| `::` | thicker | (none) |
| `quad` | 1em | `\quad` |
| `space` | normal space | (space) |

```typst
$R ; S$              // medium space between R and S
$R quad S$           // 1em space
$exists y.thin R(x,y)$   // thin space after dot
```

### LaTeX → Typst Math Symbol Mapping

Many LaTeX math symbol names do NOT exist in Typst. Use the Typst name or Unicode character directly.

#### Symbols with Typst names (use these)

| LaTeX | Typst | Notes |
|-------|-------|-------|
| `\alpha` | `alpha` | Greek letters work by name |
| `\beta` | `beta` | |
| `\Delta` | `Delta` | Uppercase Greek |
| `\Sigma` | `Sigma` | |
| `\phi` | `phi` | |
| `\sum` | `sum` | |
| `\forall` | `forall` | |
| `\exists` | `exists` | |
| `\neg` / `\lnot` | `not` | NOT `neg` |
| `\in` | `in` | |
| `\subset` | `subset` | |
| `\subseteq` | `subset.eq` | |
| `\supset` | `supset` | |
| `\cup` | `union.plus` | NOT `cup` |
| `\cap` | `intersection` | NOT `cap` |
| `\rightarrow` | `arrow.r` | |
| `\leftarrow` | `arrow.l` | |
| `\leftrightarrow` | `arrow.l.r` | |
| `\Leftrightarrow` | `arrow.l.r.double` | |
| `\Rightarrow` | `arrow.r.double` | |
| `\Leftarrow` | `arrow.l.double` | |
| `\approx` | `approx` | |
| `\equiv` | `equiv` | |
| `\times` | `times` | |
| `\cdot` | `dot.op` | Binary operator ⋅. Use `dot(x)` for accent, `dot.op` for operator |
| `\dots` / `\ldots` | `dots.h` / `dots.c` | |
| `\leq` / `\leqslant` | `<=` | |
| `\geq` / `\geqslant` | `>=` | |
| `\neq` | `!=` | |
| `\pm` | `plus.minus` | |
| `\infty` | `infinity` | NOT `infty` |
| `\partial` | `partial` | |
| `\nabla` | `nabla` | |
| `\mathcal{I}` | `cal(I)` | |
| `\mathbb{R}` | `bb(R)` | |
| `\mathbf{x}` | `bold(x)` | |
| `\dot{x}` | `dot(x)` | |
| `\hat{x}` | `hat(x)` | |
| `\bar{x}` | `macron(x)` | |
| `\overline{x}` | `overline(x)` | |
| `\sqrt{x}` | `sqrt(x)` | |
| `\frac{a}{b}` | `frac(a, b)` | or just `(a)/b` auto-detected |
| `\binom{n}{k}` | `binom(n, k)` | |

#### Symbols with Typst modifier names (NOT Unicode)

Typst uses a base symbol + dot modifiers system. These symbols all have proper Typst names — do NOT use Unicode.

| LaTeX | Typst | Notes |
|-------|-------|-------|
| `\sqsubseteq` | `subset.eq.sq` | Base `subset` + `.eq.sq` modifiers |
| `\sqsupseteq` | `supset.eq.sq` | |
| `\sqcap` | `inter.sq` | Base `inter` + `.sq` |
| `\sqcup` | `union.sq` | Base `union` + `.sq` |
| `\circ` | `compose` | Function composition ∘ |
| `\mapsto` | `mapsto` | Alias for `arrow.r.bar` |
| `\vdash` | `tack.r` | Turnstile ⊢ |
| `\dashv` | `tack.l` | Left turnstile ⊣ |
| `\models` | `tack.r.double` | Double turnstile ⊨ (NOT `models` — that's ⊧, a different symbol!) |
| `\top` | `top` | |
| `\bot` | `bot` | |
| `\wedge` | `and` | |
| `\vee` | `or` | |
| `\Diamond` | `diamond` | |
| `\Box` | `square` | |
| `\hookrightarrow` | `arrow.r.hook` | Hook arrow ↪ |
| `\bar{x}` | `macron(x)` | Accent function |
| `\overline{x}` | `overline(x)` | Accent function |
| `\dot{x}` | `dot(x)` | Accent function (dot above) |

**CRITICAL: `models` vs `tack.r.double`**
Typst's `models` = ⊧ (U+22A7), which is a DIFFERENT symbol from LaTeX's `\models` = ⊨ (U+22A8).
Use `tack.r.double` (or `tack.rr`) for the standard double-turnstile "models" relation.

### LaTeX Constructs Not in Typst

| LaTeX | Status | Typst alternative |
|-------|--------|-------------------|
| `\stackrel{a}{b}` | Does NOT exist | Place text above/below using `scripts(b, a)` or just write `$b "with" a$` |
| `\overset{a}{b}` | Does NOT exist | Same as above |
| `\underbrace{...}` | Use `underbrace(...)` | |
| `\overbrace{...}` | Use `overbrace(...)` | |
| `\text{...}` | Use `"..."` (quotes) | `$"text in math"$` |
| `\mathrm{...}` | Use `"..."` or `upright(...)` | |
| `\;` `\,` `\:` | Use `;` `thin` `:` | See spacing table above |
| `\And` `\and` | Use `and` (logical) or `&` (spacing) | |
| `\circ` | Use `compose` | NOT Unicode |
| `\neg` | Use `not` | |

### Working Math Examples

```typst
// Set theory
$A subset.eq B$                    // A ⊆ B
$A union.plus B$                   // A ∪ B
$A intersection B$                 // A ∩ B
$A setminus B$                     // A \ B

// Logic
$T tack.r.double phi$               // T ⊨ φ (models = double turnstile)
$not phi$                          // ¬φ
$phi and psi$                      // φ ∧ ψ
$phi or psi$                       // φ ∨ ψ
$forall x. exists y. R(x, y)$     // ∀x.∃y.R(x,y)

// Entailment
$T tack.r.double_(Sigma) phi$     // T ⊨_Σ φ
$M' tack.r.double_(Sigma') sigma(phi) quad arrow.l.r.double quad M'|_sigma tack.r.double_Sigma phi$

// Relations
$R compose S$                       // composition ∘
$R^(-1)$                           // inverse
$C subset.eq.sq D$                 // subsumption ⊑

// Calligraphic / blackboard bold
$cal(I) = (Delta^cal(I), dot^cal(I))$   // 𝓘 = (Δ^𝓘, ⋅^𝓘)
$bb(R), bb(N), bb(Z)$              // ℝ, ℕ, ℤ

// Matrix and cases
$mat(1, 0; 0, 1)$                  // 2×2 identity
$cases(1 "if" x > 0, 0 "if" x <= 0)$  // piecewise

// Subscripts on operators
$sum_(k=1)^n k = (n(n+1))/2$       // sum with limits
$prod_(i=1)^n x_i$                 // product with limits
$int_0^infinity f(x) thin d x$    // integral (use thin for spacing before dx)
```

---

## Bibliography

### `bibliography()` function

```typst
// Minimal
#bibliography("refs.bib")

// With options
#bibliography(
  "refs.bib",
  title: "References",   // custom title; none = no heading
  style: "ieee",         // citation style
  full: false,           // true = include all entries even if uncited
)

// Multiple files
#bibliography(("refs.bib", "extra.yaml"))

// Custom CSL style file
#bibliography("refs.bib", style: "my-style.csl")

// Force numbered heading
#show bibliography: set heading(numbering: "1.")
```

**Supported file formats:**
- BibLaTeX `.bib` — standard LaTeX format
- Hayagriva `.yaml` / `.yml` — Typst's native YAML format

---

## Citation Syntax

### Shorthand (most common)

```typst
@key                  // basic citation
@key[p.~7]            // with supplement (page, chapter, etc.)
@key @other           // multiple citations
```

### `cite()` function (explicit)

```typst
#cite(<key>)
#cite(<key>, supplement: [p.~7])
#cite(<key>, form: "prose")   // in-sentence: "Smith et al. (2023) showed..."
#cite(<key>, form: "full")    // full entry inline
#cite(<key>, form: "author")  // author name only
#cite(<key>, form: "year")    // year only
#cite(<key>, form: none)      // silent: add to bibliography but show nothing
#cite(<key>, style: "apa")    // override style for this one citation

// Keys with special characters (slashes, colons) — can't use @key shorthand
#cite(label("DBLP:books/lib/Knuth86a"))
```

### Citation forms vs LaTeX equivalents

| Form | Use case | LaTeX |
|------|----------|-------|
| `"normal"` | End-of-sentence source | `\cite{}` |
| `"prose"` | In-sentence reference | `\citet{}` / `\textcite{}` |
| `"full"` | Full entry inline | — |
| `"author"` | Author name only | `\citeauthor{}` |
| `"year"` | Year only | `\citeyear{}` |
| `none` | Silent (add to bib) | `\nocite{}` |

---

## BibLaTeX `.bib` Format

```bibtex
@article{smith2023,
  author  = {Smith, John and Doe, Jane},
  title   = {A Study of Something},
  journal = {Journal of Things},
  year    = {2023},
  volume  = {42},
  number  = {3},
  pages   = {100--115},
  doi     = {10.1000/xyz123},
}

@book{knuth1986,
  author    = {Knuth, Donald E.},
  title     = {The TeXbook},
  publisher = {Addison-Wesley},
  year      = {1986},
}

@inproceedings{jones2022,
  author    = {Jones, Alice},
  title     = {Fast Algorithms},
  booktitle = {Proceedings of ICML 2022},
  year      = {2022},
  pages     = {500--510},
}

@misc{webpage2024,
  author  = {Author, A.},
  title   = {Page Title},
  year    = {2024},
  url     = {https://example.com},
  urldate = {2024-01-15},
}
```

---

## Hayagriva `.yaml` Format (Typst Native)

Top-level keys are citation keys. Each entry is a mapping.

```yaml
# Journal article
smith2023:
  type: Article
  title: A Study of Something
  author: ["Smith, John", "Doe, Jane"]
  date: 2023
  serial-number:
    doi: "10.1000/xyz123"
  page-range: 100-115
  parent:
    type: Periodical
    title: Journal of Things
    volume: 42
    issue: 3

# Book
knuth1986:
  type: Book
  title: The TeXbook
  author: Knuth, Donald E.
  publisher: Addison-Wesley
  date: 1986

# Conference paper
jones2022:
  type: Article
  title: Fast Algorithms
  author: Jones, Alice
  date: 2022
  page-range: 500-510
  parent:
    type: Proceedings
    title: Proceedings of ICML 2022

# Web page with access date
webpage2024:
  type: Web
  title: Page Title
  author: Author, A.
  date: 2024
  url:
    value: https://example.com
    date: 2024-01-15   # access date

# Thesis
mythesis:
  type: Thesis
  title: My Doctoral Dissertation
  author: Researcher, R.
  date: 2023
  genre: Doctoral dissertation
  organization: University of Example

# Software repository
myrepo:
  type: Repository
  title: My Software
  author: Dev, A.
  url: https://github.com/example/repo
  date: 2024
```

### Hayagriva entry types

| Type | Description |
|------|-------------|
| `Article` | Journal/magazine article |
| `Book` | Long-form bound publication |
| `Chapter` | Section of a book |
| `Thesis` | Dissertation or thesis |
| `Report` | Technical/organizational report |
| `Web` | Web-native content |
| `Proceedings` | Conference proceedings |
| `Periodical` | Journal, magazine, newspaper |
| `Repository` | Source code repository |
| `Anthology` | Edited collection |
| `Video` | Motion picture |
| `Audio` | Recorded audio |
| `Artwork` | Artistic work |
| `Patent` | Patent document |
| `Legislation` | Legal document |
| `Misc` | Catch-all |

### Hayagriva key fields

| Field | Notes |
|-------|-------|
| `type` | Required; case-insensitive |
| `title` | Wrap in `"{...}"` to protect casing |
| `author` | `"Last, First"` or array `["Last, First", "Other, Name"]` |
| `date` | ISO 8601: `YYYY`, `YYYY-MM`, or `YYYY-MM-DD` |
| `parent` | Nested entry for containing work (journal, book, proceedings) |
| `publisher` | String or `{name:, location:}` |
| `volume` | Numeric or string |
| `issue` | Numeric or string |
| `page-range` | e.g. `100-115` or `S10-15` |
| `url` | String or `{value:, date:}` for access date |
| `serial-number` | Dict with keys: `doi`, `isbn`, `issn`, `arxiv`, `pmid` |
| `edition` | Numeric or string |
| `genre` | e.g. `"Doctoral dissertation"` |
| `organization` | Institution name |
| `language` | Unicode lang ID: `en`, `zh-Hans` |

### Hayagriva author format

```yaml
author: Smith, John                          # single author
author: ["Smith, John", "Doe, Jane"]         # multiple authors
author: von der Leyen, Ursula                # with prefix
author: UNICEF                               # institutional
author:                                      # verbose form
  given-name: Gloria Jean
  name: Watkins
  alias: bell hooks
```

---

## Bibliography Styles

### By discipline

| Field | Style string |
|-------|-------------|
| Engineering, IT | `"ieee"` |
| Psychology, Life Sciences | `"apa"` |
| Social Sciences | `"chicago-author-date"` |
| Humanities | `"mla"` |
| Humanities (footnotes) | `"chicago-notes"` |
| Economics | `"harvard-cite-them-right"` |
| Physics | `"american-physics-society"` |
| Chemistry | `"american-chemical-society"` |
| Medicine | `"vancouver"` |
| Computer Science | `"association-for-computing-machinery"` |
| Biology | `"american-society-for-microbiology"` |

### Other notable styles

```
"alphanumeric"              // [Smi23] labels
"nature"
"springer-basic"
"elsevier-harvard"
"chicago-shortened-notes"
"turabian-author-date"
"iso-690-numeric"
```

80+ built-in styles. Any CSL file from the CSL repository also works.

---

## Practical Examples

### Minimal document with bibliography

```typst
= My Paper

This was proven by Smith @smith2023. Multiple sources
confirm this @smith2023 @jones2022.

As noted in @knuth1986[ch.~3], the algorithm is efficient.

#cite(<jones2022>, form: "prose") showed that performance
scales linearly.

#bibliography("refs.bib", style: "ieee")
```

### LaTeX-look document

```typst
#set page(margin: 1.75in)
#set par(leading: 0.55em, spacing: 0.55em, first-line-indent: 1.8em, justify: true)
#set text(font: "New Computer Modern")
#show raw: set text(font: "DejaVu Sans Mono")   // NCM Mono not available on all systems
#show heading: set block(above: 1.4em, below: 1em)

= Introduction

As shown by @smith2023, this approach works well.

#bibliography("refs.bib", style: "ieee")
```

---

## Gotchas and Differences from LaTeX

1. **`@key` is overloaded** — works for both label cross-references and citations. Typst resolves automatically.

2. **Bibliography only shows cited works** by default. Use `full: true` or `#cite(<key>, form: none)` for silent inclusion.

3. **Bibliography heading is unnumbered** by default:
   ```typst
   #show bibliography: set heading(numbering: "1.")
   ```

4. **Keys with special characters** (slashes, colons) require:
   ```typst
   #cite(label("key:with:colons"))
   ```

5. **Hayagriva uses `parent:` instead of separate fields** — no `journal`, `booktitle`, `series`. The containing work is always a nested `parent:` entry.

6. **Hayagriva dates must be ISO 8601** (`YYYY-MM-DD`, `YYYY-MM`, `YYYY`), not free-form strings.

7. **`serial-number` for DOI/ISBN** is a sub-dictionary:
   ```yaml
   serial-number:
     doi: "10.1000/xyz"
     isbn: "978-0-000-00000-0"
   ```

8. **No `\bibliography` + `\bibliographystyle` split** — Typst combines both into one `bibliography()` call.

9. **Styles use CSL** (Citation Style Language), not `.bst`/`.bbx`. Download any `.csl` file from the CSL repository and pass its path as `style:`.

10. **No backslash commands in math mode** — Typst is not LaTeX. `\models`, `\sqsubseteq`, `\circ`, `\neg`, `\;`, `\,` all fail. Use Typst symbol names: `tack.r.double`, `subset.eq.sq`, `compose`, `not`, `;`, `thin`. See the LaTeX → Typst Math Symbol Mapping section above. Do NOT use Unicode characters as a fallback — every common math symbol has a proper Typst name.

11. **Multi-letter identifiers in math must be quoted** — Typst treats each letter as a separate variable. `$models$` errors with "unknown variable: odels". Write `$"models"$` or `$"Mod"(T)$` instead. Note: for the *entailment relation* (LaTeX `\models` = ⊨), use `tack.r.double`, NOT the quoted word `"models"` (which is Typst's `models` = ⊧, a different symbol).

12. **`"New Computer Modern Mono"` font may not be available** — on NixOS and some systems this font is missing. Use `"DejaVu Sans Mono"` or another available monospace font for `#show raw: set text(font: ...)`.

13. **`stackrel` and `overset` do not exist** — for text above/below arrows or symbols, use `scripts()` or restructure the expression. `$"BAOs" arrow.l.r.double "frames" quad "duality"$` instead of `$\stackrel{\text{duality}}{\leftrightarrow}$`.

### LaTeX → Typst quick reference

| LaTeX | Typst |
|-------|-------|
| `\cite{key}` | `@key` |
| `\cite[p.~7]{key}` | `@key[p.~7]` |
| `\citet{key}` / `\textcite{key}` | `#cite(<key>, form: "prose")` |
| `\nocite{key}` | `#cite(<key>, form: none)` |
| `\bibliography{refs}` + `\bibliographystyle{...}` | `#bibliography("refs.bib", style: "ieee")` |
| `\bibliography{a,b}` | `#bibliography(("a.bib", "b.yaml"))` |

### LaTeX → Typst math quick reference

| LaTeX | Typst | Notes |
|-------|-------|-------|
| `\models` | `tack.r.double` | NOT `models` (that's ⊧, different symbol!) |
| `\vdash` | `tack.r` | Turnstile |
| `\dashv` | `tack.l` | Left turnstile |
| `\sqsubseteq` | `subset.eq.sq` | Modifier chain |
| `\sqsupseteq` | `supset.eq.sq` | |
| `\sqcap` | `inter.sq` | |
| `\sqcup` | `union.sq` | |
| `\circ` | `compose` | Function composition |
| `\mapsto` | `mapsto` | Alias for `arrow.r.bar` |
| `\hookrightarrow` | `arrow.r.hook` | |
| `\neg` | `not` | NOT `neg` |
| `\cup` | `union.plus` | NOT `cup` |
| `\cap` | `intersection` | NOT `cap` |
| `\infty` | `infinity` | NOT `infty` |
| `\cdot` | `dot.op` | Binary operator; `dot(x)` is accent |
| `\Rightarrow` | `arrow.r.double` | |
| `\Leftrightarrow` | `arrow.l.r.double` | |
| `\;` | `;` | Medium space |
| `\,` | `thin` | Thin space |
| `\:` | `:` | Thick space |
| `\text{...}` | `"..."` | Quoted text in math |
| `\mathcal{I}` | `cal(I)` | |
| `\mathbb{R}` | `bb(R)` | |
| `\mathbf{x}` | `bold(x)` | |
| `\bar{x}` | `macron(x)` | Accent function |
| `\overline{x}` | `overline(x)` | Accent function |
| `\stackrel{a}{b}` | `scripts(b, a)` or restructure | Does NOT exist as-is |
| `\frac{a}{b}` | `frac(a, b)` or `(a)/b` | Auto-detected in many cases |
