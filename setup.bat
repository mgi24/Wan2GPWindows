@echo off
git clone https://github.com/deepbeepmeep/Wan2GP.git
cd Wan2GP
python -m venv .venv
call .venv\Scripts\activate.bat
pip install torch==2.10.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130
pip install -r requirements.txt
python wgp.py