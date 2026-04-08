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

sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
sudo apt-get update && sudo apt-get install cloudflared

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
dpkg -i cuda-repo-ubuntu2204-13-2-local_13.2.0-595.45.04-1_amd64.deb
cp /var/cuda-repo-ubuntu2204-13-2-local/cuda-*-keyring.gpg /usr/share/keyrings/
apt update
apt install -y cuda-toolkit-13-2

export CUDA_HOME=/usr/local/cuda-13.2
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

nvcc --version

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

