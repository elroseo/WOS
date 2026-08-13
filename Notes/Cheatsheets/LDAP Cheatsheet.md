---
tags:
  - ldap
  - authentication
  - ghes
  - troubleshooting
  - cheatsheet
  - runbook
audience: cre
updated: 2026-08-13
---

# LDAP Cheatsheet

## What this is and when to use it

LDAP (Lightweight Directory Access Protocol) is a protocol for accessing and managing directory services. A directory is a hierarchical database that stores information about users, groups, computers, and other resources in an organization. Microsoft's Active Directory is the most common LDAP-compatible directory.

Use this runbook when a customer configures GHES to authenticate against their corporate directory and reports sign-in failures, sync problems (users/team memberships not updating), or LDAPS certificate issues.

## How it's typically used

- Centralized user authentication (single sign-on)
- Looking up user information (email, group membership, department)
- Managing access control based on group membership
- Syncing user accounts between systems

## How it relates to GHES

GHES supports LDAP as an authentication method, allowing customers to sign in with their corporate credentials, and can sync users and teams from LDAP groups automatically. Common CRE scenarios: helping customers configure LDAP settings (base DN, search filters, attribute mapping), troubleshooting authentication failures, debugging LDAPS certificate issues, and resolving LDAP sync problems.

## Prerequisites

- Network reachability from your investigation host to the customer's LDAP server (or SSH access to the GHES appliance if testing from there).
- Bind credentials if an authenticated search is needed; anonymous search is not always permitted.
- For GHES-side auth-failure investigation: SSH access to the appliance and read access to `/var/log/github/auth.log`.

## Platform scope

