#!/bin/bash

echo "=========================================="
echo "Cassandra Praktikum Test"
echo "=========================================="
echo ""

echo "Menunggu Cassandra siap..."
sleep 10

echo "Mengakses Cassandra CQL shell..."
docker exec -it cassandra cqlsh <<EOF
-- Create keyspace
CREATE KEYSPACE IF NOT EXISTS praktikum
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE praktikum;

-- Create table
CREATE TABLE IF NOT EXISTS mahasiswa (
  nim text PRIMARY KEY,
  nama text,
  jurusan text,
  ipk decimal,
  email text,
  phone text
);

-- Insert data
INSERT INTO mahasiswa (nim, nama, jurusan, ipk, email, phone)
VALUES ('12345', 'Andi Pratama', 'Informatika', 3.8, 'andi@univ.ac.id', '0812-xxxx-xxxx');

INSERT INTO mahasiswa (nim, nama, jurusan, ipk, email, phone)
VALUES ('12346', 'Budi Santoso', 'Sistem Informasi', 3.5, 'budi@univ.ac.id', '0813-xxxx-xxxx');

INSERT INTO mahasiswa (nim, nama, jurusan, ipk, email, phone)
VALUES ('12347', 'Citra Dewi', 'Teknik Komputer', 3.9, 'citra@univ.ac.id', '0814-xxxx-xxxx');

-- Select all data
SELECT * FROM mahasiswa;

-- Select dengan filter
SELECT * FROM mahasiswa WHERE jurusan = 'Informatika' ALLOW FILTERING;

-- Describe table
DESCRIBE TABLE mahasiswa;

EXIT;
EOF

echo ""
echo "✓ Cassandra test complete!"
