---
name: preview
description: Preview Markdown, LaTeX, PDF, or code artifacts in the browser or as PDF. Use when the user wants to review a written artifact, export a report, or view a rendered document.
---

# Preview

Render and open research artifacts for visual review.

## Methods

### Browser Preview

Open markdown or HTML files in the default browser:

```bash
# macOS
open <file.md>
open <file.html>

# Linux
xdg-open <file.md>
xdg-open <file.html>
```

### PDF Export via Pandoc

Convert markdown to PDF using pandoc + LaTeX:

```bash
pandoc <file.md> -o <file.pdf> --pdf-engine=xelatex
```

Requires pandoc and a LaTeX distribution (e.g., `texlive`).

### Quick HTML Preview

For richer markdown rendering, convert to HTML first:

```bash
pandoc <file.md> -o <file.html> --standalone --metadata title="Preview"
open <file.html>  # or xdg-open on Linux
```

## When to Use

- Reviewing a completed research brief, draft, or review
- Exporting a paper draft to PDF for sharing
- Visually inspecting Mermaid diagrams or LaTeX equations in rendered form
