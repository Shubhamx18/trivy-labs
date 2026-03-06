# 02 — First Scan

> Environment: Ubuntu 22.04 LTS — AWS EC2 t2.micro

---

## What Happens When You Scan?

When you run `trivy image`, here is what Trivy does internally:

```
Pull image metadata
       ↓
Inspect every layer of the image
       ↓
List all installed packages and their versions
       ↓
Check each package against the CVE database
       ↓
Print the report table
```

---

## Prerequisites

Make sure Docker is running before scanning:

```bash
sudo systemctl status docker
```

If it shows inactive, start it:

```bash
sudo systemctl start docker
```

---

## Basic Image Scan

```bash
trivy image nginx
```

Trivy fetches the image metadata, checks every package against its CVE database, and prints a table.


---

## Understanding the Output Table

Each row in the scan result means one vulnerability. Here is what each column tells you:

| Column | What it tells you |
|--------|------------------|
| **Library** | The package that has the vulnerability |
| **Vulnerability ID** | The CVE number e.g. CVE-2024-12345 |
| **Severity** | LOW / MEDIUM / HIGH / CRITICAL |
| **Installed Version** | Version currently inside the image |
| **Fixed Version** | Version where this CVE was patched |
| **Title** | Short description of the vulnerability |

**Real example from a scan:**

```
Library: minimatch
Installed: 9.0.5
Fixed: 10.2.1
```

This means:
```
Update minimatch to version 10.2.1
Rebuild the image
Scan again to confirm fix
```

**Key rule:**
- If **Fixed Version exists** → you can fix it by upgrading that package
- If **Fixed Version is empty** → no upstream patch exists yet, nothing you can do right now

---

## Severity Levels Explained

| Level | Meaning | What to do |
|-------|---------|------------|
| **CRITICAL** | Actively exploitable, serious impact | Fix immediately |
| **HIGH** | Significant security risk | Fix soon |
| **MEDIUM** | Moderate risk | Fix in next release |
| **LOW** | Minor or theoretical risk | Fix when convenient |

> Focus on **HIGH** and **CRITICAL** first.
> Most real-world images have LOW and MEDIUM CVEs that are acceptable to live with temporarily.

---

## Scanning Different Images

Try these to see how vulnerability counts vary between image types:

```bash
# Debian-based — tends to have more CVEs (more packages)
trivy image python:3.10

# Slim variant — fewer packages = fewer CVEs
trivy image python:3.10-slim

# Alpine-based — minimal OS, usually the lowest CVE count
trivy image python:3.10-alpine

# Ubuntu base image
trivy image ubuntu:22.04
```


Alpine-based images almost always have fewer CVEs than Debian or Ubuntu images
because they ship with far fewer pre-installed packages.

---

## Trivy Cache

Trivy stores its vulnerability database locally so it does not re-download on every scan:

```bash
# Check the cache location
ls ~/.cache/trivy/

# Clear the cache — forces fresh DB download on next scan
trivy image --clear-cache
```

The database is updated regularly by Aqua Security.
If your scans feel outdated, clear the cache and let it re-download.

---

## Notes

- Trivy does not need `docker pull` first — it fetches image metadata itself
- First scan is slow because it downloads the DB. Every scan after is fast.
- A completely clean scan (0 vulnerabilities) is very rare for real-world images — that is completely normal
