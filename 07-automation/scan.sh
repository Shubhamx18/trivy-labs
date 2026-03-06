#!/bin/bash
# scan.sh — Run a Trivy image scan and save a text report with timestamp

read -p "Enter Docker image name (e.g. nginx:latest): " IMAGE

DATE=$(date +"%Y-%m-%d_%H-%M")
REPORT_DIR="reports"

mkdir -p "$REPORT_DIR"

echo ""
echo "Scanning $IMAGE ..."
echo ""

trivy image \
  --severity HIGH,CRITICAL \
  --format table \
  "$IMAGE" > "$REPORT_DIR/trivy-$DATE.txt"

echo "Scan complete."
echo "Report saved to: $REPORT_DIR/trivy-$DATE.txt"
