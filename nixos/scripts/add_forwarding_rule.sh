iptables -I FORWARD -s 192.168.122.0/24 -j ACCEPT
iptables -I FORWARD -d 192.168.122.0/24 -j ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.122.0/24 ! -d 192.168.122.0/24 -j MASQUERADE
