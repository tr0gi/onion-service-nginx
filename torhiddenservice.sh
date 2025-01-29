 
#!/bin/bash

sudo apt install php-fpm mysql-server php-mysql nginx tor

# Create web directory
sudo mkdir -p /var/www/onion
sudo chown -R www-data:www-data /var/www/onion

# Create nginx config
sudo tee /etc/nginx/sites-available/onion << 'EOF'
server {
    listen 127.0.0.1:8080;
    root /var/www/onion;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/onion /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Configure Tor
sudo tee -a /etc/tor/torrc << 'EOF'
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServicePort 80 127.0.0.1:8080
EOF

# Restart services
sudo systemctl restart tor nginx php8.1-fpm

# Get onion address
sudo cat /var/lib/tor/hidden_service/hostname