# Trivy Flags — Controlling Scan Behaviour

Knowing how to use Trivy flags is what separates a beginner from someone actually using it in production.
These three flags are the most important to understand first.

---

## 1. --severity

Filters the scan output to only show vulnerabilities at the specified severity level.
Without this, Trivy shows everything — which is noisy.

```bash
trivy image --severity HIGH,CRITICAL python:3.10-slim
```

> 📸 Add screenshot → `--severity HIGH,CRITICAL` output

**Severity levels:**

| Level | When to care |
|-------|-------------|
| CRITICAL | Fix immediately — active exploitation risk |
| HIGH | Fix soon — significant security risk |
| MEDIUM | Fix in next release cycle |
| LOW | Informational — fix when convenient |

---

## 2. --vuln-type

Controls whether Trivy scans OS-level packages, application libraries, or both.

```bash
# Only OS packages (installed via apt, apk, yum)
trivy image --vuln-type os python:3.10-slim

# Only app libraries (pip, npm, maven, etc.)
trivy image --vuln-type library python:3.10-slim
```

> 📸 Add screenshot → `--vuln-type library` output

**When to use which:**
- `os` → useful when you control the base image and want to see what OS-level patches are needed
- `library` → useful for developers checking their own application dependencies

---

## 3. --exit-code

By default Trivy exits with code `0` whether or not it finds vulnerabilities.
That means if you add it to a CI/CD pipeline without `--exit-code`, the pipeline will always pass.

```bash
trivy image --severity HIGH,CRITICAL --exit-code 1 python:3.10-slim
```

- Exit code `0` → no issues found at that severity → pipeline continues ✅
- Exit code `1` → vulnerabilities found → pipeline fails and blocks deployment ❌

> 📸 Add screenshot → pipeline failing because of exit-code 1

**This is how Trivy is actually used in real CI/CD pipelines.**
Never deploy without it when using Trivy as a security gate.

---

## Combining All Three

```bash
trivy image \
  --severity HIGH,CRITICAL \
  --vuln-type os \
  --exit-code 1 \
  python:3.10-slim
```

This is a production-ready scan command:
- Only shows what matters (HIGH/CRITICAL)
- Only checks OS packages
- Fails the pipeline if anything serious is found

> 📸 Add screenshot → combined flags output
