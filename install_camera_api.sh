#!/bin/bash
# install_camera_api.sh

# Usage: ./install_camera_api.sh [username]
USER_NAME="${1:-$(whoami)}"

# Get working directory
WORKING_DIR="$(pwd)"

# Install Python virtual environment
python3 -m venv --system-site-packages $WORKING_DIR/camera_api_venv
source $WORKING_DIR/camera_api_venv/bin/activate
pip install -r $WORKING_DIR/dependencies.txt

cd $WORKING_DIR

# Create the systemd service file with the specified user and working directory
SERVICE_FILE_CONTENT="[Unit]
Description=Camera API Service
After=network.target

[Service]
User=$USER_NAME
WorkingDirectory=$WORKING_DIR
ExecStart=$WORKING_DIR/camera_api_venv/bin/uvicorn camera_api_service:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target"

echo "$SERVICE_FILE_CONTENT" | sudo tee /etc/systemd/system/camera_api.service > /dev/null


sudo systemctl daemon-reload
sudo systemctl enable camera_api.service
sudo systemctl start camera_api.service

echo "Camera API service installed and started for user $USER_NAME."
