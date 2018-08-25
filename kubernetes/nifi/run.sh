echo "Waiting to run nslookup..."
sleep 30
echo "$(getent hosts zk-0.zk-hs.nifi.svc.cluster.local) zk-0" >>  /tmphosts
echo "$(getent hosts zk-1.zk-hs.nifi.svc.cluster.local) zk-1" >>  /tmphosts
echo "$(getent hosts zk-2.zk-hs.nifi.svc.cluster.local) zk-2" >>  /tmphosts
echo "$(getent hosts nifi-0.nifi.nifi.svc.cluster.local) nifi-0" >>  /tmphosts
echo "$(getent hosts nifi-1.nifi.nifi.svc.cluster.local) nifi-1" >>  /tmphosts
echo "$(getent hosts nifi-2.nifi.nifi.svc.cluster.local) nifi-2" >>  /tmphosts

cat /tmphosts >> /etc/hosts
./start_nifi.sh

