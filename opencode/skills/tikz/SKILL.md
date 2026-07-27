---
name: tikz
description: Use when drawing diagrams in LaTeX with TikZ. Covers node placement, arrows, styles, avoiding overlaps, anchor points, positioning library, common patterns (flowcharts, state machines, trees, comparison panels), and debugging layout issues. Use when user asks for "tikz diagram", "flowchart in latex", "draw diagram", or when a TikZ diagram has overlapping elements.
---

# TikZ Diagram Skill

## Minimum viable TikZ

```latex
\usepackage{tikz}
\usetikzlibrary{positioning, arrows.meta, calc, fit, shapes.geometric}
```

Always load these five libraries. They cover 95% of use cases.

## Core concepts

### Nodes vs draws

- **Nodes** are boxes/circles with content. Use `at` for coordinates:
  ```latex
  \node[style] (name) at (x, y) {content};
  ```

- **Draws** are lines/arrows between coordinates or node anchors. **Never** use `at` with `\draw`:
  ```latex
  % CORRECT
  \draw[->] (0,0) -- (3,0);
  \draw[->] (A) -- (B);

  % WRONG — causes "Arc expected" error
  \draw[->] at (0,0) -- (3,0);
  ```

### Anchor points

Every node has named anchors. Use them to avoid arrows passing through node centers:

```
     north
       |
west --center-- east
       |
     south
```

Diagonal anchors: `north east`, `north west`, `south east`, `south west`.

```latex
\draw[->] (A.east) -- (B.west);         % horizontal arrow
\draw[->] (A.north) -- (B.south);       % vertical arrow
\draw[->] (A.north east) -- (B.south west);  % diagonal
```

### Node styles

Define styles once at the top of `tikzpicture`:

```latex
\begin{tikzpicture}[
  >=Stealth,                    % arrow tip style
  box/.style={rectangle, draw, thick, minimum size=1cm, font=\small, fill=blue!10},
  circle/.style={circle, draw, thick, minimum size=0.8cm, font=\small, fill=blue!10},
  arrow/.style={->, thick, black},
  label/.style={font=\scriptsize, fill=white, inner sep=2pt},
]
```

- `minimum size` sets the **circle diameter** or **rectangle minimum side**. Prevents tiny nodes.
- `inner sep` controls padding between content and border. `inner sep=0pt` for compact nodes.
- `fill=blue!10` = 10% blue, 90% white. Use `!20`, `!25` for subtle backgrounds.
- **Always** give styles a name ending in `/.style` — don't inline repeat options.

## Avoiding overlaps — the #1 TikZ problem

### Rule 1: Use coordinates with enough spacing

```latex
% BAD — nodes 2cm apart, labels overlap
\node[box] (A) at (0, 0) {Long text};
\node[box] (B) at (2, 0) {Long text};

% GOOD — 4cm apart
\node[box] (A) at (0, 0) {Long text};
\node[box] (B) at (4, 0) {Long text};
```

Minimum spacing for readable diagrams:
- Horizontal: 3-4cm between node centers
- Vertical: 2-3cm between node centers
- For nodes with text below them: add 1-2cm extra

### Rule 2: Bidirectional arrows — use different anchor heights

Two arrows between the same pair of nodes **must** use different anchors:

```latex
% BAD — both arrows on same line, overlap
\draw[->] (A.east) -- (B.west);
\draw[<-] (A.east) -- (B.west);

% GOOD — one above, one below
\draw[->] (A.north east) -- (B.north west);   % upper arrow
\draw[<-] (A.south east) -- (B.south west);   % lower arrow
```

### Rule 3: Labels go on arrows with `fill=white`

```latex
\draw[->] (A) -- node[label, above] {text} (B);
```

The `fill=white` in the label style makes the text background opaque, so it masks the arrow line behind it. Without this, labels overlap arrows.

### Rule 4: Don't put text inside the diagram area

Put node descriptions in a caption **below** the diagram, not as floating text nodes:

