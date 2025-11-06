#!/bin/bash

set -e

echo "╔════════════════════════════════════════╗"
echo "║  BigData - Apache Hadoop Setup         ║"
echo "╚════════════════════════════════════════╝"
echo ""


# 1. CLEANUP
echo "[1/6] Cleaning up..."
docker-compose down -v 2>/dev/null || true
sudo rm -rf data/hdfs/* 2>/dev/null || true
mkdir -p data/hdfs/{namenode,datanode}
mkdir -p data/mongodb
mkdir -p data/cassandra

# 2. UPDATE docker-compose.yml
echo "[2/6] Updating docker-compose.yml (Apache Hadoop)..."
cat > docker-compose.yml << 'COMPOSE_EOF'
services:
  namenode:
    image: apache/hadoop:3.4.1
    container_name: namenode
    restart: always
    ports:
      - "9870:9870"
      - "9000:9000"
    volumes:
      - ./data/hdfs/namenode:/hadoop/dfs/name
    environment:
      - CLUSTER_NAME=bigdata
    networks:
      - bdnet

  datanode:
    image: apache/hadoop:3.4.1
    container_name: datanode
    restart: always
    ports:
      - "9864:9864"
    volumes:
      - ./data/hdfs/datanode:/hadoop/dfs/data
    networks:
      - bdnet
    depends_on:
      - namenode

  mongodb:
    image: mongo:6.0
    container_name: mongodb
    restart: always
    ports:
      - "27017:27017"
    volumes:
      - ./data/mongodb:/data/db
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: admin123
    networks:
      - bdnet

  cassandra:
    image: cassandra:4.1
    container_name: cassandra
    restart: always
    ports:
      - "9042:9042"
    volumes:
      - ./data/cassandra:/var/lib/cassandra
    networks:
      - bdnet

networks:
  bdnet:
    driver: bridge
COMPOSE_EOF

# 3. START SERVICES
echo "[3/6] Starting services..."
docker compose up -d
echo "⏳ Waiting 180 seconds for services (longer wait)..."
sleep 180

# 4. CHECK HEALTH
echo ""
echo "Checking container status..."
docker compose ps

# 5. SETUP HDFS - dengan retry
echo ""
echo "[4/6] Setting up HDFS..."
for i in {1..5}; do
  if docker exec namenode bash << 'HDFS_EOF'
echo "Creating /praktikum..."
hdfs dfs -mkdir -p /praktikum

echo "Uploading data..."
echo "id,name,dept,salary
1,Andi,IT,5000000
2,Budi,HR,4500000
3,Citra,Finance,4800000
4,Doni,IT,5200000
5,Eka,HR,4700000" | hdfs dfs -put - /praktikum/data.csv

echo "✓ HDFS data uploaded"
HDFS_EOF
  then
    break
  else
    echo "Retry $i/5..."
    sleep 30
  fi
done

# 6. DISPLAY HDFS DATA
echo ""
echo "[5/6] Displaying HDFS Data..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec namenode hdfs dfs -ls /praktikum/
echo ""
echo "📄 Data content:"
docker exec namenode hdfs dfs -cat /praktikum/data.csv

# 7. SETUP MONGODB & CASSANDRA
echo ""
echo "[6/6] Setting up MongoDB & Cassandra..."

docker exec mongodb mongosh -u admin -p admin123 --authenticationDatabase admin --quiet << 'MONGO_EOF' 2>/dev/null || true
use praktikum
db.employees.deleteMany({})
db.employees.insertMany([
  {id:1, name:"Andi", dept:"IT", salary:5000000},
  {id:2, name:"Budi", dept:"HR", salary:4500000},
  {id:3, name:"Citra", dept:"Finance", salary:4800000},
  {id:4, name:"Doni", dept:"IT", salary:5200000},
  {id:5, name:"Eka", dept:"HR", salary:4700000}
])
console.log("✓ MongoDB data inserted")
db.employees.find().forEach(doc => print(JSON.stringify(doc, null, 2)))
MONGO_EOF

echo ""
docker exec cassandra cqlsh << 'CASSANDRA_EOF' 2>/dev/null || true
CREATE KEYSPACE IF NOT EXISTS praktikum WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
USE praktikum;
CREATE TABLE IF NOT EXISTS employees (id text PRIMARY KEY, name text, dept text, salary decimal);
TRUNCATE employees;
INSERT INTO employees VALUES ('1', 'Andi', 'IT', 5000000);
INSERT INTO employees VALUES ('2', 'Budi', 'HR', 4500000);
INSERT INTO employees VALUES ('3', 'Citra', 'Finance', 4800000);
INSERT INTO employees VALUES ('4', 'Doni', 'IT', 5200000);
INSERT INTO employees VALUES ('5', 'Eka', 'HR', 4700000);
SELECT * FROM employees;
CASSANDRA_EOF

echo ""
echo "╔════════════════════════════════════════╗"
echo "║  ✓ SEMUA READY!                       ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "🌐 HDFS WebUI:    http://localhost:9870"
echo "💾 MongoDB:       mongodb://admin:admin123@localhost:27017"
echo "📊 Cassandra:     localhost:9042"
echo ""
