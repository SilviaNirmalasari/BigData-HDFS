#!/bin/bash

echo "=========================================="
echo "BigData HDFS - Complete Setup"
echo "=========================================="
echo ""

# 1. Create data directories
echo "[1/5] Membuat folder data..."
mkdir -p data/hdfs/{namenode,datanode}
mkdir -p data/mongodb/{configdb}
mkdir -p data/cassandra

# 2. Make scripts executable
echo "[2/5] Membuat scripts executable..."
chmod +x scripts/*.sh

# 3. Start all services
echo "[3/5] Memulai Docker Compose services..."
docker compose up -d
docker compose ps
# 4. Wait untuk services siap
echo "[4/5] Menunggu services ready (30 detik)..."
sleep 30

# 5. Run setup scripts
echo "[5/5] Menjalankan setup scripts..."
bash scripts/setup-hdfs.sh

echo ""
echo "=========================================="
echo "✓ ALL SERVICES READY!"
echo "=========================================="
echo ""
echo "HDFS WebUI:    http://localhost:9870"
echo "HDFS API:      hdfs://namenode:9000"
echo ""
echo "MongoDB:       mongodb://admin:admin123@localhost:27017"
echo "Cassandra:     localhost:9042"
echo ""
echo "Test services:"
echo "  bash scripts/test-mongodb.sh"
echo "  bash scripts/test-cassandra.sh"
echo ""
echo "Jalankan perintah di NameNode:"
echo "  docker exec -it namenode bash"
echo ""
echo "Stop semua services:"
echo "  docker compose down"
echo ""
