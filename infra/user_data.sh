#!/bin/bash
# ---------- EC2 bootstrap ----------
yum -y update
yum -y install git python3-pip mysql

adduser appuser
su - appuser <<'EOF'
  # clone code
  git clone https://github.com/YOUR_USERNAME/Parking-Lot-Management-System.git app
  cd app/app

  # python deps
  python3 -m venv venv
  source venv/bin/activate
  pip install --upgrade pip
  pip install flask mysql-connector-python python-dotenv

  # create systemd service
  cat <<'SERVICE' | sudo tee /etc/systemd/system/parkinglot.service
  [Unit]
  Description=Parking-Lot Flask API
  After=network.target

  [Service]
  User=appuser
  WorkingDirectory=/home/appuser/app/app
  EnvironmentFile=/home/appuser/app/app/.env
  ExecStart=/home/appuser/app/app/venv/bin/python main.py
  Restart=always

  [Install]
  WantedBy=multi-user.target
SERVICE

  sudo systemctl daemon-reload
  sudo systemctl enable --now parkinglot
EOF
