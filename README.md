
# BigData - HDFS + MongoDB + Cassandra

Proyek praktikum Big Data dengan implementasi Hadoop HDFS, MongoDB, dan Apache Cassandra untuk manajemen data terdistribusi.
## 👨‍💻 Pengembang
- Silvia Nirmalasari
- NIM : 312310145
Proyek ini dibuat untuk keperluan praktikum mata kuliah Big Data.

## 📋 Deskripsi

Sistem ini mengintegrasikan tiga teknologi Big Data:
- **Hadoop HDFS 3.3.4** - File system terdistribusi
- **MongoDB 6.0** - NoSQL database berbasis dokumen
- **Cassandra 3.11** - Database kolom terdistribusi

## 🚀 Cara Menjalankan

### Persyaratan
- Ubuntu/Zorin OS (atau distro berbasis Debian)
- Java 17 OpenJDK
- Docker & Docker Compose
- Minimal 2GB RAM tersedia

### Instalasi & Setup

cd ~/Documents/Project/College/BigData-HDFS
chmod +x run.sh
./run.sh

Script akan otomatis:
1. Download & install Hadoop 3.3.4
2. Konfigurasi HDFS
3. Start Docker containers (MongoDB & Cassandra)
4. Format & start HDFS NameNode & DataNode
5. Insert sample data ke semua database
6. Export hasil ke file

**Durasi:** ~3-4 menit (tergantung koneksi internet)

## 📊 Data Sample

Semua database berisi data **employees** dengan 5 records:

| ID | Name  | Department | Salary  |
|----|-------|------------|---------|
| 1  | Andi  | IT         | 5000000 |
| 2  | Budi  | HR         | 4500000 |
| 3  | Citra | Finance    | 4800000 |
| 4  | Doni  | IT         | 5200000 |
| 5  | Eka   | HR         | 4700000 |

## 🔗 Akses Services

| Service   | URL/Port                                      | Kredensial      |
|-----------|-----------------------------------------------|-----------------|
| HDFS WebUI| http://localhost:9870                         | -               |
| NameNode  | localhost:9000                                | -               |
| MongoDB   | mongodb://localhost:27017                     | admin/admin123  |
| Cassandra | localhost:9042                                | -               |

## 📁 Struktur Output

Setelah setup selesai, hasil akan tersimpan di `~/Documents/BigData-Results/`:
BigData-Results/
├── 00-README.txt # Laporan summary
├── 01-HDFS-Files.txt # Daftar file HDFS
├── 02-MongoDB-Data.json # Data MongoDB
└── 03-Cassandra-Data.csv # Data Cassandra


