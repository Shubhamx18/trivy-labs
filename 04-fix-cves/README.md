# Fixing Vulnerabilities Found by Trivy

Finding CVEs is step one. Actually fixing them is step two.
This section walks through the real process of scanning, identifying, fixing, and re-scanning.

---

## The Fix Workflow

```
Build image
    ↓
Scan with Trivy
    ↓
Identify fixable CVEs (where Fixed Version exists)
    ↓
Update Dockerfile
    ↓
Rebuild image
    ↓
Re-scan to confirm fix
```

---

## Lab 1 — Fix a Local Image

### Step 1 — Build the vulnerable image

```bash
docker build -f Dockerfileissue -t myapp:vulnerable .
```

### Step 2 — Scan it

```bash
trivy image myapp:vulnerable
```

> 📸 Add screenshot → scan output showing vulnerabilities

### Step 3 — Look at what changed between Dockerfiles

**Dockerfileissue** (vulnerable):
```dockerfile
FROM python:3.10-slim
RUN pip install flask
COPY app.py .
CMD ["python", "app.py"]
```

**Dockerfile** (fixed):
```dockerfile
FROM python:3.10-slim
RUN pip install --upgrade pip
RUN pip install flask
COPY app.py .
CMD ["python", "app.py"]
```

The difference: `pip install --upgrade pip` before installing flask upgrades pip itself,
which removes several known vulnerabilities in older pip versions.

### Step 4 — Build and re-scan the fixed image

```bash
docker build -f Dockerfile -t myapp:secure .
trivy image myapp:secure
```

> 📸 Add screenshot → re-scan showing fewer or zero HIGH/CRITICAL issues

---

## Lab 2 — Fix a DockerHub Image

```bash
# Scan your own DockerHub image
trivy image shubhamm18/YOUR_IMAGE_NAME:latest
```

> 📸 Add screenshot → initial DockerHub image scan (before fix)

Create a new Dockerfile to patch the vulnerable packages:

```dockerfile
FROM shubhamm18/YOUR_IMAGE_NAME:latest

# Upgrade packages that have known CVEs
RUN apk update && apk upgrade --no-cache
```

Build the fixed image and push it:

```bash
docker build -t shubhamm18/YOUR_IMAGE_NAME:fixed .
docker push shubhamm18/YOUR_IMAGE_NAME:fixed

# Re-scan to confirm improvement
trivy image shubhamm18/YOUR_IMAGE_NAME:fixed
```

> 📸 Add screenshot → scan after fix, showing vulnerability count before vs after

---

## Before vs After — Example

| Severity | Before Fix | After Fix |
|----------|-----------|-----------|
| CRITICAL | 0 | 0 |
| HIGH | 2 | 0 ✅ |
| MEDIUM | 5 | 3 |
| LOW | 3 | 3 |

---

## Common Fix Strategies

| Root cause | Fix |
|------------|-----|
| Outdated OS packages | `RUN apk upgrade` or `apt-get upgrade` in Dockerfile |
| Old pip packages | `RUN pip install --upgrade pip` or pin to fixed versions |
| Outdated base image | Switch to a newer tag e.g. `python:3.11-slim` |
| No upstream fix exists | Accept risk or switch to a different base image |

---

## Notes

- Always re-scan after fixing. Upgrading one package can sometimes pull in another CVE.
- `apk upgrade` fixes most Alpine CVEs in one command.
- Do not use `latest` tags in production. Pin to a specific version so scans are reproducible.
