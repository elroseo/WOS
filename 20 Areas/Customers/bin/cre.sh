#!/usr/bin/env bash
# CRE customer launcher. Source this file from your shell rc:
#   source "/Users/elroseo/WOS-PARA/20 Areas/Customers/bin/cre.sh"
#
# Provides:
#   cre <alias>                          open a persistent, customer-scoped Copilot session
#   cre-new <slug> "<Display Name>" <sf_id> [alias1,alias2]   scaffold a new account
#   cre-ls                               list managed accounts
#
# Design notes:
# - Each account has a deterministic session UUID (uuid5 of the slug) so the same
#   customer always resumes the SAME Copilot session (persistent history), while the
#   seed prompt forces a live data refresh so numbers are never stale.
# - Directory scoping PRIMES context; it does not isolate global MCPs/memory. The seed
#   prompt names the canonical account + SF id to reduce cross-account mistakes.
# - Templating and registry writes are done in Python (not sed) so account names
#   containing &, |, /, quotes, etc. are handled safely, and the registry is updated
#   atomically (temp file + os.replace) only after files are written successfully.

# Root of the Customers area. CRE_ACCOUNTS_DIR is retained for shell compatibility.
: "${CRE_ACCOUNTS_DIR:=/Users/elroseo/WOS-PARA/20 Areas/Customers}"
export CRE_ACCOUNTS_DIR

_cre_registry() { printf '%s/_registry.json' "$CRE_ACCOUNTS_DIR"; }

# Resolve an alias/slug to a JSON object.
# exit 0 = printed match; 1 = no match; 3 = registry error; 4 = ambiguous.
_cre_resolve() {
  python3 - "$(_cre_registry)" "$1" <<'PY'
import json, sys
reg, needle = sys.argv[1], sys.argv[2].casefold()
try:
    data = json.load(open(reg))
except FileNotFoundError:
    sys.stderr.write(f"cre: registry not found: {reg}\n"); sys.exit(3)
except Exception as e:
    sys.stderr.write(f"cre: registry unreadable: {e}\n"); sys.exit(3)
matches = []
for a in data.get("accounts", []):
    keys = [a.get("slug", "").casefold()] \
        + [x.casefold() for x in a.get("aliases", [])] \
        + [a.get("display_name", "").casefold()]
    if needle in keys:
        matches.append(a)
if len(matches) > 1:
    names = ", ".join(m.get("slug", "?") for m in matches)
    sys.stderr.write(f"cre: '{needle}' is ambiguous — matches: {names}\n"); sys.exit(4)
if not matches:
    sys.exit(1)
print(json.dumps(matches[0]))
PY
}

cre() {
  local alias="$1"
  if [[ -z "$alias" ]]; then echo "usage: cre <alias>   (see: cre-ls)"; return 2; fi
  local obj rc
  obj="$(_cre_resolve "$alias")"; rc=$?
  if [[ $rc -ne 0 ]]; then
    [[ $rc -eq 1 ]] && echo "cre: no account matching '$alias'. Try: cre-ls"
    return $rc
  fi

  # Parse all needed fields once; fail loudly if slug or session_uuid is missing.
  local parsed
  parsed="$(python3 - "$obj" <<'PY'
import json, sys
a = json.loads(sys.argv[1])
if not a.get("slug") or not a.get("session_uuid"):
    sys.stderr.write("cre: registry entry missing slug or session_uuid\n"); sys.exit(1)
print(a["slug"]); print(a.get("sf_id", "")); print(a.get("display_name", "")); print(a["session_uuid"])
PY
)" || return 1

  local slug sf_id display uuid dir
  { IFS= read -r slug; IFS= read -r sf_id; IFS= read -r display; IFS= read -r uuid; } <<< "$parsed"
  dir="$CRE_ACCOUNTS_DIR/$slug"
  if [[ ! -d "$dir" ]]; then echo "cre: folder missing for '$slug' ($dir)"; return 1; fi

  local seed="You are assisting @elroseo (a GitHub CRE) on the account: ${display} (Salesforce id: ${sf_id}). \
Read @index.md for durable context, decisions, and action items. \
Treat any numbers under the 'Snapshot (generated)' markers as STALE — re-pull current product telemetry, activity summary, open opportunities, and renewal posture via the account360 / revenue-mcp skills before you summarize or advise. \
Only write to this account's files after confirming the account id, and never edit inside the generated snapshot markers by hand."

  echo "→ ${display}  [${slug}]  session ${uuid:0:8}…"
  copilot -C "$dir" --add-dir "$dir" --session-id "$uuid" -i "$seed"
}

