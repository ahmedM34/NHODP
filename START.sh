#!/bin/bash
set -e

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║           NHODP — National Health Open Data Portal       ║"
echo "║           Nile University · ITCS-GP25-96                 ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

cd "$(dirname "$0")/backend"

echo "[1/3] Stopping any running containers..."
docker-compose down --remove-orphans 2>/dev/null || true

echo "[2/3] Starting all backend services..."
docker-compose up -d --build

echo ""
echo "[3/3] Waiting for services to be healthy (up to 90s)..."
for i in $(seq 1 18); do
    sleep 5
    AUTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8001/health 2>/dev/null || echo "000")
    DATA=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8002/health 2>/dev/null || echo "000")
    OCR=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8003/health 2>/dev/null || echo "000")
    if [ "$AUTH" = "200" ] && [ "$DATA" = "200" ] && [ "$OCR" = "200" ]; then
        echo ""
        echo "✓ All services are healthy!"
        break
    fi
    printf "  Attempt %d/18 — Auth:%s Dataset:%s OCR:%s\r" "$i" "$AUTH" "$DATA" "$OCR"
done

echo ""
echo "══════════════════════════════════════════════════════════"
echo "  BACKEND READY"
echo ""
echo "  Auth API:       http://localhost:8001/docs"
echo "  Dataset API:    http://localhost:8002/docs"
echo "  OCR API:        http://localhost:8003/docs"
echo "  Content API:    http://localhost:8004/docs"
echo "  Analytics API:  http://localhost:8005/docs"
echo "  Nginx Gateway:  http://localhost:8080"
echo ""
echo "  Default Admin:  admin@nhodp.gov.eg / Admin@2026"
echo "══════════════════════════════════════════════════════════"
echo ""
echo "To start the Flutter Web frontend:"
echo "  cd frontend"
echo "  flutter pub get && flutter run -d chrome"
echo ""
echo "Or build for production:"
echo "  flutter build web --dart-define=API_BASE_URL=http://YOUR_SERVER_IP"
echo "  cd build/web && python3 -m http.server 3000"
echo ""