- **Any LDAP/Active Directory environment**: the `ldapsearch`/`ldapadd`/`ldapmodify`/`ldapdelete` commands below are general LDAP tooling and apply to any directory, customer-managed or otherwise.
- **GHES appliance**: GHES connects to the customer's LDAP server as a client; it does not run its own LDAP directory. LDAP authentication settings are configured through the GHES Management Console (Site admin > Management Console > Authentication > LDAP), not by hand-editing files on the appliance. For CLI-based connection testing, GHES documents a dedicated `ghe-ldap-test` utility, but this file does not have verified flag syntax for it; check the current version's [GHES command-line utilities](https://docs.github.com/en/enterprise-server@latest/admin/administering-your-instance/administering-your-instance-from-the-command-line/command-line-utilities) reference before running it.

## Safety and read-only boundary

> [!warning] Default to ldapsearch
> `ldapsearch` (with or without a bind) is read-only. `ldapadd`, `ldapmodify`, and `ldapdelete` mutate the customer's directory: they can create, change, or remove real accounts and group memberships. Do not run these against a customer's production directory without explicit authorization; this is customer identity data, not a GHES-managed resource, so any write needs the customer's own directory administrators, not just Support/Engineering sign-off.

## Quick procedure (read-only triage)

1. Confirm the symptom: sign-in failure, stale group membership after sync, or an LDAPS certificate/handshake error.
2. Test basic connectivity: `telnet <host> 389` (or `636` for LDAPS) to rule out network/firewall issues before touching LDAP semantics.
3. Run an anonymous or authenticated search for the affected user to confirm the entry exists and has the expected attributes:
   - Anonymous: `ldapsearch -x -H ldap://ldap.example.com -b "dc=example,dc=com" "(uid=jdoe)"`
   - Authenticated: add `-D "cn=admin,dc=example,dc=com" -W`
4. For Active Directory, confirm the attribute mapping (`sAMAccountName`, `mail`/`userPrincipalName`, `memberOf`) matches what GHES expects; see the AD search example below.
5. For LDAPS, verify the certificate chain independently (see [[SSL TLS Cheatsheet]]) before assuming an LDAP configuration problem.
6. On the GHES side, check `/var/log/github/auth.log` for the exact rejection reason (bind failure, no such entry, size limit, timeout).
7. If GHES's own connection test is needed, use the documented `ghe-ldap-test` utility per the current version's docs (see Platform scope above); don't guess its flags.

## GUI steps

GHES: LDAP settings (server URL, encryption, bind DN, search base/filters, attribute mapping) are configured in the Management Console under **Site admin > Management Console > Authentication > LDAP**. The Management Console includes a test/verify step before saving; exact labels vary by version, so confirm against the current version's [Using LDAP](https://docs.github.com/en/enterprise-server@latest/admin/managing-iam/using-ldap-for-enterprise-iam/using-ldap) docs. Saving settings triggers a config-apply and brief service restart.

## Expected output / success criteria

- `ldapsearch` returns exactly one entry for a known user, with the attributes the customer's GHES config depends on populated (not blank).
- The bind (if authenticated) succeeds without an "Invalid credentials" error.
- For AD, `memberOf` includes the group(s) the customer expects to map to GHES teams.

## Validation / cross-check

- Cross-check a "user can't sign in" report against `/var/log/github/auth.log` on GHES; a successful `ldapsearch` from your workstation does not guarantee GHES's own bind/search succeeds with the same result (different network path, different bind identity, different filter).
- For sync problems, confirm the specific attribute or group membership in the directory itself via `ldapsearch` before assuming GHES's sync logic is at fault.
- For LDAPS certificate errors, validate the chain independently with `openssl` (see [[SSL TLS Cheatsheet]]) rather than relying only on the LDAP client's error message.

## Errors and recovery

| Issue | What to check |
|---|---|
| Can't connect | Check hostname, port, firewall. Try `telnet host 389` |
| Invalid credentials | Verify bind DN format and password |
| No results | Check base DN and search filter. Try broader filter like `(objectClass=*)` |
| Certificate error (LDAPS) | Check CA cert; see [[SSL TLS Cheatsheet]] for chain verification |
| Size limit exceeded | Add `-z` flag, or ask the directory admin to increase the server limit |

## Stop / escalate

Escalate when the fix requires a write to the customer's directory (new entry, attribute change, deletion), since that's the customer's identity data and outside normal CRE scope, when GHES-side LDAP config changes are needed and the customer needs guidance beyond what the docs cover, or when `/var/log/github/auth.log` shows an error you can't attribute to a known cause. See [[Investigation and Escalation Judgment]] for thresholds and the evidence to collect first.

---

## Concepts

| Term | What it means |
|---|---|
| **LDAP** | Lightweight Directory Access Protocol, used for directory services (user/group lookups) |
| **Directory** | A hierarchical database of entries (users, groups, computers, etc.) |
| **DN** (Distinguished Name) | The unique full path to an entry, e.g. `cn=Jane,ou=Users,dc=company,dc=com` |
| **RDN** (Relative Distinguished Name) | A single component of a DN, e.g. `cn=Jane` |
| **Base DN** | The starting point for searches, e.g. `dc=company,dc=com` |
| **cn** | Common Name (usually the display name) |
| **uid** | User ID (login name) |
| **ou** | Organizational Unit (like a folder) |
| **dc** | Domain Component (parts of the domain) |
| **objectClass** | Defines what attributes an entry can/must have |
| **Bind** | Authenticating to the LDAP server |

---

## Common ports

| Port | Protocol | Use |
|---|---|---|
| 389 | LDAP | Unencrypted (or STARTTLS) |
| 636 | LDAPS | Encrypted (SSL/TLS) |
| 3268 | Global Catalog | Active Directory cross-domain search |
| 3269 | Global Catalog (SSL) | Encrypted cross-domain search |

---

## Searching with `ldapsearch`

### Basic search

```bash
ldapsearch -x -H ldap://ldap.example.com -b "dc=example,dc=com" "(uid=jdoe)"
```

### Authenticated search

```bash
ldapsearch -x -H ldap://ldap.example.com \
  -D "cn=admin,dc=example,dc=com" \
  -W \
  -b "dc=example,dc=com" \
  "(uid=jdoe)"
```

(`-W` prompts for password, `-D` is the bind DN)

### Search over LDAPS

```bash
ldapsearch -x -H ldaps://ldap.example.com -b "dc=example,dc=com" "(uid=jdoe)"
```

---

## Common search filters

| Filter | Matches |
|---|---|
| `(uid=jdoe)` | User with login "jdoe" |
| `(cn=Jane Doe)` | Entry with common name "Jane Doe" |
| `(objectClass=person)` | All person entries |
| `(objectClass=group)` | All groups |
| `(memberOf=cn=admins,ou=Groups,dc=example,dc=com)` | Members of the admins group |
| `(&(objectClass=person)(department=Engineering))` | People in Engineering (AND) |
| `(\|(uid=jdoe)(uid=asmith))` | Either jdoe or asmith (OR) |
| `(!(disabled=true))` | Not disabled (NOT) |
| `(uid=j*)` | UIDs starting with "j" (wildcard) |

---

## Useful `ldapsearch` flags

| Flag | What it does |
|---|---|
| `-x` | Use simple authentication (not SASL) |
| `-H ldap://host` | Server URL |
| `-b "base dn"` | Search base |
| `-D "bind dn"` | Bind as this user |
| `-W` | Prompt for password |
| `-w password` | Provide password inline (avoid in scripts) |
| `-s sub` | Search scope: `base`, `one`, or `sub` (recursive) |
| `-LLL` | Clean output (no comments, no version) |
| `-z 10` | Limit to 10 results |

---

## Search scopes

| Scope | What it searches |
|---|---|
| `base` | Only the base DN entry itself |
| `one` | One level below base DN |
| `sub` | All levels below base DN (recursive, default) |

---

## Active Directory specifics

| Attribute | AD equivalent |
|---|---|
| `uid` | `sAMAccountName` |
| `cn` | `cn` (same) |
| `mail` | `mail` or `userPrincipalName` |
| `memberOf` | `memberOf` (group membership) |

### AD search example

```bash
ldapsearch -x -H ldap://dc.company.com \
  -D "company\\admin" \
  -W \
  -b "dc=company,dc=com" \
  "(sAMAccountName=jdoe)" cn mail memberOf
```

---

## Modifying entries

> [!danger] Customer impact: writes to a live directory
> `ldapadd`, `ldapmodify`, and `ldapdelete` create, change, or remove real entries in the customer's directory. This is the customer's own identity infrastructure, not something GHES manages. Do not run these against a customer's production directory; any legitimate write request should go through the customer's own directory administrators.

### Add an entry

```bash
ldapadd -x -H ldap://host -D "cn=admin,dc=example,dc=com" -W -f new-user.ldif
```

### Modify an entry

```bash
ldapmodify -x -H ldap://host -D "cn=admin,dc=example,dc=com" -W -f changes.ldif
```

### Delete an entry

```bash
ldapdelete -x -H ldap://host -D "cn=admin,dc=example,dc=com" -W "cn=jdoe,ou=Users,dc=example,dc=com"
```

---

## LDIF format examples

### New user

```ldif
dn: cn=Jane Doe,ou=Users,dc=example,dc=com
objectClass: inetOrgPerson
cn: Jane Doe
sn: Doe
uid: jdoe
mail: jdoe@example.com
userPassword: {SSHA}hashedpassword
```

### Modify attribute

```ldif
dn: cn=Jane Doe,ou=Users,dc=example,dc=com
changetype: modify
replace: mail
mail: jane.doe@example.com
```

---

## Related notes and docs

- [ldapsearch man page](https://linux.die.net/man/1/ldapsearch)
- [LDAP filter syntax (RFC 4515)](https://datatracker.ietf.org/doc/html/rfc4515)
- [Active Directory LDAP reference](https://learn.microsoft.com/en-us/windows/win32/ad/active-directory-domain-services)
- [Using LDAP for GHES](https://docs.github.com/en/enterprise-server@latest/admin/managing-iam/using-ldap-for-enterprise-iam/using-ldap)
- [[SSL TLS Cheatsheet]] · [[GHES Cheatsheet]]

## Freshness note

Restructured as a CRE runbook on 2026-08-13. `ldapsearch`/`ldapadd`/`ldapmodify`/`ldapdelete` syntax is standard OpenLDAP client tooling. `ghe-ldap-test` exact flags were not verified in this pass; confirm against the current GHES version's command-line utilities docs before using it.
