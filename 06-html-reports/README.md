# 06 — HTML Reports

> Environment: Ubuntu 22.04 LTS — AWS EC2 t2.micro

Terminal output is fine for quick checks during development.
But in real teams, security findings need to be shared — with developers, security teams, managers, or stored as compliance evidence.
That is where proper reports come in.

---

## Why Reports Matter

- Terminal output disappears when you close the session
- Teams need something shareable — via email, Slack, or Jira tickets
- CI/CD pipelines need artifacts to archive and review later
- Compliance and audits require documented evidence of security scans

---

## Report Formats Trivy Supports

| Format | Flag | Best for |
|--------|------|---------|
| Table | `--format table` | Default terminal output, quick checks |
| JSON | `--format json` | Machine-readable, API integrations, storing history |
| HTML | `--format template` | Sharing with humans, tickets, audits |
| CycloneDX | `--format cyclonedx` | SBOM — Software Bill of Materials |
| SPDX | `--format spdx` | Another SBOM standard |

---

## Generating an HTML Report

### Step 1 — Download the HTML template

Aqua Security provides an official HTML template for Trivy.
Download it once and reuse it:

```bash
wget https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl -O html.tpl
```

| Part | What it does |
|------|-------------|
| `wget` | Downloads a file from the internet |
| the URL | Official Trivy HTML template hosted on GitHub |
| `-O html.tpl` | Saves the file as `html.tpl` in current directory |

This file controls how the report looks. It converts raw scan data into a proper web page.

---

### Step 2 — Run scan and save as HTML

```bash
trivy image \
  --format template \
  --template "@html.tpl" \
  -o trivy-report.html \
  python:3.10-slim
```

| Flag | What it does |
|------|-------------|
| `--format template` | Use a custom template instead of default table output |
| `--template "@html.tpl"` | The `@` tells Trivy to read from a file. Points to html.tpl |
| `-o trivy-report.html` | Save output to this file instead of printing to terminal |
| `python:3.10-slim` | The image being scanned |


---

### Step 3 — View the report

If you have a desktop environment on your Linux machine:

```bash
xdg-open trivy-report.html
```

If you are on a headless EC2 server (no desktop), copy the file to your local machine first:

```bash
# Run this on your LOCAL machine terminal
scp -i your-key.pem ubuntu@your-ec2-ip:/home/ubuntu/trivy-report.html ./trivy-report.html
```

Then open `trivy-report.html` in your browser.


---

## HIGH and CRITICAL Only Report

For a focused report that shows only what needs immediate action:

```bash
trivy image \
  --severity HIGH,CRITICAL \
  --format template \
  --template "@html.tpl" \
  -o trivy-report-critical.html \
  python:3.10-slim
```

This is the version you would share with a security team or attach to a Jira ticket.

---

## JSON Report

```bash
trivy image -f json -o report.json nginx
```

View it in a readable format:

```bash
cat report.json | python3 -m json.tool | head -50
```

JSON reports are used when:
- Another tool or script needs to process the results
- You want to store scan history over time
- You are integrating with a SIEM or security dashboard

---

## SBOM — Software Bill of Materials

An SBOM is a complete list of every package inside an image — like an ingredients list for software.
Required by many enterprise security teams and compliance frameworks.

```bash
trivy image --format cyclonedx -o sbom.json python:3.10-slim
```

---

## How Reports Are Used in Real Teams

- Attached to **Jira or Linear** security tickets
- Archived as **Jenkins or GitHub Actions** build artifacts
- Shared with the **security and compliance team**
- Included in **audit documentation**
- Compared week over week to track security improvement

---

## Notes

- The `@` before `html.tpl` is required. Without it Trivy treats the value as a raw string, not a filename.
- `html.tpl` must be in the current directory when you run the command, or provide the full path.
- JSON reports are the most useful format for automation and integration with other tools.
