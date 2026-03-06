# 🔐 Trivy

Hands-on security scanning labs built while learning Trivy on Ubuntu/Linux.
This repo covers everything from installation to a full DevSecOps pipeline — with clear notes,
every command explained, and real examples from actual practice sessions.

> All labs are done on **Ubuntu (AWS EC2)** — Linux only.

---

## 📖 What is Trivy?

Trivy is a free, open-source security scanner developed by Aqua Security.

It scans:
- Container images
- Filesystem
- Git repositories
- Kubernetes clusters
- Infrastructure as Code

For:
- **Vulnerabilities** — known CVEs in OS packages and app libraries
- **Misconfigurations** — insecure Dockerfile or config practices
- **Secrets** — hardcoded API keys, passwords, tokens
- **Licenses** — license compliance issues in dependencies

```bash
trivy image nginx
```

---

## 📂 Repository Structure

```
trivy-labs/
├── 01-setup/               → Install Trivy on Ubuntu EC2, understand CVEs and architecture
├── 02-first-scan/          → Scan Docker images, understand the output table
├── 03-flags-and-filters/   → --severity, --exit-code, --ignore-unfixed and more
├── 04-fix-cves/            → Find vulnerabilities and fix them properly
├── 05-secret-detection/    → Detect hardcoded secrets in code and configs
├── 06-html-reports/        → Generate JSON, HTML, and SBOM reports
├── 07-automation/          → Full DevSecOps security workflow script
├── 08-alternatives/        → Grype and Docker Scout vs Trivy
└── 09-bulk-scanning/       → Scan multiple images at once from a list
```

---

## ⚡ Quick Command Reference

```bash
# Check version
trivy --version

# Scan a container image
trivy image nginx

# Scan only HIGH and CRITICAL
trivy image --severity HIGH,CRITICAL nginx

# Ignore vulnerabilities with no fix available
trivy image --ignore-unfixed nginx

# Fail pipeline if vulnerabilities found
trivy image --severity HIGH,CRITICAL --exit-code 1 nginx

# Scan filesystem for secrets only
trivy fs --scanners secret .

# Scan filesystem for everything
trivy fs .

# Scan a Git repository
trivy repo https://github.com/user/project

# Scan Kubernetes cluster
trivy k8s cluster

# Output as JSON
trivy image -f json -o report.json nginx

# Generate HTML report
trivy image --format template --template "@html.tpl" -o report.html nginx

# Generate SBOM
trivy image --format cyclonedx -o sbom.json nginx
```

---

## 🔁 Real CI/CD Command

This is what most real DevOps pipelines use as their security gate:

```bash
trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 --no-progress your-image
```

If vulnerabilities are found → pipeline fails → deployment is blocked.

---

## ✅ What We Practiced

- Installed Trivy on Ubuntu EC2
- Scanned Docker images
- Understood CVE and CVSS scoring
- Generated JSON reports
- Filtered by severity
- Used exit codes for pipelines
- Fixed vulnerabilities in dependencies
- Rebuilt Docker image
- Rescanned image
- Pushed fixed image to DockerHub

---
