# GitHub Markdown Cheatsheet

## What is GitHub Flavored Markdown?

Markdown is a lightweight plain-text formatting syntax that converts to HTML. **GitHub Flavored Markdown (GFM)** is GitHub's superset of the CommonMark standard, adding features like tables, task lists, strikethrough, autolinking, footnotes, and alerts. It's used everywhere on GitHub: README files, issues, pull requests, comments, wikis, discussions, and gists. The same syntax also powers tools like Obsidian (with minor differences).

## How it's typically used

- Writing README and documentation files (`.md`)
- Formatting issues, pull requests, and comments
- Authoring wikis and discussions
- Writing release notes and changelogs

## CRE perspective

Clear, well-formatted writing in issues, PRs, and customer-facing docs makes troubleshooting faster and reduces back-and-forth. Knowing GFM lets you build readable repro steps (code blocks + numbered lists), structured comparisons (tables), collapsible logs (`<details>`), and prominent warnings (alerts) — all of which make support threads and internal notes easier to scan.

> **Note:** GitHub renders Markdown slightly differently across contexts. Alerts (`> [!NOTE]`) render on github.com but not in plain Markdown viewers. Raw HTML is allowed in GitHub but sanitized (no scripts).

---

## Headings

```markdown
# H1 — Page title
## H2 — Section
### H3 — Subsection
#### H4
##### H5
###### H6
```

GitHub auto-generates an anchor link for each heading and builds a table of contents from them in the file header dropdown.

---

## Text emphasis

| Style | Syntax | Result |
|---|---|---|
| Bold | `**bold**` or `__bold__` | **bold** |
| Italic | `*italic*` or `_italic_` | *italic* |
| Bold + Italic | `***both***` | ***both*** |
| Strikethrough | `~~struck~~` | ~~struck~~ |
| Subscript | `H<sub>2</sub>O` | H₂O |
| Superscript | `X<sup>2</sup>` | X² |
| Inline code | `` `code` `` | `code` |

---

## Blockquotes

```markdown
> This is a quote.
>
> > Nested quotes use multiple `>`.
```

> This is a quote.
>
> > Nested quotes use multiple `>`.

---

## Lists

### Unordered

```markdown
- Item one
- Item two
  - Nested (indent 2 spaces)
    - Deeper
* Asterisks work too
+ So do plus signs
```

### Ordered

```markdown
1. First
2. Second
   1. Nested ordered
3. Third
```

> Numbers don't have to be sequential — GitHub renumbers automatically. `1.` repeated still renders 1, 2, 3.

### Task lists

```markdown
- [x] Completed task
- [ ] Open task
- [ ] Another to do
```

- [x] Completed task
- [ ] Open task

In issues and PRs these become interactive checkboxes you can click.

---

## Links

| Type | Syntax |
|---|---|
| Inline | `[GitHub](https://github.com)` |
| Inline + title | `[GitHub](https://github.com "tooltip")` |
| Reference | `[text][ref]` … then `[ref]: https://url` |
| Autolink | `<https://github.com>` |
| Bare URL | `https://github.com` (GFM autolinks it) |
| Relative (repo) | `[docs](./docs/README.md)` |
| Heading anchor | `[jump](#text-emphasis)` |

```markdown
[Inline link](https://github.com)
[Reference link][gh]

[gh]: https://github.com
```

---

## Images

```markdown
![Alt text](https://example.com/image.png)
![Alt text](./relative/path.png "Optional title")
```

Sizing and alignment need HTML:

```markdown
<img src="image.png" alt="diagram" width="400">
<p align="center"><img src="logo.png" width="120"></p>
```

You can also paste/drag images directly into issues and PRs — GitHub uploads and inserts the link for you.

---

## Code

### Inline

```markdown
Use the `ghe-config` command.
```

### Fenced blocks with syntax highlighting

````markdown
```bash
ghe-support-bundle -o > bundle.tgz
```

```python
def hello(name):
    return f"Hi {name}"
```

```kql
Requests | where Timestamp > ago(1h) | take 10
```
````

Add the language after the opening ``` for syntax highlighting. Use `~~~` as an alternative fence, or indent 4 spaces for an unhighlighted block.

### Showing literal backticks

Wrap with more backticks than the content uses:

````markdown
`` `code with backtick` ``
````

---

## Tables

```markdown
| Left | Center | Right |
|:-----|:------:|------:|
| a    | b      | c     |
| longer cell | x | 100 |
```

| Left | Center | Right |
|:-----|:------:|------:|
| a    | b      | c     |
| longer cell | x | 100 |

- `:---` left-align, `:--:` center, `---:` right-align.
- The header row and separator (`---`) are required.
- Columns don't need to line up in source — only the pipes matter.
- Escape a literal pipe inside a cell with `\|`.

---

## Horizontal rule

```markdown
---
***
___
```

Three or more hyphens, asterisks, or underscores on their own line.

---

## Alerts (GitHub callouts)

```markdown
> [!NOTE]
> Useful information users should know.

