#!/bin/bash
set -e

ENVIRONMENT=$1
APP_DIR="/opt/flask-app"
SERVICE_NAME="flaskapp"

echo "Desplegando aplicación Flask en ambiente: $ENVIRONMENT"

sudo systemctl stop $SERVICE_NAME || true

# Backup de la versión anterior
if [ -d "$APP_DIR" ]; then
    sudo cp -r $APP_DIR ${APP_DIR}_backup_$(date +%Y%m%d_%H%M%S)
fi

# Copiar nueva versión
sudo rm -rf $APP_DIR
sudo mkdir -p $APP_DIR
sudo cp -r /tmp/flask-app/* $APP_DIR/
sudo chown -R flaskapp:flaskapp $APP_DIR

cd $APP_DIR
sudo -u flaskapp python3 -m venv venv
sudo -u flaskapp venv/bin/pip install -r requirements.txt

# Configurar variables de ambiente según el entorno
if [ "$ENVIRONMENT" = "production" ]; then
    sudo -u flaskapp cp config/production.env $APP_DIR/.env
else
    sudo -u flaskapp cp config/staging.env $APP_DIR/.env
fi

sudo systemctl start $SERVICE_NAME
sudo systemctl enable $SERVICE_NAME

echo "Deploy completado para $ENVIRONMENT"