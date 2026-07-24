# CRE Account Workspace (Phase 1 scaffold)

A CLI-first way to manage customer accounts as a GitHub CRE. No web dashboard — each
account is a **living note** in this vault plus a **persistent, customer-scoped Copilot
session** that pulls live data on demand.

## Layout
```
Accounts/
  _registry.json            canonical list: slug ↔ display ↔ sf_id ↔ aliases ↔ session_uuid
  _templates/
    index.template.md       template for a new account's "Account Home" note
  bin/
    cre.sh                  shell functions: cre, cre-new, cre-ls
  <slug>/
    index.md                the account's living note (durable + generated snapshot)
```

## Setup (one time)
Add to your `~/.zshrc` (or `~/.bashrc`):
```sh
source "/Users/elroseo/Work GitHub/Accounts/bin/cre.sh"
```
Then `source ~/.zshrc` (or open a new terminal).

## Use
```sh
cre-ls                                   # list managed accounts
cre acme                                 # open the persistent Copilot session for Acme
cre-new globex "Globex Inc" 001ABC "glx" # scaffold + register a new account
```

`cre <alias>` opens Copilot **in that account's folder** with a **deterministic session id**
(so history persists across days) and a seed prompt that:
- reads `@index.md` for your durable context, decisions, and action items;
- treats the `Snapshot (generated)` numbers as stale and **re-pulls live** telemetry /
  activity / opportunities / renewal via the account360 + revenue-mcp skills;
- refuses to hand-edit inside the generated snapshot markers.

## The account note (`<slug>/index.md`)
- **Durable sections** (Contacts, Background, Decisions, Action Items) — *you* own these.
- **Snapshot (generated)** — between `BEGIN/END GENERATED SNAPSHOT` markers; refreshed from
  live data with a source + timestamp. Never hand-edit inside the markers.

## Not built yet (Phase 2, deferred by design)
- A `refresh-snapshot` skill that patches the snapshot section via the Obsidian MCP.
- A portfolio/overview note (worth it once you manage ~4+ accounts).

## Important caveats
- **Directory scoping primes context; it does not isolate.** Global MCPs, memory, and
  instructions still apply. The seed prompt names the account + SF id to reduce mistakes,
  but confirm the account before writing.
- **Governance:** decide what live business data (Salesforce/Gong/email/Teams) is allowed
  to persist in this vault. Default: store your notes, decisions, IDs, and links — not
  copied transcripts or full commercial reports.

`acme-corp/` is a **placeholder** for review. Replace it with a real account via `cre-new`,
then delete the folder and its registry entry.
