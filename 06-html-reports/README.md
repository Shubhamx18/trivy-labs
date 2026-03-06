# Generating Vulnerability Reports with Trivy

Terminal output is useful for quick checks.
But when you need to share findings with a team, raise a ticket, or store it as a CI/CD artifact — you need a proper report.

---

## Supported Report Formats

| Format | Use case |
|--------|---------|
| `table` | Default terminal output |
| `json` | Machine-readable, for integrations |
| `template` | Custom output — used for HTML reports |
| `cyclonedx` | SBOM (Software Bill of Materials) |
| `spdx` | Another SBOM standard |

---

## Generate an HTML Report

### Step 1 — Download the HTML template

```bash
curl -o html.tpl https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl
```

This template (maintained by Aqua Security) converts raw scan data into a clean HTML page.
Download it once and reuse it.

---

### Step 2 — Run the scan and save as HTML

```bash
trivy image \
  --format template \
  --template "@html.tpl" \
  -o trivy-report.html \
  python:3.10-slim
```

**Flag breakdown:**

| Flag | Purpose |
|------|---------|
| `--format template` | Use a template for output instead of table |
| `--template "@html.tpl"` | The `@` means read from file — points to your downloaded template |
| `-o trivy-report.html` | Output file name |

> 📸 Add screenshot → command running in terminal

---

### Step 3 — Open the report

```bash
# Linux
xdg-open trivy-report.html

# macOS
open trivy-report.html
```

> 📸 Add screenshot → HTML report open in browser showing CVE table

---

## HIGH and CRITICAL Only Report

Reduces noise by excluding LOW and MEDIUM:

```bash
trivy image \
  --severity HIGH,CRITICAL \
  --format template \
  --template "@html.tpl" \
  -o trivy-report-critical.html \
  python:3.10-slim
```

This is the version you would share with a security or compliance team.

---

## JSON Report

Useful when another tool needs to consume the scan results:

```bash
trivy image --format json -o trivy-report.json python:3.10-slim
```

---

## SBOM — Software Bill of Materials

An SBOM lists every single package inside the image.
Required by many compliance frameworks and enterprise security teams.

```bash
trivy image --format cyclonedx -o sbom.json python:3.10-slim
```

---

## How Reports Are Used in Real Teams

- Attached to **Jira / Linear** security tickets
- Archived as **Jenkins / GitHub Actions** build artifacts
- Shared with **security and compliance** teams
- Included in **audit documentation**

---

## Notes

- The `@` before `html.tpl` is required — it tells Trivy to read from a file, not treat it as a string.
- The `html.tpl` must be in the current folder, or provide the full path.
- JSON reports are commonly used in SIEM integrations and security dashboards.
