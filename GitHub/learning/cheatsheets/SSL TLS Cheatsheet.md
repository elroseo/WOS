# SSL/TLS Cheatsheet

## What is SSL/TLS?

SSL (Secure Sockets Layer) and its successor TLS (Transport Layer Security) are protocols that encrypt data in transit between a client (like a browser) and a server. They use certificates to verify the server's identity so clients know they're connecting to the right place and not an imposter. In practice, people still say "SSL" even though TLS is the current standard.

## How it's typically used

- Encrypting web traffic (HTTPS)
- Securing API connections
- Encrypting email, database, and other service connections
- Verifying server identity through certificate chains

## How it relates to GHES

GHES requires a TLS certificate for its web interface and API. Customers configure this through the management console or via `ghe-ssl-certificate-setup`. Common CRE scenarios include helping customers install or renew certificates, troubleshooting certificate chain issues (missing intermediates), debugging TLS handshake failures between GHES and external services (like LDAP over LDAPS or webhook endpoints), and verifying custom CA certificates are properly installed with `ghe-ssl-ca-certificate-install`.

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

## Quick reference links

- [SSL Labs server test](https://www.ssllabs.com/ssltest/)
- [OpenSSL docs](https://www.openssl.org/docs/)
- [Let's Encrypt](https://letsencrypt.org/)
