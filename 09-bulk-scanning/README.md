# Bulk Image Scanning with Trivy

Instead of scanning images one by one, this script reads a list from `images.txt` and generates a separate HTML report for each image automatically.

---

## When Is This Useful?

- Auditing every Docker image used across a team or project
- Comparing security posture across multiple base images
- Running a scheduled weekly report across all your services

---

## Files in This Folder

| File | Purpose |
|------|---------|
| `scan-all.sh` | Main script — reads image list, runs scans, saves HTML reports |
| `images.txt` | One image per line — edit this with your target images |
| `reports/` | Auto-created — all HTML reports saved here |

> `html.tpl` is downloaded automatically by the script if not present.

---

## How to Use

**Step 1 — Edit `images.txt`** with the images you want to scan:

```
nginx:mainline
redis:alpine
postgres:15-alpine
python:3.11-slim
node:lts-alpine
```

**Step 2 — Give the script execute permission:**

```bash
chmod +x scan-all.sh
```

**Step 3 — Run it:**

```bash
./scan-all.sh
```

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

> 📸 Add screenshot → terminal showing each image being scanned
> 📸 Add screenshot → reports folder with all HTML files

---

## Notes

- Image names are sanitized for filenames — `:` and `/` are replaced with `_`
- `set -euo pipefail` means the script stops immediately if anything fails
- `html.tpl` is downloaded once and reused for all scans
- Only **HIGH** and **CRITICAL** are included in reports to keep them focused
