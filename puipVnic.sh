#!/usr/bin/env -S bash
# /opt/puipVnic/puipVnic.sh
cd /opt/puipVnic;
ns=$(hostname);
puip=$(oci-public-ip -g) ; [[ $? == 1 ]] && puip=$(curl --insecure  https://ipinfo.io/ip);
gw=$(echo 192.168.41.2 | cut -d. -f1,2,3).1;
instIfc=$(grep  '^en' /proc/net/dev | head -1 | cut -d: -f1);
nscMac=$(ip link show dev $instIfc | grep ether | tr -s ' ' | cut -d' ' -f3);
cat > ns_$ns.cfg <<!
ip=$puip
pfx=24
gw=$gw
nscMac=$nscMac
nsh=nsh$ns
nsc=$instIfc
brns=brns
instIfc=$instIfc
!
curl -O https://github.com/lindba/scripts/blob/master/ns/ns.sh; chmod +x ns.sh;
curl -O https://github.com/lindba/puipVnic/blob/main/puipVnic.service; mv puipVnic.service /lib/systemd/system/; systemd enable puipVnic;


