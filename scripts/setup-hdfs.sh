#!/bin/bash

echo "=========================================="
echo "HDFS Praktikum Setup"
echo "=========================================="
echo ""

# Wait for namenode ready
echo "Menunggu NameNode ready..."
sleep 10

# Format namenode (hanya sekali)
echo "Format NameNode..."
docker exec namenode hdfs namenode -format -force

# Create directories di HDFS
echo "Membuat direktori praktikum di HDFS..."
docker exec namenode hdfs dfs -mkdir -p /praktikum
docker exec namenode hdfs dfs -mkdir -p /data
docker exec namenode hdfs dfs -chmod 777 /praktikum
docker exec namenode hdfs dfs -chmod 777 /data

# List direktori
echo ""
echo "Daftar direktori HDFS:"
docker exec namenode hdfs dfs -ls /

echo ""
echo "✓ HDFS setup complete!"
echo ""
echo "WebUI tersedia di: http://localhost:9870"
echo ""
