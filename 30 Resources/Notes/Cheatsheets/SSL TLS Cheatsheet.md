---
tags:
  - ssl
  - tls
  - certificates
  - ghes
  - security
  - cheatsheet
  - runbook
audience: cre
updated: 2026-08-13
---

# SSL/TLS Cheatsheet

## What this is and when to use it

SSL (Secure Sockets Layer) and its successor TLS (Transport Layer Security) are protocols that encrypt data in transit between a client (like a browser) and a server. They use certificates to verify the server's identity. In practice, people still say "SSL" even though TLS is the current standard.

GHES requires a TLS certificate for its web interface and API. Use this runbook when a customer reports a certificate expiry, a chain/intermediate error, a handshake failure between GHES and an external service (LDAPS, webhook endpoints), or needs help understanding what's currently installed before requesting a change.

## How it's typically used

- Encrypting web traffic (HTTPS)
- Securing API connections
- Encrypting email, database, and other service connections
- Verifying server identity through certificate chains

## How it relates to GHES

GHES requires a TLS certificate for its web interface and API. Customers configure this through the Management Console or the documented `ghe-ssl-certificate-setup` command-line utility. Common CRE scenarios: helping customers understand or diagnose certificate chain issues (missing intermediates), debugging TLS handshake failures between GHES and external services, and verifying custom CA certificates.

## Prerequisites

- Network reachability to the host/port you're testing (`openssl s_client`, `curl`).
- For GHES-side installs: SSH or Management Console access, and the customer's PEM certificate/key files (this is the customer's action, not typically something you do on their behalf without authorization).

## Platform scope

