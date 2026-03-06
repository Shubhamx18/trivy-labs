#!/bin/bash
# scan-html.sh — Run a Trivy image scan and save an HTML report with timestamp

read -p "Enter Docker image name (e.g. nginx:latest): " IMAGE

DATE=$(date +"%Y-%m-%d_%H-%M")
REPORT_DIR="reports"

mkdir -p "$REPORT_DIR"

# Download html.tpl if not already present
if [[ ! -f html.tpl ]]; then
    echo "Downloading HTML template..."
    wget -q https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl -O html.tpl
fi

echo ""
echo "Scanning $IMAGE ..."
echo ""

trivy image \
  --severity HIGH,CRITICAL \
  --format template \
  --template "@html.tpl" \
  "$IMAGE" -o "$REPORT_DIR/trivy-$DATE.html"

echo "Scan complete."
echo "Report saved to: $REPORT_DIR/trivy-$DATE.html"
