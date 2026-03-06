# 08 — Alternatives

> Environment: Ubuntu 22.04 LTS — AWS EC2 t2.micro

Trivy is the most widely used container security scanner, but it is not the only one.
This section covers two common alternatives — Grype and Docker Scout — and how they compare.

---

## 1. Grype (by Anchore)

Grype is a fast, open-source vulnerability scanner.
It is simpler than Trivy — focused purely on vulnerability scanning with no secret or config detection.

### Install on Linux (Ubuntu)

```bash
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
```

| Part | What it does |
|------|-------------|
| `curl -sSfL` | Downloads the install script silently |
| `sh -s --` | Runs the script |
| `-b /usr/local/bin` | Installs the binary to this folder so you can run it from anywhere |

Verify the install:

```bash
grype version
```

GitHub → https://github.com/anchore/grype

### Scan an image

```bash
grype nginx:latest
```


### Grype vs Trivy — What is different?

Grype output looks very similar to Trivy but it is missing secret detection, config scanning, and HTML reports.
Use it when you want a lightweight, single-purpose scanner.

---

## 2. Docker Scout

Docker Scout is built directly into the Docker CLI.
Its standout feature is telling you exactly which base image tag to upgrade to in order to reduce vulnerabilities — not just listing the CVEs.

### Prerequisites

- Docker account (free) — sign up at hub.docker.com
- Docker CLI installed and logged in

### Login to Docker

```bash
docker login
```

Enter your DockerHub username and password when prompted.

### Commands

```bash
# Quick summary — shows total CVEs by severity
docker scout quickview nginx:latest

# Full CVE list with details
docker scout cves nginx:latest
```


---

## Side-by-Side Comparison

| Feature | Trivy | Grype | Docker Scout |
|---------|-------|-------|-------------|
| Image scanning | ✅ | ✅ | ✅ |
| Filesystem scanning | ✅ | ✅ | ❌ |
| Secret detection | ✅ | ❌ | ❌ |
| Misconfiguration scanning | ✅ | ❌ | ❌ |
| SBOM generation | ✅ | ✅ with Syft | ✅ |
| Base image fix suggestions | ❌ | ❌ | ✅ |
| HTML reports | ✅ | ❌ | ❌ |
| JSON output | ✅ | ✅ | ✅ |
| Needs account | ❌ | ❌ | ✅ DockerHub |
| CI/CD integration | ✅ | ✅ | ✅ |
| Works fully offline | ✅ | ✅ | ❌ |
| Free | ✅ | ✅ | ✅ basic |

---

## When to Use Each

**Use Trivy when:**
- You need one tool that does everything — images, filesystem, secrets, configs
- You want zero account setup
- You are integrating into a CI/CD pipeline
- You need HTML reports

**Use Grype when:**
- You only need fast image scanning
- You want a minimal, single-purpose tool
- You are already using Syft for SBOM generation and want a matching scanner

**Use Docker Scout when:**
- You want "upgrade to this base image tag" recommendations
- You are already using Docker Desktop and want a visual dashboard
- You need DockerHub integration for team-wide visibility

---

## Recommendation

For most DevSecOps work on Linux — stick with **Trivy**.
It covers the most ground, needs no account, and fits perfectly into CI/CD pipelines.

Add **Docker Scout** alongside it if you want base image upgrade recommendations.

---

## Notes

- Docker Scout requires `docker login` even for public image scans
- Grype output is almost identical to Trivy but missing the secrets and config columns
- Trivy is the industry standard for container security scanning in DevSecOps pipelines
