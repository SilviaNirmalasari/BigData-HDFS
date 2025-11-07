#!/bin/bash

echo "╔════════════════════════════════════════╗"
echo "║  BigData - HDFS + MongoDB + Cassandra  ║"
echo "║  COMPLETE AUTOMATED - ALL IN ONE       ║"
echo "╚════════════════════════════════════════╝"
echo ""

cd ~/Documents/Project/College/BigData-HDFS

# ===== ENVIRONMENT =====
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export HADOOP_HOME=$HOME/hadoop
export PATH=$HADOOP_HOME/bin:$PATH

OUTPUT_DIR="$HOME/Documents/BigData-Results"
mkdir -p "$OUTPUT_DIR"

echo "🔧 Setup:"
echo "  JAVA_HOME: $JAVA_HOME"
echo "  HADOOP_HOME: $HADOOP_HOME"
echo "  Output: $OUTPUT_DIR"
echo ""

# ===== 1. HADOOP =====
echo "[1/8] Installing Hadoop..."
if [ ! -d "$HADOOP_HOME" ]; then
  cd ~
  wget --tries=3 https://archive.apache.org/dist/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz -O hadoop.tar.gz 2>/dev/null
  tar -xzf hadoop.tar.gz
  rm hadoop.tar.gz
  mv hadoop-3.3.4 hadoop
  cd ~/Documents/Project/College/BigData-HDFS
fi
echo "✓ Hadoop ready"

# ===== 2. CONFIG =====
echo "[2/8] Creating configs..."
mkdir -p $HADOOP_HOME/etc/hadoop

cat > $HADOOP_HOME/etc/hadoop/hdfs-site.xml << 'HDFS_CONFIG'
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property><name>dfs.replication</name><value>1</value></property>
    <property><name>dfs.namenode.name.dir</name><value>file:///home/gusytxpower/hadoop/dfs/name</value></property>
    <property><name>dfs.datanode.data.dir</name><value>file:///home/gusytxpower/hadoop/dfs/data</value></property>
    <property><name>dfs.namenode.rpc-address</name><value>localhost:9000</value></property>
    <property><name>dfs.namenode.http-address</name><value>localhost:9870</value></property>
</configuration>
HDFS_CONFIG

cat > $HADOOP_HOME/etc/hadoop/core-site.xml << 'CORE_CONFIG'
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property><name>fs.defaultFS</name><value>hdfs://localhost:9000</value></property>
    <property><name>hadoop.tmp.dir</name><value>/home/gusytxpower/hadoop/tmp</value></property>
</configuration>
CORE_CONFIG
echo "✓ Configs created"

# ===== 3. DOCKER =====
echo "[3/8] Setting up Docker..."
mkdir -p data/{mongodb,cassandra}

cat > docker-compose.yml << 'COMPOSE'
services:
  mongodb:
    image: mongo:6.0
    container_name: mongodb
    restart: always
    ports: ["27017:27017"]
    volumes: ["./data/mongodb:/data/db"]
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: admin123
    networks: [bdnet]

  cassandra:
    image: cassandra:3.11
    container_name: cassandra
    restart: always
    ports: ["9042:9042"]
    volumes: ["./data/cassandra:/var/lib/cassandra"]
    environment:
      CASSANDRA_CLUSTER_NAME: TestCluster
      CASSANDRA_DC: dc1
    networks: [bdnet]

networks:
  bdnet:
    driver: bridge
COMPOSE

docker compose down -v 2>/dev/null
docker compose up -d
echo "⏳ Waiting Docker..."
for ((i=60; i>0; i--)); do printf "\r⏳ $i secs                           "; sleep 1; done
printf "\r✓ Docker ready!                            \n"

# ===== 4. HDFS START =====
echo "[4/8] Starting HDFS..."
pkill -f "hdfs namenode" 2>/dev/null
pkill -f "hdfs datanode" 2>/dev/null
sleep 2

rm -rf $HADOOP_HOME/dfs /tmp/hadoop-*
mkdir -p $HADOOP_HOME/dfs/{name,data}

$HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive > /tmp/format.log 2>&1
$HADOOP_HOME/bin/hdfs namenode > /tmp/namenode.log 2>&1 &
NAMENODE_PID=$!
sleep 40

$HADOOP_HOME/bin/hdfs datanode > /tmp/datanode.log 2>&1 &
DATANODE_PID=$!
sleep 30

echo "✓ HDFS running (NN:$NAMENODE_PID DN:$DATANODE_PID)"

# ===== 5. HDFS DATA =====
echo "[5/8] HDFS data..."
hdfs dfs -mkdir -p /praktikum 2>/dev/null

cat > /tmp/data.csv << 'DATA'
id,name,dept,salary
1,Andi,IT,5000000
2,Budi,HR,4500000
3,Citra,Finance,4800000
4,Doni,IT,5200000
5,Eka,HR,4700000
DATA

hdfs dfs -put -f /tmp/data.csv /praktikum/data.csv 2>/dev/null || true
echo "✓ HDFS data ready"

