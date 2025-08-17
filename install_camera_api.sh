#!/bin/bash
# install_camera_api.sh
# Installs vilib (from source) and FastAPI dependencies for low-latency camera API

# Usage: ./install_camera_api.sh [username]
USER_NAME="${1:-$(whoami)}"

# Python3 related packages must be installed if you are installing the Lite version OS.
sudo apt install git python3-pip python3-setuptools python3-smbus

# Get working directory
WORKING_DIR="$(pwd)"

# Install vilib
cd ~/
git clone -b picamera2 https://github.com/sunfounder/vilib.git
cd vilib
python3 -m venv ~/camera_api_venv
source ~/camera_api_venv/bin/activate
sudo python3 install.py

cd $WORKING_DIR

# Install Python dependencies
pip3 install -r $WORKING_DIR/dependencies.txt

# Create the systemd service file with the specified user and working directory
cat <<EOF | sudo tee /etc/systemd/system/camera_api.service
[Unit]
Description=Camera API Service
After=network.target

[Service]
User=$USER_NAME
WorkingDirectory=$WORKING_DIR
ExecStart=/home/$USER_NAME/camera_api_venv/bin/uvicorn camera_api_service:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable camera_api.service
sudo systemctl start camera_api.service

echo "Camera API service installed and started for user $USER_NAME."
