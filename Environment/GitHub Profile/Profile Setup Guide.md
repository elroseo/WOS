# GitHub Profile Setup Guide

How my public GitHub profile is built, how to edit it, and ideas for the future.

**Live at:** https://github.com/elroseo
**Source repo:** `elroseo/elroseo` (the "special" repo named after my username. A README there renders on the profile homepage.)

---

## Files in this folder

| File | What it is | Where it lives online |
|---|---|---|
| [[profile-readme.md]] | My profile homepage content | `elroseo/elroseo/README.md` |
| [[working-with-me.md]] | Public human user guide, linked from the profile | `elroseo/elroseo/working-with-me.md` |

> These are the vault copies (source of truth I edit here). After editing, publish to the repo and they render live. See "How to edit" below.

---

## What's on the profile now

1. **Animated typing banner** (readme-typing-svg). Cycles through five lines: greeting, role, Brit in Canada, systems thinker, dog mum to Lucy.
2. **Where I came from / A little more about me / Working with me** sections.
3. **Contribution snake** at the bottom. A snake that eats my contribution graph, theme-aware (light/dark).

### The typing banner

The banner is a single image URL. Edit the `lines=` part to change the rotating text.

```
https://readme-typing-svg.demolab.com?font=Fira+Code&size=22&duration=3000&pause=1000&color=2F81F7&center=true&vCenter=true&width=750&lines=LINE1;LINE2;LINE3
```

Rules for editing `lines=`:
- Separate each line with a semicolon `;`
- Spaces become `+` (e.g. `Hi+there`)
- Emoji use URL encoding. Handy ones I use:
  - 👋🏻 wave, light tone = `%F0%9F%91%8B%F0%9F%8F%BB`
  - 🇬🇧🇨🇦 UK + Canada flags = `%F0%9F%87%AC%F0%9F%87%A7%F0%9F%87%A8%F0%9F%87%A6`
  - 🧩 puzzle = `%F0%9F%A7%A9`
  - 🐶 dog = `%F0%9F%90%B6`
- Other knobs: `font=` (Google Font), `size=`, `color=` (hex, no `#`), `width=` (widen if text clips), `duration=`, `pause=`
- **Preview before committing:** paste the full URL into a browser to see it animate.

### The contribution snake

Powered by a GitHub Action, no manual upkeep.

- **Workflow file:** `.github/workflows/snake.yml` in `elroseo/elroseo`
- **Action used:** `Platane/snk@v3` (the standard, widely used one)
- **How it works:** runs daily at midnight UTC (and on every push to main). It regenerates the snake SVGs and pushes them to the `output` branch. The README embeds those SVGs.
- **Output files:** `github-snake.svg` (light) and `github-snake-dark.svg` (dark) on the `output` branch
- **Run it manually anytime:** repo → Actions tab → "Generate Snake" → Run workflow
- **Note:** the `workflow` OAuth scope is required to edit workflow files via `gh`. Add it with `gh auth refresh -h github.com -s workflow`.

---

## How to edit the profile

Two options.

**Option A: edit in the browser (quickest for small text changes)**
1. Go to the file on github.com (README.md or working-with-me.md in `elroseo/elroseo`)
2. Click the pencil icon, edit, use the Preview tab, commit.
3. Then pull the change back into this vault folder so the two stay in sync (see sync note below).

**Option B: edit here in the vault, then publish (my usual flow)**
1. Edit the file in this folder.
2. Publish it to the repo with `gh api`:
   ```bash
   # from the vault root
   FILE="Environment/GitHub Profile/profile-readme.md"   # or working-with-me.md
   SHA=$(gh api repos/elroseo/elroseo/contents/README.md --jq '.sha')
   gh api repos/elroseo/elroseo/contents/README.md -X PUT \
     -f message="Update profile README" \
     -f content="$(base64 -i "$FILE" | tr -d '\n')" \
     -f sha="$SHA"
   ```
   (For working-with-me.md, target `contents/working-with-me.md` instead.)
3. Commit and push the vault too.

**Verify they match:**
```bash
diff <(gh api repos/elroseo/elroseo/contents/README.md --cache 0 --jq '.content' | base64 -d) "Environment/GitHub Profile/profile-readme.md"
```
> The GitHub contents API can serve a cached (stale) copy for a few seconds right after a write. Use `--cache 0` and re-check if a diff looks wrong.

---

## Ideas to add later

From the "From Meh to Marvelous" guide (Chijioke Okorji) plus a few of my own. Pick what fits, keep it clean and not cluttered.

- **Skill badges** (`skillicons.dev`): quick icons for my toolkit. Good fit for a CRE:
  `https://skillicons.dev/icons?i=linux,bash,git,github,ansible,docker,py`
- **Social / contact badges** (`shields.io`): LinkedIn, blog, email as coloured badges.
- **GitHub stats cards** (`github-readme-stats`): commits, streak, top languages. Note: as a mostly-internal GitHub employee, public stats may look sparse, so weigh whether it adds value.
- **Visitor counter** (`profile-counter.glitch.me`): simple view count. Fun but low value.
- **"Currently learning" line:** e.g. GitHub Foundations, Kusto/KQL, Splunk. Ties to my ramp goals.
- **Fun fact / personality:** a non-work line (golf, niche playlists, "How It's Made" reruns). Adds warmth.
- **Pinned repositories:** curate the repos shown on the profile (done via GitHub UI, not the README).
- **Banner image:** a custom header image instead of or above the typing SVG, if I want a stronger visual.

### Editing principle

Keep it minimal and clear with a bit of fun (matches my voice). Every element should earn its place. Preview before committing.

---

## Related

- [[Voice/Writing Style|Writing Style]] (voice for profile copy)
- [[working-with-me.md|Working with me guide]]
- Reference article: "From Meh to Marvelous: The Ultimate Guide to Crafting a Killer GitHub Profile" (Chijioke Okorji, Medium)
