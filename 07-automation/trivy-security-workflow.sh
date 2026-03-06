#!/bin/bash
# trivy-security-workflow.sh
# Full end-to-end DevSecOps security workflow
# Build → Scan → Fix → Rebuild → Push → Final Scan

echo "===== STEP 1: Build Initial Docker Image ====="
docker build -t shubhamm18/webapp:02 .

echo ""
echo "===== STEP 2: List Docker Images ====="
docker images

echo ""
echo "===== STEP 3: Scan Image with Trivy (All Vulnerabilities) ====="
trivy image shubhamm18/webapp:02

echo ""
echo "===== STEP 4: Scan Only HIGH and CRITICAL ====="
trivy image --severity HIGH,CRITICAL shubhamm18/webapp:02

echo ""
echo "===== STEP 5: CI/CD Scan (Fails Pipeline if Vulnerabilities Found) ====="
trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 --no-progress shubhamm18/webapp:02

echo ""
echo "===== STEP 6: Create Patch Dockerfile to Fix Vulnerable Dependency ====="

cat <<DOCKEREOF > Dockerfile.patch
FROM shubhamm18/webapp:02

WORKDIR /app

# Fix vulnerable dependency found by Trivy
RUN npm install cross-spawn@7.0.5

CMD ["npm", "start"]
DOCKEREOF

echo "Patch Dockerfile created."

echo ""
echo "===== STEP 7: Build Patched Image ====="
docker build -t shubhamm18/webapp:03 -f Dockerfile.patch .

echo ""
echo "===== STEP 8: Verify New Image Exists ====="
docker images

echo ""
echo "===== STEP 9: Scan Patched Image ====="
trivy image --severity HIGH,CRITICAL shubhamm18/webapp:03

echo ""
echo "===== STEP 10: Login to Docker Hub ====="
docker login

echo ""
echo "===== STEP 11: Push Secure Image to DockerHub ====="
docker push shubhamm18/webapp:03

echo ""
echo "===== STEP 12: Final Scan — Ignore Unfixed Vulnerabilities ====="
trivy image --ignore-unfixed --severity HIGH,CRITICAL shubhamm18/webapp:03

echo ""
echo "===== SECURITY WORKFLOW COMPLETED ====="
