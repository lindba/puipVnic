#!/usr/bin/env -S bash
# /opt/puipVnic/puipVnic.sh
mkdir /opt/puipVnic; cd /opt/puipVnic;
ns=$(hostname);
puip=$(oci-public-ip -g) ; [[ $? == 1 ]] && puip=$(curl --insecure  https://ipinfo.io/ip);
gw=$(echo $puip | cut -d. -f1,2,3).1;
instIfc=$(grep  '^en' /proc/net/dev | head -1 | cut -d: -f1);
instIp=$(ip addr show dev enp0s3 | grep 'inet ' | tr -s ' ' | cut -d ' ' -f3);
nscMac=$(ip link show dev $instIfc | grep ether | tr -s ' ' | cut -d' ' -f3);
cat > ns_$ns.cfg <<!
ip=$puip
pfx=24
gw=$gw
nscMac=$nscMac
nsh=nsh$ns
nsc=${instIfc}1
brns=brns
instIfc=$instIfc
instIp=$instIp
!
curl -O https://raw.githubusercontent.com/lindba/scripts/master/ns/ns.sh; chmod +x ns.sh;
curl -O https://raw.githubusercontent.com/lindba/puipVnic/main/puipVnic.service; sed -i -e s/hostname/$(hostname)/g puipVnic.service; mv puipVnic.service /lib/systemd/system/; systemctl enable puipVnic;


<<cloudInit
  curl -O https://raw.githubusercontent.com/lindba/puipVnic/main/puipVnic.sh; chmod +x puipVnic.sh; ./puipVnic.sh
cloudInit