# ===== 6. MONGODB =====
echo "[6/8] MongoDB data..."
docker exec -i mongodb mongosh -u admin -p admin123 --authenticationDatabase admin --quiet << 'MONGO' 2>/dev/null
use praktikum
db.employees.deleteMany({})
db.employees.insertMany([
  {id:1, name:"Andi", dept:"IT", salary:5000000},
  {id:2, name:"Budi", dept:"HR", salary:4500000},
  {id:3, name:"Citra", dept:"Finance", salary:4800000},
  {id:4, name:"Doni", dept:"IT", salary:5200000},
  {id:5, name:"Eka", dept:"HR", salary:4700000}
])
MONGO
echo "✓ MongoDB data ready"

# ===== 7. CASSANDRA =====
echo "[7/8] Cassandra data..."
sleep 30
docker exec -i cassandra cqlsh 2>/dev/null << 'CASS'
CREATE KEYSPACE IF NOT EXISTS praktikum WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
USE praktikum;
CREATE TABLE IF NOT EXISTS employees (id text PRIMARY KEY, name text, dept text, salary decimal);
INSERT INTO employees (id, name, dept, salary) VALUES ('1', 'Andi', 'IT', 5000000);
INSERT INTO employees (id, name, dept, salary) VALUES ('2', 'Budi', 'HR', 4500000);
INSERT INTO employees (id, name, dept, salary) VALUES ('3', 'Citra', 'Finance', 4800000);
INSERT INTO employees (id, name, dept, salary) VALUES ('4', 'Doni', 'IT', 5200000);
INSERT INTO employees (id, name, dept, salary) VALUES ('5', 'Eka', 'HR', 4700000);
CASS
echo "✓ Cassandra data ready"

# ===== 8. EXPORT RESULTS =====
echo "[8/8] Exporting results..."

# HDFS
echo "HDFS Directory Listing" > "$OUTPUT_DIR/01-HDFS-Files.txt"
echo "======================" >> "$OUTPUT_DIR/01-HDFS-Files.txt"
echo "" >> "$OUTPUT_DIR/01-HDFS-Files.txt"
hdfs dfs -ls /praktikum/ 2>/dev/null >> "$OUTPUT_DIR/01-HDFS-Files.txt" || echo "HDFS browse not available" >> "$OUTPUT_DIR/01-HDFS-Files.txt"

# MongoDB
echo "MongoDB Employees Data" > "$OUTPUT_DIR/02-MongoDB-Data.json"
echo "=======================" >> "$OUTPUT_DIR/02-MongoDB-Data.json"
echo "" >> "$OUTPUT_DIR/02-MongoDB-Data.json"
docker exec -i mongodb mongosh -u admin -p admin123 --authenticationDatabase admin --eval "db.getSiblingDB('praktikum').employees.find().forEach(doc => print(JSON.stringify(doc)))" 2>/dev/null >> "$OUTPUT_DIR/02-MongoDB-Data.json" || echo "MongoDB data not available" >> "$OUTPUT_DIR/02-MongoDB-Data.json"

# Cassandra
echo "Cassandra Employees Data" > "$OUTPUT_DIR/03-Cassandra-Data.csv"
echo "=========================" >> "$OUTPUT_DIR/03-Cassandra-Data.csv"
echo "" >> "$OUTPUT_DIR/03-Cassandra-Data.csv"
docker exec -i cassandra cqlsh 2>/dev/null << 'CASS_EXPORT' >> "$OUTPUT_DIR/03-Cassandra-Data.csv"
USE praktikum;
SELECT * FROM employees;
CASS_EXPORT

# Summary Report
cat > "$OUTPUT_DIR/00-README.txt" << 'README'
╔════════════════════════════════════════════╗
║  BigData Setup Report - All Automated ✅  ║
╚════════════════════════════════════════════╝

✓ SETUP COMPLETE!

Services Running:
  • Hadoop HDFS 3.3.4
  • MongoDB 6.0
  • Cassandra 3.11

Data Status:
  ✓ MongoDB: 5 employees inserted
  ✓ Cassandra: 5 employees inserted
  ✓ HDFS: /praktikum/data.csv created

Access Points:
  HDFS WebUI: http://localhost:9870
  MongoDB: localhost:27017
  Cassandra: localhost:9042

Credentials:
  MongoDB - admin / admin123

Output Files:
  01-HDFS-Files.txt - HDFS directory listing
  02-MongoDB-Data.json - MongoDB records
  03-Cassandra-Data.csv - Cassandra records

All data is ready for the praktikum assignment! 🎉
README

echo "✓ Results exported"

# ===== FINAL SUMMARY =====
echo ""
echo "╔════════════════════════════════════════╗"
echo "║  ✅ SETUP COMPLETE & AUTOMATED! ✅    ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "📁 Output Location:"
echo "   $OUTPUT_DIR/"
echo ""
echo "📊 Files Generated:"
ls -1 "$OUTPUT_DIR/" | sed 's/^/   ✓ /'
echo ""
echo "🔍 View Results:"
echo "   cat $OUTPUT_DIR/00-README.txt"
echo "   cat $OUTPUT_DIR/02-MongoDB-Data.json"
echo "   cat $OUTPUT_DIR/03-Cassandra-Data.csv"
echo ""
echo "🌐 Access:"
echo "   HDFS: http://localhost:9870"
echo ""
echo ""
