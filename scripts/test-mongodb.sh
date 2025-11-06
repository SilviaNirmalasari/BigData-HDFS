#!/bin/bash

echo "=========================================="
echo "MongoDB Praktikum Test"
echo "=========================================="
echo ""

echo "Mengakses MongoDB shell..."
docker exec -it mongodb mongosh -u admin -p admin123 --authenticationDatabase admin <<EOF
use praktikum

// Insert single document
db.mahasiswa.insertOne({
  nim: "12345",
  nama: "Andi Pratama",
  jurusan: "Informatika",
  ipk: 3.8,
  kontak: {
    email: "andi@univ.ac.id",
    phone: "0812-xxxx-xxxx"
  }
})

// Insert multiple documents
db.mahasiswa.insertMany([
  {
    nim: "12346",
    nama: "Budi Santoso",
    jurusan: "Sistem Informasi",
    ipk: 3.5,
    kontak: {
      email: "budi@univ.ac.id",
      phone: "0813-xxxx-xxxx"
    }
  },
  {
    nim: "12347",
    nama: "Citra Dewi",
    jurusan: "Teknik Komputer",
    ipk: 3.9,
    kontak: {
      email: "citra@univ.ac.id",
      phone: "0814-xxxx-xxxx"
    }
  }
])

// Tampilkan semua data
console.log("=== Semua Data Mahasiswa ===")
db.mahasiswa.find().pretty()

// Query dengan filter
console.log("\n=== Data Jurusan Informatika ===")
db.mahasiswa.find({ jurusan: "Informatika" }).pretty()

// Create index
db.mahasiswa.createIndex({ nim: 1 })
db.mahasiswa.createIndex({ jurusan: 1 })

// Tampilkan indexes
console.log("\n=== Indexes ===")
db.mahasiswa.getIndexes()

// Count documents
console.log("\n=== Jumlah Data: " + db.mahasiswa.countDocuments() + " ===")

exit
EOF

echo ""
echo "✓ MongoDB test complete!"
