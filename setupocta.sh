#!/bin/bash

set -e  # stop kalau ada error

echo "=== CHECK ROOT ==="
if [ "$EUID" -ne 0 ]; then
  echo "Harus dijalankan sebagai root!"
  exit 1
fi

echo "=== UPDATE APT ==="
apt update

echo "=== INSTALL DEPENDENCY DASAR ==="
apt install -y software-properties-common wget ca-certificates build-essential
apt install -y --no-install-recommends libgl1 libglx-mesa0 libegl1 libglib2.0-0
ldconfig
ldconfig -p | grep -E 'libGL\.so\.1|libGLX\.so|libEGL\.so'
ls -l /usr/lib/x86_64-linux-gnu/libGL.so.1*
update-ca-certificates

echo "=== DOWNLOAD MINICONDA ==="
wget https://repo.anaconda.com/miniconda/Miniconda3-py313_26.1.1-1-Linux-x86_64.sh -O miniconda.sh

echo "=== INSTALL MINICONDA ==="
bash miniconda.sh -b -p /root/miniconda3

echo "=== LOAD CONDA ==="
source /root/miniconda3/etc/profile.d/conda.sh

echo "=== ACCEPT TOS ANACONDA ==="
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

echo "=== ADD DEADSNAKES PPA ==="
add-apt-repository -y ppa:deadsnakes/ppa

echo "=== UPDATE APT (SETELAH PPA) ==="
apt update

echo "=== INSTALL PYTHON 3.11 ==="
apt install -y python3.11 python3.11-venv python3.11-dev

echo "=== DONE ==="
echo "Coba cek: conda --version && python3.11 --version"