> [!TIP]
> Helpful advice for doing things better.

> [!IMPORTANT]
> Key information users need to succeed.

> [!WARNING]
> Urgent info needing immediate attention.

> [!CAUTION]
> Advises about risks or negative outcomes.
```

These render as colored, icon-prefixed boxes on GitHub. Five types: **NOTE, TIP, IMPORTANT, WARNING, CAUTION**.

---

## Collapsible sections

```markdown
<details>
<summary>Click to expand logs</summary>

```text
...long log output here...
```

</details>
```

<details>
<summary>Click to expand</summary>

Hidden content shows when clicked. Great for long logs or optional detail in issues.

</details>

> Leave a blank line after `</summary>` so Markdown inside renders correctly.

---

## Footnotes

```markdown
Here is a statement with a footnote.[^1]

[^1]: This is the footnote text.
```

GitHub renders footnotes as superscript links that jump to definitions at the bottom.

---

## Mentions, references & emoji (GitHub-only)

| Feature | Syntax | Result |
|---|---|---|
| Mention user/team | `@octocat` / `@org/team` | Notifies them |
| Reference issue/PR | `#123` | Links to issue/PR #123 |
| Reference in other repo | `owner/repo#123` | Cross-repo link |
| Reference commit | paste the SHA | Auto-links to the commit |
| Emoji | `:rocket:` `:+1:` | 🚀 👍 |

These only work inside GitHub (issues, PRs, comments, discussions), not in plain `.md` files rendered elsewhere.

---

## Escaping characters

Prefix a Markdown special character with a backslash to show it literally:

```markdown
\*not italic\*   \#not a heading   \`not code\`
```

Escapable characters: `` \ ` * _ { } [ ] ( ) # + - . ! | ~ ``

---

## Line breaks & paragraphs

- A **blank line** separates paragraphs.
- End a line with **two trailing spaces** (or a `\`) to force a single line break without a new paragraph.
- A single newline (no trailing spaces) usually does *not* create a break in rendered Markdown.

---

## Comments (hidden text)

```markdown
<!-- This text won't render on the page -->
```

Useful for notes-to-self in a README or templated issue forms.

---

## Math (LaTeX)

```markdown
Inline: $E = mc^2$

Block:
$$
\sum_{i=1}^{n} i = \frac{n(n+1)}{2}
$$
```

GitHub renders LaTeX math via MathJax in Markdown files, issues, and PRs.

---

## Reference table — all GFM syntax

| Element | Syntax |
|---|---|
| Heading | `# H1` … `###### H6` |
| Bold | `**text**` |
| Italic | `*text*` |
| Bold + Italic | `***text***` |
| Strikethrough | `~~text~~` |
| Subscript | `<sub>text</sub>` |
| Superscript | `<sup>text</sup>` |
| Inline code | `` `code` `` |
| Code block | ` ```lang … ``` ` |
| Blockquote | `> quote` |
| Nested quote | `> > quote` |
| Unordered list | `- item` / `* item` / `+ item` |
| Ordered list | `1. item` |
| Task list | `- [ ]` / `- [x]` |
| Inline link | `[text](url)` |
| Link + title | `[text](url "title")` |
| Reference link | `[text][ref]` + `[ref]: url` |
| Autolink | `<url>` |
| Image | `![alt](url)` |
| Sized image | `<img src="" width="">` |
| Table | `\| a \| b \|` + `\|---\|---\|` |
| Column align | `:---` `:--:` `---:` |
| Horizontal rule | `---` / `***` / `___` |
| Alert | `> [!NOTE]` (NOTE/TIP/IMPORTANT/WARNING/CAUTION) |
| Collapsible | `<details><summary>…</summary>…</details>` |
| Footnote | `text[^1]` + `[^1]: note` |
| Mention | `@user` |
| Issue/PR ref | `#123` / `owner/repo#123` |
| Emoji | `:emoji_name:` |
| Escape | `\*` `\#` `\`` etc. |
| Hard line break | two trailing spaces or `\` |
| Comment | `<!-- hidden -->` |
| Inline math | `$E = mc^2$` |
| Block math | `$$ … $$` |

---

## Quick reference links

- [GitHub: Basic writing and formatting syntax](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)
- [GitHub Flavored Markdown Spec](https://github.github.com/gfm/)
- [Working with advanced formatting](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting)
- [Mastering Markdown](https://guides.github.com/features/mastering-markdown/)
- [CommonMark reference](https://commonmark.org/help/)
