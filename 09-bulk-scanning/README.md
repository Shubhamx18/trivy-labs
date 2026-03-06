# 09 — Bulk Scanning

> Environment: Ubuntu 22.04 LTS — AWS EC2 t2.micro

Instead of scanning images one by one, this script reads a list from `images.txt`
and generates a separate HTML report for each image automatically.

---

## When Is This Useful?

- Auditing all Docker images used across a team or project at once
- Comparing security posture across multiple base images before choosing one
- Running a scheduled weekly security report across all your services
- Scanning all images before a production release

---

## Files in This Folder

| File | Purpose |
|------|---------|
| `scan-all.sh` | Main script — reads image list, scans each one, saves HTML reports |
| `images.txt` | One image name per line — edit this with your target images |
| `reports/` | Auto-created folder — all HTML reports saved here |

> `html.tpl` is downloaded automatically by the script on first run if not already present.

---

## How to Use

### Step 1 — Edit images.txt

Open the file and add the images you want to scan, one per line:

```bash
nano images.txt
```

Example content:

```
nginx:mainline
redis:alpine
postgres:15-alpine
python:3.11-slim
node:lts-alpine
```

Save and exit: `Ctrl+X` then `Y` then `Enter`

---

### Step 2 — Give the script execute permission

```bash
chmod +x scan-all.sh
```

| Part | What it does |
|------|-------------|
| `chmod` | Change file permissions |
| `+x` | Add execute permission |
| `scan-all.sh` | The file to make executable |

---

### Step 3 — Run the script

```bash
./scan-all.sh
```

The script will:
1. Download `html.tpl` if not already present
2. Loop through every image in `images.txt`
3. Scan each image with Trivy
4. Save an HTML report for each one inside `reports/`


---

## Output

Each image gets its own HTML report inside `reports/`:

```
reports/
├── nginx_mainline.html
├── redis_alpine.html
├── postgres_15-alpine.html
├── python_3.11-slim.html
└── node_lts-alpine.html
```


---

## Understanding the Script

```bash
#!/bin/bash
set -euo pipefail
```

| Part | What it does |
|------|-------------|
| `#!/bin/bash` | Tells Linux to run this file using bash |
| `set -e` | Stop immediately if any command fails |
| `set -u` | Treat unset variables as errors |
| `set -o pipefail` | Catch errors inside piped commands |

```bash
command -v trivy >/dev/null 2>&1 || { echo "Error: trivy not installed."; exit 1; }
```

Checks that Trivy is installed before starting. If not found, exits with an error message.

```bash
filename=$(echo "$image" | sed 's/[:/]/_/g')
```

Converts image name to a safe filename by replacing `:` and `/` with `_`.
Example: `python:3.11-slim` becomes `python_3.11-slim.html`

---

## Real-World Usage

- **Nightly cron job** — scan all images at 2am, save reports for morning review

  ```bash
  # Add to crontab with: crontab -e
  0 2 * * * /home/ubuntu/trivy-labs/09-bulk-scanning/scan-all.sh
  ```

- **Pre-release audit** — scan every image in the stack before a production deployment
- **Weekly security review** — compare this week's reports to last week's to track progress

---

## Notes

- Only **HIGH** and **CRITICAL** are included in reports to keep them focused
- `html.tpl` is downloaded once and reused for every scan in the loop
- If an image scan fails, `set -euo pipefail` stops the script rather than silently continuing
- You can add as many images as you want to `images.txt` — the script handles all of them
