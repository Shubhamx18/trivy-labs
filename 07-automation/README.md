# Automating Trivy Scans

Running scans manually is fine for learning and one-off checks.
In real DevSecOps setups, security scanning is automated — on a schedule, on every build, or before every deployment.

---

## Scripts in This Folder

| Script | What it does |
|--------|-------------|
| `scan.sh` | Prompts for an image name, runs a scan, saves a `.txt` report with timestamp |
| `scan-html.sh` | Same as above but saves an `.html` report instead |

All reports are saved inside the `reports/` folder with a timestamp in the filename so old scans are never overwritten.

---

## How to Use

```bash
# Give execute permission
chmod +x scan.sh scan-html.sh

# Run text report
./scan.sh

# Run HTML report
./scan-html.sh
```

When prompted, type the image name. Example: `nginx:latest`

---

## Output Structure

```
reports/
├── trivy-2026-03-01_09-30.txt
├── trivy-2026-03-01_09-45.html
```

> 📸 Add screenshot → script running and report being saved

---

## Real-World Usage

- **Cron job** → scan all images every night, save reports for review
- **CI/CD stage** → run `scan.sh` after every Docker build in the pipeline
- **Pre-deployment check** → block deployment if HIGH/CRITICAL found

---

## Notes

- Only **HIGH** and **CRITICAL** are included in the output — keeps reports focused and actionable.
- `mkdir -p reports` inside the scripts ensures the output folder is created automatically.
- Timestamp format `%Y-%m-%d_%H-%M` keeps reports sortable by date in any file browser.
