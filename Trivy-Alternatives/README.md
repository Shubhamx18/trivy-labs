# Trivy Alternatives — Grype and Docker Scout

Trivy is the most popular container security scanner, but it is not the only one.
This section covers two common alternatives and how they compare — based on actual hands-on testing.

---

## 1. Grype (by Anchore)

Grype is a fast, open-source vulnerability scanner.
It is simpler than Trivy — focused purely on vulnerability scanning with no secret or config scanning.

### Install

```bash
# macOS
brew install grype

# Linux
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
```

GitHub → https://github.com/anchore/grype

### Scan an image

```bash
grype python:3.10-slim
```

> 📸 Add screenshot → Grype scan output

---

## 2. Docker Scout

Docker Scout is built directly into the Docker CLI and Docker Desktop.
Its standout feature is telling you exactly which base image tag to upgrade to in order to fix vulnerabilities.

### Prerequisites

- Docker account (free)
- Logged into Docker CLI

```bash
docker login
```

### Commands

```bash
# Quick summary of vulnerabilities
docker scout quickview python:3.10-slim

# Full CVE list with details
docker scout cves python:3.10-slim
```

> 📸 Add screenshot → `docker scout quickview` output

---

## Side-by-Side Comparison

| Feature | Trivy | Grype | Docker Scout |
|---------|-------|-------|-------------|
| Image scanning | ✅ | ✅ | ✅ |
| Filesystem scanning | ✅ | ✅ | ❌ |
| Secret detection | ✅ | ❌ | ❌ |
| Misconfiguration scanning | ✅ | ❌ | ❌ |
| SBOM generation | ✅ | ✅ (with Syft) | ✅ |
| Base image fix suggestions | ❌ | ❌ | ✅ |
| Visual dashboard | ❌ | ❌ | ✅ Docker Desktop |
| Needs account | ❌ | ❌ | ✅ Docker Hub |
| CI/CD integration | ✅ | ✅ | ✅ |
| Completely offline | ✅ | ✅ | ❌ |

---

## When to Use Each

**Use Trivy when:**
- You need one tool that does everything (images + filesystem + secrets + configs)
- You want zero account setup
- You are integrating into Jenkins, GitHub Actions, or GitLab CI

**Use Grype when:**
- You only need fast image scanning
- You are already using Syft for SBOM and want a scanner that pairs with it
- You prefer a minimal, single-purpose tool

**Use Docker Scout when:**
- You want actionable "upgrade to this tag" recommendations
- You are already using Docker Desktop and want a visual dashboard
- You need Docker Hub integration for team visibility

---

## Recommendation

For most DevSecOps setups, start with **Trivy** — it covers the most ground with zero setup.
Add **Docker Scout** if you need base image upgrade suggestions.

---

## Notes

- Docker Scout requires `docker login` even for public images — this felt unnecessary during testing.
- Grype's output is almost identical to Trivy's but missing the secret and config columns.
- Trivy's HTML report is much more useful than what either alternative generates by default.
