# 05 — Secret Detection

> Environment: Ubuntu 22.04 LTS — AWS EC2 t2.micro

Trivy can scan your entire codebase and find hardcoded secrets — API keys, passwords, tokens, private keys.
This is one of the most practically important features for any developer or DevOps engineer.

---

## Why This Matters

Secrets committed to a git repository are considered **leaked** — even in private repos.
Once a secret is in git history it is very hard to fully remove.
Attackers constantly scan GitHub and GitLab for exposed credentials using automated bots.

Common real-world incidents caused by leaked secrets:
- AWS keys committed in `.env` file → unauthorized cloud usage, massive billing charges
- GitHub tokens left in code → repo access, CI/CD pipeline abuse
- Database passwords in config files → data breach

---

## How Secret Scanning Works

Trivy uses two techniques to find secrets:
1. **Pattern matching** — recognizes known formats like `AKIA` for AWS keys, `ghp_` for GitHub tokens
2. **Entropy analysis** — detects randomly generated strings like JWT secrets even without a known pattern

---

## How to Run a Secret Scan

```bash
# Scan only for secrets in current directory
trivy fs --scanners secret .
```

| Part | What it does |
|------|-------------|
| `trivy fs` | Filesystem scan mode — scans files on disk, not a Docker image |
| `--scanners secret` | Only run the secret detection scanner |
| `.` | Scan current directory and all subdirectories |

```bash
# Scan for both vulnerabilities AND secrets at the same time
trivy fs .
```


---

## What the Output Looks Like

```
.env (secrets)
══════════════════════════════════════════════
 CRITICAL  SecretType: AWS Access Key ID
           RuleID:     aws-access-key-id
           Line:       3
           Match:      AWS_ACCESS_KEY_ID=**********

 HIGH      SecretType: Generic Password
           RuleID:     generic-password
           Line:       5
           Match:      DB_PASSWORD=**********
```

Each finding tells you:
- **File path** — exactly which file has the secret
- **Line number** — the exact line to go fix
- **Secret type** — what kind of secret was detected
- **Severity** — how serious the exposure is

> Trivy masks the actual secret value with `**` in output for safety.

---

## What Trivy Detects

| Secret Type | How Trivy Finds It |
|------------|-------------------|
| AWS Access Key | Recognizes the `AKIA` prefix |
| AWS Secret Key | 40-char string near known key variable names |
| GitHub Token | Recognizes `ghp_` and `github_pat_` prefixes |
| Generic Password | Variable names like `PASSWORD`, `PASS`, `SECRET`, `TOKEN` |
| Private RSA Key | `-----BEGIN RSA PRIVATE KEY-----` block |
| JWT Secret | High-entropy base64 strings |
| Stripe API Key | `sk_live_` and `sk_test_` prefixes |
| Slack Token | `xoxb-` and `xoxp-` prefixes |

---

## Demo Files in This Folder

> ⚠️ All values in these files are **completely fake and safe**.
> They exist only so you can practice running Trivy secret scans.

| File | What it demonstrates |
|------|---------------------|
| `app.py` | AWS keys and database URL hardcoded in Python code |
| `.env` | Multiple secret types in an environment variables file |
| `config.yaml` | Credentials inside a YAML config file |
| `Dockerfile` | Secrets set as ENV variables — a very common bad practice |

### Run the demo scan

Navigate into this folder and scan it:

```bash
cd 05-secret-detection
trivy fs --scanners secret .
```

Trivy will flag each file with the exact line number and type of secret found.


---

## Scanning Your Own Project

```bash
# Go to your project folder
cd /path/to/your/project

# Scan for secrets
trivy fs --scanners secret .
```

Scan a specific file only:

```bash
trivy fs --scanners secret ./config/database.yaml
```

---

## Best Practices

**Never hardcode secrets in source code. Use these instead:**

| Environment | What to use |
|-------------|------------|
| Local development | `.env` file — add it to `.gitignore` |
| Ubuntu server / EC2 | Environment variables set in the shell |
| Production on AWS | AWS Secrets Manager or Parameter Store |
| Self-hosted | HashiCorp Vault |

**If you accidentally commit a secret:**
1. Rotate the secret immediately — assume it is already compromised
2. Revoke the old key or token in whatever service issued it
3. Remove it from the current code
4. Remove it from git history using `git filter-branch` or BFG Repo Cleaner
5. Force push the cleaned history

---

## Notes

- Trivy does **not** send your files or secrets anywhere — all scanning is fully local
- High-entropy random strings like JWT secrets are caught via entropy analysis even if the variable name is not recognized
- YAML, JSON, and plain text config files are scanned the same way as code files
- The `.env` file is one of the most common sources of accidentally committed secrets — always check your `.gitignore`