- **Any TLS endpoint**: the `openssl`/`curl` inspection and verification commands below apply to any host, GHES or otherwise.
- **GHES appliance**: certificate installation happens through the Management Console (a real, supported GUI) or the `ghe-ssl-certificate-setup`/`ghe-ssl-ca-certificate-install` command-line utilities. This file does not have verified flag syntax for those utilities; check the current version-specific [GHES command-line utilities](https://docs.github.com/en/enterprise-server@latest/admin/administering-your-instance/administering-your-instance-from-the-command-line/command-line-utilities) reference before running them.

## Safety and read-only boundary

> [!warning] Default to inspection and verification
> `openssl s_client`, `openssl x509 ... -text/-dates/-subject/-issuer`, `openssl verify`, and `curl -vI` are all read-only checks against a live endpoint. Installing, replacing, or generating a certificate changes what the server presents to every client and is customer-impacting; do it only with explicit authorization and, on GHES, through the documented Management Console or `ghe-ssl-*` workflow, not by guessing at commands.

## Quick procedure (read-only triage)

1. Confirm the symptom: browser/Git client certificate warning, chain/intermediate error, handshake failure to an external service (e.g. LDAPS), or an expiry question.
2. Check the certificate the server currently presents:
   ```bash
   echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -dates -subject -issuer
   ```
3. If a chain issue is suspected, show the full chain: `openssl s_client -connect host:443 -showcerts`.
4. Verify the chain against a CA bundle if you have one: `openssl verify -CAfile ca.pem -untrusted intermediate.pem cert.pem`.
5. For an HTTP-level view of the handshake (useful for webhook/API endpoint failures): `curl -vI https://host`.
6. For GHES specifically, if HAProxy is in the path (it is, for GHES), remember TLS terminates at the HAProxy frontend; see [[HAProxy Cheatsheet]].
7. If a certificate change is actually needed, don't guess the CLI syntax; use the Management Console (see GUI steps below) or the current version's docs for `ghe-ssl-certificate-setup`.

## GUI steps

GHES Management Console has a real, supported GUI for installing a TLS certificate:

1. From an administrative account, go to **Site admin > Management Console**.
2. Under **Settings**, click **Privacy**, and select **TLS only (recommended)**.
3. Choose the TLS protocol versions to allow.
4. Under **Certificate**, upload the PEM-format certificate or certificate chain.
5. Under **Unencrypted key**, upload the RSA private key (no passphrase).
6. Click **Save settings**.

> [!warning] Customer impact
> Saving settings in the Management Console restarts system services, causing brief, customer-visible downtime. Confirm authorization and a maintenance window before doing this. See the current version's [Configuring TLS](https://docs.github.com/en/enterprise-server@latest/admin/configuring-settings/hardening-security-for-your-enterprise/configuring-tls) docs for exact, version-specific steps and prerequisites (unencrypted RSA key, full chain order, Subject Alternative Names for subdomain isolation).

## Expected output / success criteria

- `openssl x509 -noout -dates` shows a `notAfter` date in the future; an expired or soon-to-expire date explains a browser warning.
- `openssl s_client -showcerts` returns a chain ending in a certificate you recognize as the expected root/intermediate for the customer's CA.
- `openssl verify` returns `OK` for the leaf certificate against the supplied chain.
- `curl -vI` completes the TLS handshake and returns HTTP headers, not a handshake error.

## Validation / cross-check

- Cross-check an expiry-related symptom against the actual `notAfter` date from `openssl x509`, not just the customer's description of "it says expired."
- Cross-check a chain error by explicitly verifying with `openssl verify -CAfile ... -untrusted ...`; a missing intermediate is a common root cause `s_client -showcerts` will reveal.
- For GHES, confirm TLS terminates at HAProxy (see [[HAProxy Cheatsheet]]) before assuming the certificate itself, rather than the proxy config, is the issue.
- Before recommending a Management Console change, confirm the customer's GHES version's exact prerequisites (unencrypted key, SAN entries for subdomain isolation) against the current docs.

## Errors and recovery

| Issue | What to check |
|---|---|
| Browser/Git cert warning | `openssl x509 -in cert.pem -dates -noout` for expiry; chain completeness with `-showcerts` |
| "Unable to verify the first certificate" | Missing intermediate; check chain order (server, intermediates, root last/omitted) |
| LDAPS handshake failure | Verify the LDAP server's cert chain the same way; see [[LDAP Cheatsheet]] |
| `curl -k` "works" but `curl` doesn't | Confirms it's a trust/chain issue, not connectivity |
| Self-signed cert in production | Expected to fail validation; customer needs a CA-signed cert for production use |

## Stop / escalate

Escalate when a certificate install/replace is needed on a GHES appliance and requires a maintenance window or troubleshooting beyond the documented Management Console flow, when a customer's internal CA chain issue isn't resolved by adding the missing intermediate, or when the fix would require guessing at `ghe-ssl-*` CLI flags this file doesn't verify. See [[Investigation and Escalation Judgment]] for thresholds and the evidence to collect first.

---

## Mutating actions: customer-impact warning

> [!danger] Read before generating or installing anything below
> Generating a new key/CSR, and especially installing a certificate on GHES, changes what the server presents to every client and can cause downtime while services restart. Confirm authorization and a maintenance window first, and prefer the Management Console or verified `ghe-ssl-*` documentation over improvised commands on a GHES appliance.

---

## Concepts

| Term | What it means |
|---|---|
| **SSL/TLS** | Protocols that encrypt connections between client and server |
| **Certificate** | A file that proves a server's identity, signed by a CA |
| **CA** (Certificate Authority) | A trusted entity that issues and signs certificates |
| **CSR** (Certificate Signing Request) | A request you send to a CA to get a certificate |
| **Private key** | Secret key kept on the server, never shared |
| **Public key** | Included in the certificate, shared with clients |
| **Self-signed cert** | A certificate signed by itself, not a CA (for testing) |
| **Chain of trust** | Root CA > Intermediate CA > Server certificate |

---

## Checking certificates

| Command | What it does |
|---|---|
| `openssl s_client -connect host:443` | Connect and show certificate info |
| `openssl s_client -connect host:443 -servername host` | Connect with SNI (needed for shared hosting) |
| `openssl x509 -in cert.pem -text -noout` | View certificate details |
| `openssl x509 -in cert.pem -dates -noout` | Check expiration dates only |
| `openssl x509 -in cert.pem -subject -noout` | View the subject (CN, org, etc.) |
| `openssl x509 -in cert.pem -issuer -noout` | View who issued the certificate |

---

## Quick certificate check (one-liner)

```bash
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -dates -subject -issuer
```

---

## Generating certificates

### Self-signed (for testing)

```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
```

### Generate a CSR (for production)

```bash
# Generate key + CSR
openssl req -newkey rsa:4096 -keyout key.pem -out request.csr -nodes

# Generate CSR from existing key
openssl req -new -key key.pem -out request.csr
```

### View a CSR

```bash
openssl req -in request.csr -text -noout
```

---

## Verifying certificates

| Command | What it does |
|---|---|
| `openssl verify cert.pem` | Verify against system CA store |
| `openssl verify -CAfile ca.pem cert.pem` | Verify against a specific CA |
| `openssl verify -CAfile ca.pem -untrusted intermediate.pem cert.pem` | Verify full chain |

---

## Converting formats

| From | To | Command |
|---|---|---|
| PEM to DER | Binary format | `openssl x509 -in cert.pem -outform DER -out cert.der` |
| DER to PEM | Text format | `openssl x509 -in cert.der -inform DER -out cert.pem` |
| PEM to PKCS12 | Bundled key+cert | `openssl pkcs12 -export -out cert.p12 -inkey key.pem -in cert.pem` |
| PKCS12 to PEM | Extract from bundle | `openssl pkcs12 -in cert.p12 -out cert.pem -nodes` |

---

## Debugging TLS connections

| Command | What it does |
|---|---|
| `curl -vI https://host` | Show TLS handshake details |
| `curl --cacert ca.pem https://host` | Test with a custom CA |
| `curl -k https://host` | Skip certificate verification (testing only) |
| `openssl s_client -connect host:443 -showcerts` | Show full certificate chain |

---

## Common certificate file extensions

| Extension | Format | Contains |
|---|---|---|
| `.pem` | Base64 text | Cert, key, or chain |
| `.crt` / `.cer` | Usually PEM | Certificate only |
| `.key` | PEM | Private key only |
| `.der` | Binary | Certificate only |
| `.p12` / `.pfx` | Binary | Key + cert bundle |
| `.csr` | PEM | Certificate signing request |

---

## Certificate chain order

When configuring a server, the chain file should be ordered:

```
1. Server certificate
2. Intermediate certificate(s)
3. (Root CA is usually not included, clients have it already)
```

---

## Related notes and docs

- [SSL Labs server test](https://www.ssllabs.com/ssltest/)
- [OpenSSL docs](https://www.openssl.org/docs/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Configuring TLS (GHES)](https://docs.github.com/en/enterprise-server@latest/admin/configuring-settings/hardening-security-for-your-enterprise/configuring-tls)
- [GHES command-line utilities](https://docs.github.com/en/enterprise-server@latest/admin/administering-your-instance/administering-your-instance-from-the-command-line/command-line-utilities)
- [[HAProxy Cheatsheet]] · [[LDAP Cheatsheet]] · [[GHES Cheatsheet]]

## Freshness note

Restructured as a CRE runbook on 2026-08-13. `openssl`/`curl` syntax is standard and stable across versions. GHES Management Console steps were verified against the current docs at that time; confirm against the customer's specific GHES version before relying on exact menu labels, since these can shift between releases.
