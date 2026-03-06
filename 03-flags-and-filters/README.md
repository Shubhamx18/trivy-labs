# 03 — Flags and Filters

> Environment: Ubuntu 22.04 LTS — AWS EC2 t2.micro

Knowing the basic `trivy image` command is just the start.
These flags are what make Trivy actually useful in real projects and CI/CD pipelines.

---

## Flag 1 — --severity

**What it does:** Filters output to only show vulnerabilities at the severity levels you specify.

**Why you need it:** By default Trivy shows everything — LOW, MEDIUM, HIGH, CRITICAL.
In a real scan this can be hundreds of rows. `--severity` cuts the noise down to what matters.

```bash
# Show only HIGH and CRITICAL
trivy image --severity HIGH,CRITICAL nginx

# Show only CRITICAL
trivy image --severity CRITICAL nginx

# Show MEDIUM, HIGH, and CRITICAL
trivy image --severity MEDIUM,HIGH,CRITICAL nginx
```


In most real teams:
- HIGH and CRITICAL must be fixed before deployment
- MEDIUM and LOW are tracked but do not block the pipeline

---

## Flag 2 — --exit-code

**What it does:** Controls what exit code Trivy returns after a scan.

**Why you need it:** By default Trivy exits with code `0` (success) whether or not vulnerabilities are found.
Without `--exit-code 1` your CI/CD pipeline will always pass — even if CRITICAL issues are found.

```bash
trivy image --severity HIGH,CRITICAL --exit-code 1 nginx
```

How exit codes work in Linux:

```
Exit code 0  →  No issues found at that severity  →  Pipeline passes ✅
Exit code 1  →  Vulnerabilities found              →  Pipeline fails  ❌
```

Test it manually on your terminal:

```bash
trivy image --severity HIGH,CRITICAL --exit-code 1 nginx
echo "Exit code was: $?"
```


**This is the single most important flag for CI/CD.**
Without `--exit-code 1`, Trivy is just a reporting tool.
With `--exit-code 1`, Trivy becomes a real security gate that blocks bad deployments.

---

## Flag 3 — --ignore-unfixed

**What it does:** Hides vulnerabilities that have no fix available yet.

**Why you need it:** Many CVEs have no upstream patch. You cannot do anything about them right now.
`--ignore-unfixed` filters those out so you only see actionable issues.

```bash
trivy image --ignore-unfixed nginx
```

Combined with severity filter:

```bash
trivy image --severity HIGH,CRITICAL --ignore-unfixed nginx
```

This gives you a clean, actionable list — only HIGH/CRITICAL issues that have a patch available.


---

## Flag 4 — --vuln-type

**What it does:** Controls whether Trivy scans OS packages, application libraries, or both.

```bash
# Only OS packages installed via apt, apk, yum
trivy image --vuln-type os python:3.10-slim

# Only application libraries — pip, npm, maven, go modules
trivy image --vuln-type library python:3.10-slim

# Both — this is the default when you do not specify
trivy image --vuln-type os,library python:3.10-slim
```

When to use which:
- `os` → when you want to check what OS patches are needed in the base image
- `library` → when developers want to check their own app dependencies
- Both → full audit, used for complete security reviews

---

## Flag 5 — JSON Output

**What it does:** Saves the scan result as a JSON file instead of printing to terminal.

```bash
trivy image -f json -o report.json nginx
```

| Part | What it does |
|------|-------------|
| `-f json` | Format the output as JSON |
| `-o report.json` | Save to this file instead of printing |

View it:

```bash
cat report.json | python3 -m json.tool | head -50
```

Useful when:
- Another tool or script needs to process the results
- You want to store scan history
- You are integrating with a security dashboard

---

## Flag 6 — --no-progress

**What it does:** Suppresses the progress bar output.

**Why you need it:** In CI/CD pipeline logs, the animated progress bar creates messy output.
`--no-progress` gives clean, readable logs.

```bash
trivy image --no-progress nginx
```

---

## The Most Important CI/CD Command

This is what most real DevOps pipelines use as their security gate:

```bash
trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 --no-progress your-image
```

| Flag | Why it is here |
|------|---------------|
| `--severity HIGH,CRITICAL` | Only care about serious issues |
| `--ignore-unfixed` | Skip issues with no available fix — avoids false failures |
| `--exit-code 1` | Fail the pipeline if serious issues are found |
| `--no-progress` | Clean logs in CI/CD output |

If vulnerabilities exist → pipeline fails → deployment is blocked.

---

## Pipeline Flow

```
Build Docker image
       ↓
Run Trivy scan
       ↓
Vulnerabilities found?
       ↓
YES → fail pipeline → developer fixes → rebuild
       ↓
NO  → pipeline continues → deploy
```

---

## Notes

- `--ignore-unfixed` with `--severity HIGH,CRITICAL` is the most practical combination for daily use
- `--exit-code` is useless without `--severity` — otherwise Trivy might fail on a LOW vulnerability
- All flags work with both `trivy image` and `trivy fs`
