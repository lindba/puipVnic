#!/bin/bash

# /opt/puipVnic/puipVnic.sh
systemctl stop firewalld; systemctl disable firewalld;
mkdir /opt/puipVnic; cd /opt/puipVnic;
ns=$(hostname);
puip=$(oci-public-ip -g) ; [[ $? == 1 ]] && puip=$(curl --insecure  https://ipinfo.io/ip);
gw=$(echo $puip | cut -d. -f1,2,3).1;
instIfc=$(grep  'en' /proc/net/dev | head -1 | cut -d: -f1|sed -e "s/ //g");
instIp=$(ip addr show | grep 'inet ' | tr -s ' ' | cut -d ' ' -f3 | grep -v 127|head -1|cut -d/ -f1);
nscMac=$(ip link show dev $instIfc | grep ether | tr -s ' ' | cut -d' ' -f3);
cat > ns_$ns.cfg <<!
ip=$(echo $puip|sed -e "s/ //g")
pfx=24
gw=$gw
nscMac=$nscMac
nsh=nsh0
nsc=${instIfc}1
brns=brns
instIfc=$instIfc
instIp=$instIp
!
curl -O https://raw.githubusercontent.com/lindba/scripts/master/ns/ns.sh; chmod +x ns.sh;
curl -O https://raw.githubusercontent.com/lindba/puipVnic/main/puipVnic.service; sed -i -e s/hostname/$(hostname)/g puipVnic.service; mv puipVnic.service /lib/systemd/system/; for act in start enable; do systemctl $act puipVnic; done;
