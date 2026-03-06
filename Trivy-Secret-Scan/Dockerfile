# ⚠️  BAD PRACTICE — Secrets hardcoded as ENV variables
# This is intentionally wrong — for Trivy secret scan demo only

FROM python:3.10-slim

ENV DB_PASSWORD=HardcodedPassword123
ENV API_TOKEN=token_abcdef123456789

COPY app.py /app/app.py
CMD ["python", "/app/app.py"]
