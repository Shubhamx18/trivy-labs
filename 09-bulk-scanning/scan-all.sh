#!/bin/bash
# scan-all.sh — Scan multiple Docker images from images.txt and generate HTML reports
set -euo pipefail

INPUT="images.txt"
REPORT_DIR="reports"

# Check required tools
command -v trivy >/dev/null 2>&1 || { echo "Error: trivy is not installed."; exit 1; }
command -v wget  >/dev/null 2>&1 || { echo "Error: wget is not installed."; exit 1; }

# Check input file exists
[[ -f "$INPUT" ]] || { echo "Error: $INPUT not found."; exit 1; }

# Download HTML template if not already present
if [[ ! -f html.tpl ]]; then
    echo "Downloading HTML template..."
    wget -q https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl -O html.tpl
fi

mkdir -p "$REPORT_DIR"

echo ""
echo "Starting bulk scan..."
echo "═══════════════════════════════════════"

while IFS= read -r image || [[ -n "$image" ]]; do
    # Skip empty lines
    [[ -z "$image" ]] && continue

    echo ""
    echo "Scanning: $image"

    # Sanitize image name for use as filename
    filename=$(echo "$image" | sed 's/[:/]/_/g')
    output="$REPORT_DIR/${filename}.html"

    trivy image \
        --severity HIGH,CRITICAL \
        --format template \
        --template "@html.tpl" \
        -o "$output" \
        "$image"

    echo "Report saved: $output"
    echo "───────────────────────────────────────"

done < "$INPUT"

echo ""
echo "All scans complete. Reports are in ./$REPORT_DIR/"
