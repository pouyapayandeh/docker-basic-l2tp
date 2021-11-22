#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

export PATH

[ -z "${PUBLIC_IP}" ] && PUBLIC_IP=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
[ -z "${PUBLIC_IP}" ] && PUBLIC_IP=$( wget -qO- -t1 -T2 ipinfo.io/ip )


# enable IP forwarding
sysctl -eqw net.ipv4.ip_forward=1

# configure firewall
iptables -t nat -A POSTROUTING -s 10.99.99.0/24 ! -d 10.99.99.0/24 -j MASQUERADE
iptables -A FORWARD -s 10.99.99.0/24 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1356
iptables -A INPUT -i ppp+ -j ACCEPT
iptables -A OUTPUT -o ppp+ -j ACCEPT
iptables -A FORWARD -i ppp+ -j ACCEPT
iptables -A FORWARD -o ppp+ -j ACCEPT
iptables -I FORWARD -s 192.168.1.0/24 -j ACCEPT

rand(){
    str=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
    echo ${str}
}

VPN_USER="vpnuser"
VPN_PASSWORD="$(rand)"

if ! grep -qw "${VPN_USER}" /etc/ppp/chap-secrets 2>/dev/null; then
    cat > /etc/ppp/chap-secrets <<EOF
${VPN_USER} l2tpd ${VPN_PASSWORD} *
EOF
fi

chmod 600 /etc/ppp/chap-secrets




cat <<EOF
L2TP VPN Server with the Username and Password is below:
Server IP: ${PUBLIC_IP}
Username : ${VPN_USER}
Password : ${VPN_PASSWORD}
EOF

exec /usr/sbin/xl2tpd -D -c /etc/xl2tpd/xl2tpd.conf