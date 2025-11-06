#!/bin/bash

# Script untuk uninstall Docker Snap dan install Docker via APT di Zorin OS
# Run: chmod +x install-docker-apt.sh && ./install-docker-apt.sh

set -e  # Exit jika ada error

echo "=========================================="
echo "Docker Snap → APT Migration Script"
echo "=========================================="
echo ""

# 1. Stop dan remove Docker Snap
echo "[1/7] Menghapus Docker Snap..."
sudo snap remove docker || echo "Docker Snap tidak terinstall atau sudah terhapus"

# 2. Clean up snap docker folder
echo "[2/7] Membersihkan folder snap docker..."
sudo rm -rf ~/snap/docker || echo "Folder snap docker tidak ditemukan"

# 3. Update sistem
echo "[3/7] Update package list..."
sudo apt update

# 4. Install dependencies
echo "[4/7] Install dependencies (curl, ca-certificates)..."
sudo apt-get install ca-certificates curl -y

# 5. Add Docker GPG key
echo "[5/7] Menambahkan Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 6. Add Docker repository
echo "[6/7] Menambahkan Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 7. Install Docker
echo "[7/7] Install Docker CE, CLI, dan plugins..."
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# 8. Add user ke docker group
echo ""
echo "=========================================="
echo "Post-Installation Setup"
echo "=========================================="
echo ""
echo "Menambahkan user ke docker group..."
sudo usermod -aG docker $USER

# 9. Informasi untuk user
echo ""
echo "=========================================="
echo "✓ Docker installation complete!"
echo "=========================================="
echo ""
echo "PENTING: Kamu perlu LOGOUT atau REBOOT agar changes berlaku"
echo ""
echo "Opsi 1: Logout dan login ulang"
echo "  $ exit"
echo ""
echo "Opsi 2: Reboot sistem"
echo "  $ sudo reboot"
echo ""
echo "Setelah itu, test dengan command:"
echo "  $ docker --version"
echo "  $ docker ps"
echo "  $ docker pull sequenceiq/hadoop-docker:2.7.0"
echo ""
