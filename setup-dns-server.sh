#!/bin/bash

echo "[+] Checking for root permissions"
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root"
    exit 1
fi

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
    listen-on { 127.0.0.1; [YOUR_SERVER_IP]; };
    listen-on-v6 { any; };

    forwarders {
        [FORWARDER_1_IP];
        [FORWARDER_2_IP];
    };
};
EOF

# Configure named.conf.local
cat > /etc/bind/named.conf.local <<EOF
zone "[YOUR_DOMAIN]" {
    type master;
    file "/etc/bind/db.[YOUR_DOMAIN]";
};

zone "[REVERSE_ZONE].in-addr.arpa" {
    type master;
    file "/etc/bind/db.[REVERSE_ZONE]";
};
EOF

# Create the forward zone file
cat > /etc/bind/db.[YOUR_DOMAIN] <<EOF
\$TTL    604800
@       IN      SOA     ns.[YOUR_DOMAIN]. admin.[YOUR_DOMAIN]. (
                          [SERIAL_NUMBER]   ; Serial
                          604800            ; Refresh
                          86400             ; Retry
                          2419200           ; Expire
                          604800 )          ; Negative Cache TTL
;
@       IN      NS      ns.[YOUR_DOMAIN].
@       IN      A       [YOUR_SERVER_IP]
ns      IN      A       [YOUR_SERVER_IP]
EOF

# Create the reverse zone file
cat > /etc/bind/db.[REVERSE_ZONE] <<EOF
\$TTL    604800
@       IN      SOA     ns.[YOUR_DOMAIN]. admin.[YOUR_DOMAIN]. (
                          [SERIAL_NUMBER]   ; Serial
                          604800            ; Refresh
                          86400             ; Retry
                          2419200           ; Expire
                          604800 )          ; Negative Cache TTL
;
@       IN      NS      ns.[YOUR_DOMAIN].
[LAST_OCTET]   IN      PTR     [YOUR_DOMAIN].
EOF

# Set permissions
chown bind:bind /etc/bind/db.[YOUR_DOMAIN]
chmod 644 /etc/bind/db.[YOUR_DOMAIN]

chown bind:bind /etc/bind/db.[REVERSE_ZONE]
chmod 644 /etc/bind/db.[REVERSE_ZONE]

echo "[+] Checking BIND configuration"
named-checkconf

echo "[+] Checking forward zone file"
named-checkzone [YOUR_DOMAIN] /etc/bind/db.[YOUR_DOMAIN]

echo "[+] Checking reverse zone file"
named-checkzone [REVERSE_ZONE].in-addr.arpa /etc/bind/db.[REVERSE_ZONE]

echo "[+] Restarting BIND service"
systemctl restart bind9
systemctl enable bind9

echo "###################################################################"
echo "## DNS Server configuration complete.                            ##"
echo "## Ensure you adjust your firewall settings to allow DNS traffic. ##"
echo "## Test your DNS server with tools like dig or nslookup.          ##"
echo "###################################################################"
