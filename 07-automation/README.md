# 07 — Automation

> Environment: Ubuntu 22.04 LTS — AWS EC2 t2.micro

Running scans manually works for learning and one-off checks.
In real DevSecOps setups, security scanning is automated — triggered on every build, before every deployment, or on a nightly schedule.

---

## Scripts in This Folder

| Script | What it does |
|--------|-------------|
| `scan.sh` | Prompts for image name, runs scan, saves timestamped `.txt` report |
| `scan-html.sh` | Same but saves an `.html` report |
| `trivy-security-workflow.sh` | Full end-to-end DevSecOps workflow — build, scan, fix, rebuild, push |

---

## Script 1 — scan.sh (Text Report)

### How to use

```bash
# Give execute permission
chmod +x scan.sh

# Run it
./scan.sh
```

When prompted enter the image name, for example: `nginx:latest`

Report is saved to `reports/trivy-2026-03-01_09-30.txt`

---

## Script 2 — scan-html.sh (HTML Report)

### How to use

```bash
chmod +x scan-html.sh
./scan-html.sh
```

Enter image name when prompted.

Report is saved to `reports/trivy-2026-03-01_09-30.html`


---

## Script 3 — trivy-security-workflow.sh (Full DevSecOps Pipeline)

This is the most important script. It demonstrates the **complete security workflow** from start to finish:

```
Build Docker image
       ↓
List images
       ↓
Scan with Trivy (all vulnerabilities)
       ↓
Scan only HIGH and CRITICAL
       ↓
CI/CD scan (fail if vulnerabilities found)
       ↓
Create patch Dockerfile to fix vulnerable dependency
       ↓
Build patched image
       ↓
Verify new image
       ↓
Scan patched image
       ↓
Login to DockerHub
       ↓
Push secure image
       ↓
Final scan ignoring unfixed
```

### How to create and run it

**Step 1 — Create the script file**

```bash
nano trivy-security-workflow.sh
```

**Step 2 — Paste this content:**

```bash
#!/bin/bash

echo "===== STEP 1: Build Initial Docker Image ====="
docker build -t shubhamm18/webapp:02 .

echo "===== STEP 2: List Docker Images ====="
docker images

echo "===== STEP 3: Scan Image with Trivy ====="
trivy image shubhamm18/webapp:02

echo "===== STEP 4: Scan Only HIGH and CRITICAL ====="
trivy image --severity HIGH,CRITICAL shubhamm18/webapp:02

echo "===== STEP 5: Scan for CI/CD (Fail if Vulnerabilities Found) ====="
trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 --no-progress shubhamm18/webapp:02

echo "===== STEP 6: Create Patch Dockerfile to Fix Dependency ====="

cat <<EOF > Dockerfile.patch
FROM shubhamm18/webapp:02

WORKDIR /app

# Fix vulnerable dependency
RUN npm install cross-spawn@7.0.5

CMD ["npm", "start"]
