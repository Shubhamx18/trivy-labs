# 01 — Setup

> Environment: Ubuntu 22.04 LTS — AWS EC2 t2.micro

---

## What is Trivy?

Trivy is a free, open-source security scanner developed by **Aqua Security**.

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

Unlike other tools that only check OS packages, Trivy does all of this in one command.

```bash
trivy image nginx
```

---

## Why Trivy Exists

Modern applications depend on many packages and libraries.
Any one of them can contain a known security vulnerability.

Example — what lives inside a typical container:

```
your app
  └── node modules / pip packages
        └── linux packages
              └── openssl
              └── glibc
              └── libssl
```

**Purpose:**
```
Prevent vulnerable software from reaching production
```

---

## What are CVEs?

CVE = **Common Vulnerabilities and Exposures**

A CVE is a public identifier assigned to every known security flaw.

Example:
```
CVE-2024-21538
```

Breaking it down:
```
Year           →  2024
Vulnerability  →  21538
```

Every CVE gets a severity score:

```
CRITICAL  →  Actively exploitable, fix immediately
HIGH      →  Significant risk, fix soon
MEDIUM    →  Moderate risk, fix in next cycle
LOW       →  Minor or theoretical risk
```

These scores come from the **National Vulnerability Database (NVD)** using **CVSS scoring**.

---

## How Trivy Works

Core components:

```
Artifact Analyzer
       ↓
Vulnerability Database
       ↓
Matching Engine
       ↓
Report Formatter
```

Flow:

```
Target (image / repo / filesystem)
       ↓
Trivy scans all packages and versions
       ↓
Matches against CVE database
       ↓
Generates report
```

---

## Where Trivy Gets Vulnerability Data

Trivy pulls from multiple official sources:

- National Vulnerability Database (NVD)
- GitHub Security Advisory Database
- RedHat Security Advisories
- Debian Security Tracker
- Alpine Security Tracker

Behind the scenes — **Trivy DB Pipeline:**

```
Multiple vulnerability sources
       ↓
Data normalization
       ↓
Duplicate removal
       ↓
Compression
       ↓
Trivy DB published
       ↓
Your machine downloads DB (~30MB)
       ↓
Fast local matching on every scan
```

This is why scans are very fast — all matching happens locally after the first download.

---

## Installing Trivy on Ubuntu (AWS EC2)

### Step 1 — Update the package list

Always update before installing anything new:

```bash
sudo apt-get update
```

---

### Step 2 — Install required tools

```bash
sudo apt-get install wget gnupg -y
```

- `wget` — downloads files from the internet via terminal
- `gnupg` — verifies the authenticity of packages using GPG keys
- `-y` — auto-confirms prompts so the install does not pause

---

### Step 3 — Add Aqua Security's GPG key

```bash
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
```

Breaking this command down:

| Part | What it does |
|------|-------------|
| `wget -qO -` | Downloads the GPG key quietly and prints to stdout |
| `gpg --dearmor` | Converts key from text format to binary `.gpg` format |
| `sudo tee /usr/share/keyrings/trivy.gpg` | Saves the key to system keyring folder |
| `> /dev/null` | Hides output so terminal stays clean |

Without this key, `apt` will reject Trivy packages as untrusted and the install will fail.

---

### Step 4 — Register the Trivy repository

```bash
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
```

Breaking this command down:

| Part | What it does |
|------|-------------|
| `echo "deb ..."` | Creates the repository entry as a string |
| `signed-by=...trivy.gpg` | Tells apt to verify packages using our saved key |
| `sudo tee -a /etc/apt/sources.list.d/trivy.list` | Appends the repo entry to apt sources |

Without this step, `apt` does not know Trivy exists and cannot find it to install.

---

### Step 5 — Refresh and install

```bash
sudo apt-get update
sudo apt-get install trivy -y
```

Run `apt-get update` again after adding the new repo so apt picks up the Trivy packages.

---

### Step 6 — Verify the installation

```bash
trivy --version
```

Expected output:
```
Version: 0.58.x
```


---

## First Test Scan

Run a quick scan to confirm everything is working:

```bash
trivy image alpine:latest
```

If you see a table with CVE results (or a clean "0 found" message), Trivy is installed and working correctly.


---

## Basic Commands to Know

```bash
# Scan a container image
trivy image nginx

# Scan filesystem
trivy fs .

# Scan a Git repository
trivy repo https://github.com/user/project

# Scan Kubernetes cluster
trivy k8s cluster
```

---

## Notes

- **First scan is slow** — Trivy downloads its vulnerability database (~30MB) on the very first run. This is completely normal. Every scan after that is fast.
- **Cache location** — database is stored at `~/.cache/trivy`
- **GPG key warning** — if `apt-get update` shows a GPG error, redo Step 3
- **No account needed** — Trivy is completely free, no signup required