```latex
% BAD — text nodes overlap arrows
\node[font=\scriptsize, below=0.1cm of A] {has 1, wants 2};

% GOOD — describe in caption
% (in the \textit{} paragraph after \end{tikzpicture})
```

### Rule 5: Use `\node` for labels, `\draw` for lines

```latex
% Label positioned at a coordinate
\node[font=\scriptsize, green!50!black] at (0, 2.5) {match};

% This is a NODE, not a draw — never use \draw for text
```

## Arrows

### Arrow styles

| Style | Code | Use |
|-------|------|-----|
| Solid arrow | `->, thick` | Normal flow |
| Dashed arrow | `->, thick, dashed, gray` | Optional / secondary |
| Double arrow | `<->` | Bidirectional |
| No arrow | `--` | Plain line |
| Thick arrow | `->, very thick` | Emphasis |
| Stealth tip | `>=Stealth` | Modern arrowhead (set globally) |

### Labeled arrows

```latex
\draw[->] (A) -- node[label, above] {label text} (B);   % label above
\draw[->] (A) -- node[label, below] {label text} (B);   % label below
\draw[->] (A) -- node[label, midway] {label text} (B);  % centered
```

### Curved arrows (use sparingly)

Only when straight arrows would overlap. Use `to[bend]`:

```latex
\draw[->] (A) to[bend left=30] (B);    % curves upward
\draw[->] (A) to[bend right=30] (B);   % curves downward
```

**Don't** use curves for decoration. Use them only to route around obstacles.

## Positioning library

The `positioning` library lets you place nodes relative to others:

```latex
\usetikzlibrary{positioning}

\node[box] (A) {First};
\node[box, right=2cm of A] (B) {Second};        % 2cm to the right
\node[box, below=1cm of A] (C) {Third};         % 1cm below
\node[box, below right=1cm and 2cm of A] (D) {Fourth};  % diagonal
```

### `node distance`

Set default spacing for all relative placements:

```latex
\begin{tikzpicture}[node distance=2cm]
```

### `calc` library for coordinate arithmetic

```latex
\usetikzlibrary{calc}

\draw[->] ($(A.north east) + (0, 0.3)$) -- ($(B.north west) + (0, 0.3)$);
```

Use `$(name) + (offset)$` to shift anchor points. Useful for parallel arrows.

## Common patterns

### Pattern: Comparison panel (left vs right)

```latex
\begin{tikzpicture}[...]
% Left panel
\node[font=\small\bfseries] at (0, 3) {Title Left};
\node[box] (A) at (-2, 1) {A};
\node[box] (B) at (2, 1) {B};
% ... arrows ...

% Divider
\draw[dashed, gray!40] (5, -3) -- (5, 3);

% Right panel
\node[font=\small\bfseries] at (10, 3) {Title Right};
\node[box] (A2) at (8, 1) {A};
\node[box] (B2) at (12, 1) {B};
% ... arrows ...
\end{tikzpicture}
```

Key: left panel centered at x=0, right panel centered at x=10, divider at x=5. Gives 5cm clearance on each side.

### Pattern: Flowchart (top-down)

```latex
\begin{tikzpicture}[
  >=Stealth,
  box/.style={rectangle, draw, thick, minimum width=2.5cm, minimum height=0.8cm, font=\small, fill=blue!10, align=center},
  decision/.style={diamond, draw, thick, minimum size=1.5cm, font=\small, fill=yellow!20, align=center},
  arrow/.style={->, thick, black},
  lbl/.style={font=\scriptsize, fill=white, inner sep=2pt},
]
\node[box] (start) at (0, 0) {Start};
\node[box, below=1.5cm of start] (step1) {Step 1};
\node[decision, below=1.5cm of step1] (check) {Valid?};
\node[box, below=1.5cm of check] (end) {End};
\node[box, right=3cm of check] (retry) {Retry};

\draw[arrow] (start) -- (step1);
\draw[arrow] (step1) -- (check);
\draw[arrow] (check) -- node[lbl, left] {yes} (end);
\draw[arrow] (check) -- node[lbl, above] {no} (retry);
\draw[arrow] (retry) |- (step1);  % right-angle arrow back up
\end{tikzpicture}
```

