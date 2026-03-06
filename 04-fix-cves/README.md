# 04 — Fix CVEs

> Environment: Ubuntu 22.04 LTS — AWS EC2 t2.micro

Finding CVEs is step one. Actually fixing them is what matters.
This section walks through the complete process — scan, identify, fix, rebuild, re-scan, confirm, push.

---

## The Fix Workflow

```
Build image
       ↓
Scan with Trivy
       ↓
Read the report — find CVEs where Fixed Version exists
       ↓
Update Dockerfile or dependencies
       ↓
Rebuild the image
       ↓
Re-scan to confirm fix worked
       ↓
Push the fixed image to DockerHub
```

---

## Understanding What to Fix

When you scan an image you will see rows like this:

```
Library: minimatch     Installed: 9.0.5    Fixed: 10.2.1
Library: cross-spawn   Installed: 7.0.3    Fixed: 7.0.5
```

This tells you exactly what to do:
- Update `minimatch` to `10.2.1`
- Update `cross-spawn` to `7.0.5`
- Rebuild the image
- Scan again

If **Fixed Version is empty** → no patch exists yet. You cannot fix it by upgrading.
Focus only on the ones that have a fixed version.

---

## Lab 1 — Fix a Local Docker Image

This lab uses two Dockerfiles in this folder:
- `Dockerfileissue` — intentionally vulnerable
- `Dockerfile` — the fixed version

### Step 1 — Build the vulnerable image

```bash
docker build -f Dockerfileissue -t myapp:vulnerable .
```

| Part | What it does |
|------|-------------|
| `docker build` | Builds a Docker image |
| `-f Dockerfileissue` | Use this specific file instead of default Dockerfile |
| `-t myapp:vulnerable` | Name and tag the image |
| `.` | Use current directory as build context |

### Step 2 — Scan it

```bash
trivy image myapp:vulnerable
```


### Step 3 — Understand what the fix does

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

The fix: `RUN pip install --upgrade pip` upgrades pip before installing anything else.
Older pip versions have known CVEs. Upgrading removes them from the image.

### Step 4 — Build the fixed image

```bash
docker build -f Dockerfile -t myapp:secure .
```

### Step 5 — Re-scan and compare

```bash
trivy image myapp:secure
```


---

## Lab 2 — Fix Your DockerHub Image

### Step 1 — Scan your image

```bash
trivy image shubhamm18/YOUR_IMAGE_NAME:latest
```


### Step 2 — Create a patch Dockerfile

```bash
nano Dockerfile.patch
```

Add this content (edit package names based on your scan results):

```dockerfile
FROM shubhamm18/YOUR_IMAGE_NAME:latest

WORKDIR /app

# Fix the vulnerable dependency found by Trivy
RUN npm install cross-spawn@7.0.5

CMD ["npm", "start"]
```

### Step 3 — Build the patched image

```bash
docker build -t shubhamm18/YOUR_IMAGE_NAME:fixed -f Dockerfile.patch .
```

### Step 4 — Verify the new image was created

```bash
docker images
```

### Step 5 — Re-scan the patched image

```bash
trivy image --severity HIGH,CRITICAL shubhamm18/YOUR_IMAGE_NAME:fixed
```


### Step 6 — Final scan ignoring unfixed

```bash
trivy image --ignore-unfixed --severity HIGH,CRITICAL shubhamm18/YOUR_IMAGE_NAME:fixed
```

### Step 7 — Login and push to DockerHub

```bash
docker login
docker push shubhamm18/YOUR_IMAGE_NAME:fixed
```

---

## Before vs After — Example

| Severity | Before Fix | After Fix |
|----------|-----------|-----------|
| CRITICAL | 0 | 0 |
| HIGH | 2 | 0 ✅ |
| MEDIUM | 5 | 3 |
| LOW | 3 | 3 |

---

## Common Fix Methods

**Method 1 — Update Node dependencies**
```bash
npm update
```

**Method 2 — Update Python dependencies**
```bash
pip install --upgrade package-name
```

**Method 3 — Update Ubuntu/Debian OS packages**
```bash
apt-get update && apt-get upgrade -y
```

**Method 4 — Update Alpine OS packages**
```bash
apk update && apk upgrade
```

**Method 5 — Update base image tag in Dockerfile**
```dockerfile
# Before
FROM node:20-alpine

# After — use newer version
FROM node:22-alpine
```

**Method 6 — Patch a specific layer**
```dockerfile
FROM existing-image
RUN apt-get update && apt-get upgrade -y
```

---

## Real DevSecOps Workflow

This is the full end-to-end workflow you practice in production:

```
Developer pushes code
       ↓
CI builds container image
       ↓
Trivy scans image
       ↓
Vulnerabilities found → fail build
       ↓
Developer fixes dependencies
       ↓
Rebuild image
       ↓
Re-scan — clean result
       ↓
Deploy
```

---

## Notes

- Always re-scan after fixing. Upgrading one package can sometimes pull in a different CVE.
- `apk upgrade` on Alpine fixes most OS-level CVEs in one command.
- Never use `latest` tag in production Dockerfiles. Always pin to a specific version like `python:3.11.9-slim` so your scans are reproducible.
- If Fixed Version is empty in Trivy output — no upstream patch exists. Accept the risk or switch to a different base image.
