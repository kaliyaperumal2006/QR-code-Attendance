#!/bin/bash
WSL_IP=$(hostname -I | awk '{print $1}')
echo "WSL IP: $WSL_IP"

# Allow PostgreSQL to accept connections from any address
PG_CONF=$(sudo -u postgres psql -t -c "SHOW config_file;" | tr -d ' ')
PG_HBA=$(sudo -u postgres psql -t -c "SHOW hba_file;" | tr -d ' ')

echo "PG config: $PG_CONF"
echo "PG HBA: $PG_HBA"

# Update postgresql.conf to listen on all interfaces
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $PG_CONF
sudo sed -i "s/listen_addresses = 'localhost'/listen_addresses = '*'/" $PG_CONF

# Add host entry to pg_hba.conf for Windows host
echo "host    all             attendance      0.0.0.0/0               md5" | sudo tee -a $PG_HBA

# Update redis to bind all interfaces
sudo sed -i "s/^bind 127.0.0.1 -::1/bind 0.0.0.0/" /etc/redis/redis.conf 2>/dev/null || true
sudo sed -i "s/^bind 127.0.0.1$/bind 0.0.0.0/" /etc/redis/redis.conf 2>/dev/null || true

# Restart services
sudo service postgresql restart
sudo service redis-server restart
sleep 2

echo "WSL_IP=$WSL_IP"
echo "NETWORK_DONE"
