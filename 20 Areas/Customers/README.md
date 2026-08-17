# Customers

Customer and account context belong in this folder. In this vault, "customer" is the single organizing term for assigned accounts, recurring customer work, and durable relationship context.

## Layout

```text
20 Areas/Customers/
  _registry.json            canonical managed-customer registry
  _templates/
    index.template.md       template for a managed customer's home note
  bin/
    cre.sh                  shell functions: cre, cre-new, cre-ls
  <slug>/
    index.md                durable context and generated account snapshot
  <Customer Name>/
    <Customer Name>.md      lightweight customer notes
```

Use a named customer folder with a matching Markdown note for occasional customer context. Use a `<slug>/index.md` workspace when the customer needs persistent Copilot sessions, generated snapshots, or structured account management.

## Managed customer setup

Add this to `~/.zshrc` or `~/.bashrc`:

```sh
source "/Users/elroseo/WOS-PARA/20 Areas/Customers/bin/cre.sh"
```

Then run `source ~/.zshrc` or open a new terminal.

## Commands

```sh
cre-ls                                   # list managed customers
cre globex                               # open the persistent customer session
cre-new globex "Globex Inc" 001ABC "glx" # create and register a customer workspace
```

`cre <alias>` opens Copilot in that customer's folder with a deterministic session identifier. The seed prompt identifies the customer and asks the agent to refresh live data rather than trusting stored snapshot values.

## Customer note contents

Capture only durable information that is useful for future work:

- Account identifiers and product footprint
- Key contacts and account-team relationships
- Current priorities and risks
- Decisions and action items
- Links to approved source systems

Avoid copying full transcripts or commercial reports into the vault. Treat generated snapshots as time-bound and include their source and refresh time.