cre-new() {
  local slug="$1" display="$2" sf_id="$3" aliases="${4:-}"
  if [[ -z "$slug" || -z "$display" || -z "$sf_id" ]]; then
    echo 'usage: cre-new <slug> "<Display Name>" <sf_id> [alias1,alias2]'; return 2
  fi
  # All validation, rendering, and the atomic registry write happen in one Python
  # step so a partial failure never leaves the registry and filesystem inconsistent.
  python3 - "$CRE_ACCOUNTS_DIR" "$slug" "$display" "$sf_id" "$aliases" <<'PY'
import json, os, re, sys, tempfile, uuid
root, slug, display, sf_id, aliases = sys.argv[1:6]

if slug in (".", "..") or not re.fullmatch(r"[A-Za-z0-9._-]+", slug):
    sys.exit(f"cre-new: invalid slug '{slug}' (allowed: letters, digits, . _ - ; not . or ..)")

reg  = os.path.join(root, "_registry.json")
tmpl = os.path.join(root, "_templates", "index.template.md")
adir = os.path.join(root, slug)

if os.path.exists(adir):
    sys.exit(f"cre-new: folder '{slug}' already exists")
try:
    data = json.load(open(reg))
except Exception as e:
    sys.exit(f"cre-new: cannot read registry: {e}")

alias_list = [a for a in aliases.split(",") if a]
existing = set()
for a in data.get("accounts", []):
    existing.add(a.get("slug", "").casefold())
    existing.update(x.casefold() for x in a.get("aliases", []))
for key in [slug] + alias_list:
    if key.casefold() in existing:
        sys.exit(f"cre-new: key '{key}' already registered")

try:
    tpl = open(tmpl).read()
except Exception as e:
    sys.exit(f"cre-new: cannot read template: {e}")

rendered = (tpl.replace("{{SLUG}}", slug)
               .replace("{{DISPLAY_NAME}}", display)
               .replace("{{SF_ID}}", sf_id)
               .replace("{{TIER}}", "")
               .replace("{{RENEWAL_DATE}}", ""))

ns = uuid.UUID(data["namespace_uuid"])
entry = {
    "slug": slug, "display_name": display, "sf_id": sf_id,
    "aliases": alias_list, "parent": None, "tier": "", "renewal_date": "",
    "session_uuid": str(uuid.uuid5(ns, slug)), "placeholder": False,
}

# 1) write the account files first; roll back the folder on any failure.
os.makedirs(adir)
try:
    with open(os.path.join(adir, "index.md"), "w") as f:
        f.write(rendered)
except Exception as e:
    try:
        os.remove(os.path.join(adir, "index.md"))
    except FileNotFoundError:
        pass
    os.rmdir(adir)
    sys.exit(f"cre-new: failed to write index.md: {e}")

# 2) update the registry atomically LAST; roll back the folder if it fails.
data["accounts"].append(entry)
try:
    fd, tmp = tempfile.mkstemp(dir=root, suffix=".json")
    with os.fdopen(fd, "w") as f:
        json.dump(data, f, indent=2); f.write("\n")
    os.replace(tmp, reg)
except Exception as e:
    try: os.remove(tmp)
    except Exception: pass
    os.remove(os.path.join(adir, "index.md")); os.rmdir(adir)
    sys.exit(f"cre-new: failed to update registry (folder rolled back): {e}")

print(f"OK {adir}/index.md")
PY
  local rc=$?
  [[ $rc -ne 0 ]] && return $rc
  echo "✓ created account '$slug'. Open it with:  cre $slug"
}

cre-ls() {
  python3 - "$(_cre_registry)" <<'PY'
import json, sys
try:
    data = json.load(open(sys.argv[1]))
except Exception as e:
    sys.stderr.write(f"cre-ls: cannot read registry: {e}\n"); sys.exit(3)
rows = [(a["slug"], a.get("display_name", ""), a.get("sf_id", ""),
         "placeholder" if a.get("placeholder") else "") for a in data.get("accounts", [])]
w = max((len(r[0]) for r in rows), default=4)
for slug, disp, sf, flag in rows:
    print(f"{slug:<{w}}  {disp}  ({sf}) {flag}".rstrip())
if not rows:
    print("(no accounts yet — add one with cre-new)")
PY
}
