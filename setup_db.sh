#!/bin/bash
sudo service postgresql start
sudo service redis-server start
sleep 2

sudo -u postgres psql -c "CREATE USER attendance WITH PASSWORD 'attendance';" 2>&1 || true
sudo -u postgres psql -c "CREATE DATABASE qr_attendance OWNER attendance;" 2>&1 || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE qr_attendance TO attendance;" 2>&1 || true
sudo -u postgres psql -c "ALTER USER attendance CREATEDB;" 2>&1 || true

echo "DB_SETUP_DONE"
