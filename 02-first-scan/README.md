# Trivy Image Scanning

Scanning Docker images is the most common use case for Trivy.
This section covers how to run scans, what the output means, and how to use it effectively.

---

## Basic Image Scan

```bash
trivy image nginx:latest
```

Trivy pulls image metadata, checks every package against its CVE database, and prints a table.

> 📸 Add screenshot → `trivy image nginx:latest` output

---

## Understanding the Output

Each row in the scan table contains:

| Column | What it means |
|--------|--------------|
| Library | The package or dependency with the vulnerability |
| Vulnerability ID | The CVE number (e.g. CVE-2024-12345) |
| Severity | LOW / MEDIUM / HIGH / CRITICAL |
| Installed Version | Version currently in the image |
| Fixed Version | Version where the CVE was patched |
| Title | Short description of the issue |

> If **Fixed Version** is empty → no upstream patch exists yet.

---

## Trivy Cache

Trivy caches its vulnerability database locally so it does not re-download on every scan.

```
Linux  →  ~/.cache/trivy
macOS  →  ~/Library/Caches/trivy
```

First scan is slow (DB download). All scans after that are fast.

---

## Scanning a Specific Image

```bash
trivy image python:3.10-slim
trivy image ubuntu:22.04
trivy image alpine:3.18
```

> 📸 Add screenshot → scan output of your chosen image

---

## What to Look For

- Focus on **HIGH** and **CRITICAL** first
- Check if a **Fixed Version** exists — if yes, that vulnerability is patchable
- **LOW** severity issues are generally informational, not urgent
- A completely clean scan is rare for real-world images
