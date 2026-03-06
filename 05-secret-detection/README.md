# Trivy Secret Scanning

Trivy can detect hardcoded secrets inside your codebase — API keys, passwords, tokens, private keys.
This is critical because secrets committed to a repo are considered leaked, even in private repos.

---

## How Secret Scanning Works

Trivy scans the filesystem rather than a Docker image for this.
It uses pattern matching (known key formats) and entropy analysis (randomly generated strings).

---

## Run a Secret Scan

```bash
# Secrets only
trivy fs --scanners secret .

# Everything — vulnerabilities + secrets combined
trivy fs .
```

> 📸 Add screenshot → `trivy fs --scanners secret .` output detecting secrets

---

## What the Output Looks Like

```
.env (secrets)
═══════════════════════════════════════════════════════════
 CRITICAL  SecretType: AWS Access Key ID
 Line 3:   AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE

 HIGH      SecretType: Generic Password
 Line 5:   DB_PASSWORD=SuperSecretPassword123
```

Each finding shows:
- The file and line number where the secret is found
- The type of secret detected
- The severity level

---

## What Trivy Detects

| Secret Type | Example pattern |
|------------|----------------|
| AWS Access Key | `AKIA...` prefix |
| AWS Secret Key | 40-char alphanumeric string next to known key names |
| GitHub Token | `ghp_`, `github_pat_` prefix |
| Generic Password | Variables named `PASSWORD`, `PASS`, `SECRET`, `TOKEN` |
| Private RSA Key | `-----BEGIN RSA PRIVATE KEY-----` block |
| JWT Secret | High-entropy base64 strings |
| Stripe API Key | `sk_live_`, `sk_test_` prefix |

---

## Demo Files in This Folder

> ⚠️ All values below are **fake and safe** — created only for scanning practice.

| File | What it demonstrates |
|------|---------------------|
| `app.py` | AWS keys and DB URL hardcoded in Python code |
| `.env` | Multiple secret types in an env file |
| `config.yaml` | Credentials inside a YAML config |
| `Dockerfile` | Secrets set as ENV variables (bad practice) |

Run the scan from inside this folder:

```bash
cd Trivy-Secret-Scan
trivy fs --scanners secret .
```

> 📸 Add screenshot → Trivy output showing each file, line number, and secret type

---

## Best Practices

- Never hardcode secrets in source code
- Add `.env` to `.gitignore` — always
- Use a secrets manager in production:
  - **AWS** → Secrets Manager or Parameter Store
  - **Self-hosted** → HashiCorp Vault
  - **Azure** → Azure Key Vault
- If you accidentally push a secret — **rotate it immediately**, then remove it from git history

---

## Notes

- Trivy does NOT send your code or secrets anywhere — scanning is fully local.
- High-entropy strings (JWT secrets, random tokens) are caught via entropy analysis even if the variable name is not recognized.
- Both YAML and JSON config files are scanned the same way as code.
