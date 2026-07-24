#!/usr/bin/env bash
# CRE account launcher — source this file from your shell rc:
#   source "/Users/elroseo/Work GitHub/Accounts/bin/cre.sh"
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

# Root of the Accounts area (override with CRE_ACCOUNTS_DIR).
: "${CRE_ACCOUNTS_DIR:=/Users/elroseo/Work GitHub/Accounts}"
export CRE_ACCOUNTS_DIR

_cre_registry() { printf '%s/_registry.json' "$CRE_ACCOUNTS_DIR"; }

# Resolve an alias/slug to a JSON object (or empty). Args: <alias>
_cre_resolve() {
  python3 - "$(_cre_registry)" "$1" <<'PY'
import json, sys
reg, needle = sys.argv[1], sys.argv[2].lower()
try:
    data = json.load(open(reg))
except Exception as e:
    print("", end=""); sys.exit(0)
for a in data.get("accounts", []):
    keys = [a.get("slug","").lower()] + [x.lower() for x in a.get("aliases",[])] + [a.get("display_name","").lower()]
    if needle in keys:
        print(json.dumps(a)); break
PY
}

cre() {
  local alias="$1"
  if [[ -z "$alias" ]]; then echo "usage: cre <alias>   (see: cre-ls)"; return 2; fi
  local obj; obj="$(_cre_resolve "$alias")"
  if [[ -z "$obj" ]]; then echo "cre: no account matching '$alias'. Try: cre-ls"; return 1; fi

  local slug sf_id display uuid dir
  slug="$(python3 -c 'import json,sys;print(json.loads(sys.argv[1])["slug"])' "$obj")"
  sf_id="$(python3 -c 'import json,sys;print(json.loads(sys.argv[1]).get("sf_id",""))' "$obj")"
  display="$(python3 -c 'import json,sys;print(json.loads(sys.argv[1]).get("display_name",""))' "$obj")"
  uuid="$(python3 -c 'import json,sys;print(json.loads(sys.argv[1])["session_uuid"])' "$obj")"
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
  local root="$CRE_ACCOUNTS_DIR" reg; reg="$(_cre_registry)"
  local tmpl="$root/_templates/index.template.md"
  local dir="$root/$slug"
  if [[ -d "$dir" ]]; then echo "cre-new: '$slug' already exists"; return 1; fi

  # Register (computes deterministic uuid5 from the namespace + slug).
  python3 - "$reg" "$slug" "$display" "$sf_id" "$aliases" <<'PY'
import json, sys, uuid
reg, slug, display, sf_id, aliases = sys.argv[1:6]
data = json.load(open(reg))
ns = uuid.UUID(data["namespace_uuid"])
if any(a["slug"] == slug for a in data["accounts"]):
    sys.exit("slug already registered")
data["accounts"].append({
    "slug": slug, "display_name": display, "sf_id": sf_id,
    "aliases": [a for a in aliases.split(",") if a],
    "parent": None, "tier": "", "renewal_date": "",
    "session_uuid": str(uuid.uuid5(ns, slug)), "placeholder": False,
})
json.dump(data, open(reg, "w"), indent=2); open(reg,"a").write("\n")
PY
  [[ $? -ne 0 ]] && return 1

  # Render the template.
  mkdir -p "$dir"
  sed -e "s|{{SLUG}}|$slug|g" -e "s|{{DISPLAY_NAME}}|$display|g" \
      -e "s|{{SF_ID}}|$sf_id|g" -e "s|{{TIER}}||g" -e "s|{{RENEWAL_DATE}}||g" \
      "$tmpl" > "$dir/index.md"
  echo "✓ created $dir/index.md and registered '$slug'. Open it with:  cre $slug"
}

cre-ls() {
  python3 - "$(_cre_registry)" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
rows = [(a["slug"], a.get("display_name",""), a.get("sf_id",""),
         "placeholder" if a.get("placeholder") else "") for a in data.get("accounts",[])]
w = max((len(r[0]) for r in rows), default=4)
for slug, disp, sf, flag in rows:
    print(f"{slug:<{w}}  {disp}  ({sf}) {flag}".rstrip())
if not rows: print("(no accounts yet — add one with cre-new)")
PY
}
