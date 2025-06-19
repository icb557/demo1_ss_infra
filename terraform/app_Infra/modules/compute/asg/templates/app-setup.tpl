#!/bin/bash
set -e

# --- Variables ---
APP_DIR="/opt/flaskapp"
GIT_REPO="https://github.com/icb557/demo1_ss_app_flask.git"
GIT_BRANCH="main"
GUNICORN_WORKERS=4
GUNICORN_BIND="0.0.0.0:8000"

# --- Infra Playbook Steps ---

# Enable universe repository
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs) universe" -y

# Update apt cache
sudo apt-get update -y

# Install system dependencies
sudo apt-get install -y git python3 python3-pip gcc python3-venv

# Create app directory
sudo mkdir -p "$APP_DIR"
sudo chmod 755 "$APP_DIR"
sudo chown $(whoami):$(whoami) "$APP_DIR"

# --- App Playbook Steps ---

# Clone or update the app repo
if [ ! -d "$APP_DIR/.git" ]; then
  git clone -b "$GIT_BRANCH" "$GIT_REPO" "$APP_DIR"
else
  cd "$APP_DIR"
  git pull origin "$GIT_BRANCH"
fi

# Create .env file (replace values as needed)
cat > "$APP_DIR/.env" <<EOF
SECRET_KEY=devops

# AWS RDS Database
DB_USER=devops
DB_PASSWORD=devops123
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_NAME=demo1_db
TEST_DB_NAME=test_db
EOF

# Create virtual environment
python3 -m venv "$APP_DIR/venv"

# Install requirements
"$APP_DIR/venv/bin/pip" install --upgrade pip
"$APP_DIR/venv/bin/pip" install -r "$APP_DIR/requirements.txt"

# Initialize migrations if not exist
if [ ! -d "$APP_DIR/migrations" ]; then
  cd "$APP_DIR"
  "$APP_DIR/venv/bin/flask" db init
fi

# Run flask db migrate and upgrade
cd "$APP_DIR"
"$APP_DIR/venv/bin/flask" db migrate -m "Auto migration" || true
"$APP_DIR/venv/bin/flask" db upgrade

# Install Gunicorn
"$APP_DIR/venv/bin/pip" install gunicorn

# Create logs directory
sudo mkdir -p "$APP_DIR/logs"
sudo chmod 755 "$APP_DIR/logs"
sudo chown $(whoami):$(whoami) "$APP_DIR/logs"

# Create Gunicorn config
cat > "$APP_DIR/gunicorn_config.py" <<EOF
workers = $GUNICORN_WORKERS
bind = "$GUNICORN_BIND"
worker_class = 'sync'
accesslog = "$APP_DIR/logs/access.log"
errorlog = "$APP_DIR/logs/error.log"
EOF

# Run Gunicorn in background
nohup "$APP_DIR/venv/bin/gunicorn" --config "$APP_DIR/gunicorn_config.py" 'app:create_app()' > /dev/null 2>&1 &

# Optionally, check app status (not required for user data, but for debugging)
sleep 5
curl -f "http://$GUNICORN_BIND" || echo "App did not respond on $GUNICORN_BIND"