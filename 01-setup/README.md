# Trivy Installation on Ubuntu (AWS EC2)

> Tested on: Ubuntu 22.04 LTS — AWS EC2 t2.micro

---

## What is Trivy?

Trivy is a fast, all-in-one open-source security scanner.
Unlike other tools that only check OS packages, Trivy also scans application libraries, secrets, and misconfigurations — all in one command.

It is maintained by Aqua Security and is actively used in production DevSecOps pipelines.

---

## Why install it on EC2?

Most real security scanning happens inside CI/CD pipelines running on Linux servers.
Learning it on an EC2 Ubuntu instance gives you the closest experience to how it is actually used in production.

---

## Installation Steps

### Step 1 — Install required tools

```bash
sudo apt-get install wget gnupg
```

`wget` — downloads files from the internet
`gnupg` — verifies the authenticity of packages using GPG keys

---

### Step 2 — Add Aqua Security's GPG key

```bash
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
```

This downloads Aqua Security's public key, converts it to `.gpg` format, and saves it.
Without this, `apt` will reject packages from the Trivy repository as untrusted.

---

### Step 3 — Register the Trivy repository

```bash
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
```

Adds the official Trivy apt repository to your system's package sources.

---

### Step 4 — Install Trivy

```bash
sudo apt-get update
sudo apt-get install trivy
```

---

### Step 5 — Verify the installation

```bash
trivy --version
```

Expected output:
```
Version: 0.58.x
```

> 📸 Add screenshot → `trivy --version` output on your terminal

---

## First Scan — Quick Test

```bash
trivy image alpine:latest
```

If you see a table of CVEs (or a clean result saying 0 found), Trivy is working correctly.

> 📸 Add screenshot → first scan output

---

## Notes

- The first scan downloads Trivy's vulnerability database (~30MB). This only happens once.
- If `apt-get update` gives a GPG warning, redo Step 2.
- Cache is stored at `~/.cache/trivy` — subsequent scans are much faster.
