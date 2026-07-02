# LDAP Cheatsheet

## What is LDAP?

LDAP (Lightweight Directory Access Protocol) is a protocol for accessing and managing directory services. A directory is a hierarchical database that stores information about users, groups, computers, and other resources in an organization. Think of it like a company's address book that applications can query to look up who someone is, what groups they belong to, and whether their password is correct. Microsoft's Active Directory is the most common LDAP-compatible directory.

## How it's typically used

- Centralized user authentication (single sign-on)
- Looking up user information (email, group membership, department)
- Managing access control based on group membership
- Syncing user accounts between systems

## How it relates to GHES

GHES supports LDAP as an authentication method, allowing customers to sign into GitHub with their corporate credentials. GHES can sync users and teams from LDAP groups automatically. Common CRE scenarios include helping customers configure LDAP settings (base DN, search filters, attribute mapping), troubleshooting authentication failures using `ghe-ldap-test` and `/var/log/github/auth.log`, debugging LDAPS certificate issues, and resolving LDAP sync problems where users or team memberships aren't updating correctly.

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

## Troubleshooting

| Issue | What to check |
|---|---|
| Can't connect | Check hostname, port, firewall. Try `telnet host 389` |
| Invalid credentials | Verify bind DN format and password |
| No results | Check base DN and search filter. Try broader filter like `(objectClass=*)` |
| Certificate error (LDAPS) | Check CA cert. Use `LDAPTLS_REQCERT=never` to skip (testing only) |
| Size limit exceeded | Add `-z` flag or ask admin to increase server limit |

---

## Quick reference links

- [ldapsearch man page](https://linux.die.net/man/1/ldapsearch)
- [LDAP filter syntax (RFC 4515)](https://datatracker.ietf.org/doc/html/rfc4515)
- [Active Directory LDAP reference](https://learn.microsoft.com/en-us/windows/win32/ad/active-directory-domain-services)
