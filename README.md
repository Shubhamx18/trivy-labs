# 🔐 Trivy

Essential commands and hands-on labs for container security scanning with Trivy.

---

## 📖 What is Trivy?

Trivy is an open-source security scanner by Aqua Security.
It scans Docker images, filesystems, and Git repos for:

- **CVEs** — known vulnerabilities in OS packages and libraries
- **Secrets** — hardcoded API keys, passwords, tokens
- **Misconfigurations** — insecure Dockerfile practices

Used widely in DevSecOps pipelines alongside Jenkins, GitHub Actions, and GitLab CI.

---

## 📂 Repository Structure

```
trivy-labs/
├── 01-setup/                   → Install Trivy on Ubuntu EC2, verify setup
├── 02-first-scan/              → Scan Docker images, understand CVE output
├── 03-flags-and-filters/       → --severity, --exit-code, --vuln-type flags
├── 04-fix-cves/                → Identify and fix vulnerabilities in images
├── 05-secret-detection/        → Detect hardcoded secrets in code and configs
├── 06-html-reports/            → Generate and share HTML vulnerability reports
├── 07-automation/              → Shell scripts for automated scanning
├── 08-alternatives/            → Grype and Docker Scout vs Trivy
└── 09-bulk-scanning/           → Scan multiple images from a list
```

---

## ⚡ Quick Command Reference

```bash
# Verify installation
trivy --version

# Scan a Docker image (all vulnerabilities)
trivy image nginx:latest

# Scan only HIGH and CRITICAL
trivy image --severity HIGH,CRITICAL nginx:latest

# Scan filesystem for secrets
trivy fs --scanners secret .

# Scan filesystem (everything)
trivy fs .

# Generate HTML report
trivy image --format template --template "@html.tpl" -o report.html nginx:latest

# Generate SBOM
trivy image --format cyclonedx -o sbom.json nginx:latest
```

---

## 🛠️ Prerequisites

- Ubuntu EC2 (or any Linux machine)
- Docker installed and running
- Trivy installed → see `Trivy-Installation/`

---

## 👤 Author

**Shubhamx18** — documented during hands-on Trivy practice.