### Pattern: Tree

```latex
\begin{tikzpicture}[
  >=Stealth,
  node distance=1.5cm,
  box/.style={rectangle, draw, thick, minimum width=2cm, font=\small, fill=blue!10, align=center},
  arrow/.style={->, thick},
]
\node[box] (root) {Root};
\node[box, below left=1cm and 1.5cm of root] (L) {Left};
\node[box, below right=1cm and 1.5cm of root] (R) {Right};
\node[box, below=1cm of L] (LL) {L-L};
\node[box, below=1cm of R] (RR) {R-R};

\draw[arrow] (root) -- (L);
\draw[arrow] (root) -- (R);
\draw[arrow] (L) -- (LL);
\draw[arrow] (R) -- (RR);
\end{tikzpicture}
```

### Pattern: State machine

```latex
\begin{tikzpicture}[
  >=Stealth,
  state/.style={circle, draw, thick, minimum size=1.2cm, font=\small, fill=blue!10},
  arrow/.style={->, thick, black},
  lbl/.style={font=\scriptsize, fill=white, inner sep=2pt},
]
\node[state] (S0) at (0, 0) {$S_0$};
\node[state] (S1) at (4, 0) {$S_1$};
\node[state] (S2) at (8, 0) {$S_2$};

\draw[arrow] (S0) -- node[lbl, above] {event A} (S1);
\draw[arrow] (S1) -- node[lbl, above] {event B} (S2);
\draw[arrow] (S2.north) to[bend left=45] node[lbl, above] {reset} (S0.north);
\draw[arrow] (S1.south) to[bend right=45] node[lbl, below] {fail} (S0.south);
\end{tikzpicture}
```

## Debugging checklist

When a diagram has overlaps or looks wrong, check:

1. **Spacing**: Are nodes at least 3-4cm apart horizontally, 2-3cm vertically?
2. **Bidirectional arrows**: Do paired arrows use different anchors (`north east` vs `south east`)?
3. **Labels**: Do they have `fill=white` in the style to mask the arrow behind?
4. **Text in diagram**: Are there floating text nodes that could be moved to the caption?
5. **Arrow anchors**: Are arrows using `.east`, `.west`, `.north`, `.south` instead of node centers?
6. **`\draw` with `at`**: This causes "Arc expected" error. Remove `at` from draws.
7. **Curved arrows**: Are they necessary? If straight arrows don't overlap, don't curve.
8. **Node size**: Is `minimum size` set? Without it, nodes shrink to text size and arrows clip.
9. **Font size**: Use `\small` for nodes, `\scriptsize` for labels, `\small\bfseries` for titles.

## Compilation

TikZ is included in TeX Live. No extra packages needed. Compile normally:

```bash
docker run --rm -v "$PWD:$PWD" -w "$PWD" texlive/texlive:latest \
  latexmk -pdf -interaction=nonstopmode -synctex=1 document.tex
```

## Quick reference

```latex
% Node
\node[style] (name) at (x, y) {text};

% Edge with label
\draw[->] (A) -- node[lbl, above] {text} (B);

% Edge between anchors
\draw[->] (A.east) -- (B.west);

% Curved edge (only when needed)
\draw[->] (A) to[bend left=30] (B);

% Right-angle edge
\draw[->] (A) |- (B);    % vertical then horizontal
\draw[->] (A) -| (B);    % horizontal then vertical

% Divider line
\draw[dashed, gray!40] (x1, y1) -- (x2, y2);

% Coordinate arithmetic (needs calc library)
\draw[->] ($(A.north) + (0, 0.5)$) -- ($(B.south) + (0, 0.5)$);
```
