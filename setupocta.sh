#!/bin/bash

set -e  # stop on error

echo "=== CHECK ROOT ==="
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root!"
  exit 1
fi

echo "=== UPDATE APT ==="
apt update
apt install -y software-properties-common wget ca-certificates build-essential


if dpkg -l libgl1 libglx-mesa0 libegl1 libglib2.0-0 2>/dev/null | grep -q "^ii"; then
  echo "Graphics libraries already installed, skipping."
else
  apt install -y --no-install-recommends libgl1 libglx-mesa0 libegl1 libglib2.0-0
fi

ldconfig -p | grep -E 'libGL\.so\.1|libGLX\.so|libEGL\.so' \
  || echo "NOTE: libGL/libGLX/libEGL not found in ldconfig cache (yet)"

ls -l /usr/lib/x86_64-linux-gnu/libGL.so.1* \
  || echo "NOTE: /usr/lib/x86_64-linux-gnu/libGL.so.1* not present"
update-ca-certificates

if command -v cloudflared &>/dev/null; then
  echo "Cloudflared already installed, skipping."
else
  mkdir -p --mode=0755 /usr/share/keyrings
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
  echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main' | tee /etc/apt/sources.list.d/cloudflared.list
  apt-get update && apt-get install -y cloudflared
fi


echo "INSTALLING CUDA TOOLKITS"

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.6.0/local_installers/cuda-repo-ubuntu2004-12-6-local_12.6.0-560.28.03-1_amd64.deb
dpkg -i cuda-repo-ubuntu2004-12-6-local_12.6.0-560.28.03-1_amd64.deb
cp /var/cuda-repo-ubuntu2004-12-6-local/cuda-*-keyring.gpg /usr/share/keyrings/
apt-get update
apt-get -y install cuda-toolkit-12-6

nvcc --version || echo "WARNING: nvcc not found"


if [ -d /root/miniconda3 ] && command -v /root/miniconda3/bin/conda &>/dev/null; then
  echo "Miniconda already installed at /root/miniconda3, skipping."
else
  echo "=== DOWNLOAD MINICONDA ==="
  wget https://repo.anaconda.com/miniconda/Miniconda3-py313_26.1.1-1-Linux-x86_64.sh -O miniconda.sh

  echo "=== INSTALL MINICONDA ==="
  bash miniconda.sh -b -p /root/miniconda3
fi

echo "=== LOAD CONDA ==="
source /root/miniconda3/etc/profile.d/conda.sh

echo "=== ACCEPT ANACONDA TOS ==="
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

if dpkg -l python3.11 python3.11-venv python3.11-dev 2>/dev/null | grep -q "^ii"; then
  echo "Python 3.11 already installed, skipping."
else
  echo "=== ADD DEADSNAKES PPA ==="
  add-apt-repository -y ppa:deadsnakes/ppa

  echo "=== UPDATE APT (AFTER PPA) ==="
  apt update

  echo "=== INSTALL PYTHON 3.11 ==="
  apt install -y python3.11 python3.11-venv python3.11-dev
fi

echo "=== DONE ==="
echo "Verification: conda --version && python3.11 --version"

