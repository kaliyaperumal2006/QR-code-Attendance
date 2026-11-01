#!/bin/bash
set -e

echo "=== Fixing Redis bind ==="
# Show current bind setting
grep "^bind" /etc/redis/redis.conf || echo "No bind line found"

# Fix redis bind to listen on all interfaces
sudo sed -i 's/^bind .*/bind 0.0.0.0/' /etc/redis/redis.conf
# Also disable protected mode so external connections work
sudo sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf

echo "=== Redis config after fix ==="
grep "^bind\|^protected-mode" /etc/redis/redis.conf

echo "=== Fixing pg_hba.conf ==="
PG_HBA=$(sudo -u postgres psql -t -c "SHOW hba_file;" | tr -d ' \n')
echo "HBA file: $PG_HBA"
cat $PG_HBA

# Add the scram-sha-256 host entry at top of host entries
echo "host    all             attendance      0.0.0.0/0               scram-sha-256" | sudo tee -a $PG_HBA

echo "=== Restarting services ==="
sudo service postgresql restart
sudo service redis-server restart
sleep 3

echo "=== Checking ports ==="
ss -tlnp | grep -E "5432|6379"

echo "ALL_FIXED"
