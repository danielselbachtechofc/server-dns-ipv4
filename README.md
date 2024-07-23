# DNS Server Setup Script

This script sets up a primary DNS server using BIND 9 on Debian 12. It configures the server to be both recursive and authoritative.

## Usage

1. Replace placeholders in `setup-dns-server.sh` with your actual server details:
   - `[YOUR_SERVER_IP]`
   - `[FORWARDER_1_IP]`, `[FORWARDER_2_IP]`
   - `[YOUR_DOMAIN]`
   - `[REVERSE_ZONE]`
   - `[SERIAL_NUMBER]`
   - `[LAST_OCTET]`


2. Clone the repository and navigate to the directory:

   ```bash
   git clone https://github.com/danielselbachtechofc/server-dns.git
   cd dns-server-setup


3. Make the script executable:
chmod +x setup-dns-server.sh


4. Run the script as root:
sudo ./setup-dns-server.sh


5. Verify the DNS server is working:
nslookup google.com 127.0.0.1
nslookup ns.[YOUR_DOMAIN] 127.0.0.1

Notes
Ensure your firewall settings allow DNS traffic on port 53.
Modify the zone files and configurations as necessary to suit your environment.
