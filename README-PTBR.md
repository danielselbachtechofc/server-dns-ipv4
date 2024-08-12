# Script de configuração do servidor DNS
Este script configura um servidor DNS primário usando BIND 9 no Debian 12. Ele configura o servidor para ser recursivo e autoritativo.

## Uso
Substitua os marcadores de posição em `setup-dns-server-ipv4.sh` pelos detalhes reais do seu servidor:

- `[IP_DO_SEU_SERVIDOR]`
- `[SEU_DOMÍNIO]`
- `[ZONA_REVERSA]`
- `[FORWARDER_1_IP]`
- `[FORWARDER_2_IP]`
- `[SERIAL_NUMBER]`
- `[ÚLTIMO_OCTETO]`
  
## Etapas:

1. Clone o repositório e navegue até o diretório:
`git clone https://github.com/danielselbachtechofc/server-dns-ipv4.git`
`cd server-dns-ipv4`

2. Torne o script executável:
`chmod +x setup-dns-server-ipv4.sh`

3. Execute o script como root:
`sudo ./setup-dns-server-ipv4.sh`

4. Verifique se o servidor DNS está funcionando:
`nslookup google.com 127.0.0.1`
`nslookup ns.[SEU_DOMÍNIO] 127.0.0.1`

Observações
Certifique-se de que suas configurações de firewall permitem tráfego DNS na porta 53.
Modifique os arquivos de zona e as configurações conforme necessário para se adequar ao seu ambiente.
