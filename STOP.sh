#!/bin/bash
cd "$(dirname "$0")/backend"
docker-compose down
echo "All containers stopped."
