#!/bin/bash

#########################################################################################
# DANIEL S. FIGUEIRÓ                                                                    #
# NETWORK SPECIALIST                                                                    #
# E-MAIL: danielselbach.fig@gmail.com                                                   #
# Script V.: 1.0 - BIND9                                                                #
#########################################################################################

echo "[+] Checking for root permissions"
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root"
    exit 1
fi

# Requesting information from the user
read -p "Enter your server IP: " SERVER_IP
read -p "Enter your domain (e.g., flashtech.local): " DOMAIN
read -p "Enter the reverse zone (e.g., 30.200.10): " REVERSE_ZONE
read -p "Enter the forwarder 1 IP: " FORWARDER_1_IP
read -p "Enter the forwarder 2 IP: " FORWARDER_2_IP
read -p "Enter the serial number (e.g., 2024072301): " SERIAL_NUMBER
read -p "Enter the last octet of the reverse IP: " LAST_OCTET

echo "[+] Updating package lists"
apt-get update

echo "[+] Installing BIND 9"
apt-get install -y bind9 bind9utils bind9-doc

echo "[+] Configuring BIND 9"
# Backup original configuration files
cp /etc/bind/named.conf /etc/bind/named.conf.bak
cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bak
cp /etc/bind/named.conf.options /etc/bind/named.conf.options.bak

# Configure named.conf.options
cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";

    recursion yes; # Enable recursion
    allow-recursion { any; }; # Allow recursion from any client

    dnssec-validation no; # Disable DNSSEC validation

    auth-nxdomain no; # Disable authoritative responses for non-existent domains
    listen-on { 127.0.0.1; $SERVER_IP; };
    listen-on-v6 { any; };

    forwarders {
        $FORWARDER_1_IP;
        $FORWARDER_2_IP;
    };
};
EOF

# Configure named.conf.local
cat > /etc/bind/named.conf.local <<EOF
zone "$DOMAIN" {
    type master;
    file "/etc/bind/db.$DOMAIN";
};

zone "$REVERSE_ZONE.in-addr.arpa" {
    type master;
    file "/etc/bind/db.$REVERSE_ZONE";
};
EOF

# Create the forward zone file
cat > /etc/bind/db.$DOMAIN <<EOF
\$TTL    604800
@       IN      SOA     ns.$DOMAIN. admin.$DOMAIN. (
                          $SERIAL_NUMBER   ; Serial
                          604800            ; Refresh
                          86400             ; Retry
                          2419200           ; Expire
                          604800 )          ; Negative Cache TTL
;
@       IN      NS      ns.$DOMAIN.
@       IN      A       $SERVER_IP
ns      IN      A       $SERVER_IP
EOF

# Create the reverse zone file
cat > /etc/bind/db.$REVERSE_ZONE <<EOF
\$TTL    604800
@       IN      SOA     ns.$DOMAIN. admin.$DOMAIN. (
                          $SERIAL_NUMBER   ; Serial
                          604800            ; Refresh
                          86400             ; Retry
                          2419200           ; Expire
                          604800 )          ; Negative Cache TTL
;
@       IN      NS      ns.$DOMAIN.
$LAST_OCTET   IN      PTR     $DOMAIN.
EOF

# Set permissions
chown bind:bind /etc/bind/db.$DOMAIN
chmod 644 /etc/bind/db.$DOMAIN

chown bind:bind /etc/bind/db.$REVERSE_ZONE
chmod 644 /etc/bind/db.$REVERSE_ZONE

echo "[+] Checking BIND configuration"
named-checkconf

echo "[+] Checking forward zone file"
named-checkzone $DOMAIN /etc/bind/db.$DOMAIN

echo "[+] Checking reverse zone file"
named-checkzone $REVERSE_ZONE.in-addr.arpa /etc/bind/db.$REVERSE_ZONE

echo "[+] Restarting BIND service"
systemctl restart bind9
systemctl enable bind9

echo "###################################################################"
echo "## DNS Server configuration complete.                            ##"
echo "## Ensure you adjust your firewall settings to allow DNS traffic. ##"
echo "## Test your DNS server with tools like dig or nslookup.          ##"
echo "###################################################################"
