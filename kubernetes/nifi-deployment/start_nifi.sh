#!/bin/sh

set -e

#HOSTNAME=10.47.240.19
do_site2site_configure() {

  sed -i "s/nifi\.web\.http\.port=8080/nifi.web.http.port=80/g" ${NIFI_HOME}/conf/nifi.properties
  #sed -i "s/nifi\.web\.https\.port=.*/nifi.web.https.port=${NIFI_WEB_HTTP_PORT:-8443}/g" ${NIFI_HOME}/conf/nifi.properties
  #sed -i "s/nifi\.remote\.input\.http\.enabled=true/nifi.remote.input.http.enabled=false/g" ${NIFI_HOME}/conf/nifi.properties

  #sed -i "s/nifi\.remote\.input\.host=.*/nifi.remote.input.host=${HOSTNAME}/g" ${NIFI_HOME}/conf/nifi.properties
  #sed -i "s/nifi\.remote\.input\.socket\.port=.*/nifi.remote.input.socket.port=${S2S_PORT:-2881}/g" ${NIFI_HOME}/conf/nifi.properties
  #sed -i "s/nifi\.remote\.input\.secure=false/nifi.remote.input.secure=true/g" ${NIFI_HOME}/conf/nifi.properties
  #sed -i "s/nifi\.web\.http\.host=.*/nifi.web.http.host=${MY_ID}/g" ${NIFI_HOME}/conf/nifi.properties
}

do_authentication_configure() {
  #sed -i -e 's|<property name="Initial User Identity 1"></property>|<property name="Initial User Identity 1">'"${LDAP_MANAGER_DN}"'</property>|'  ${NIFI_HOME}/conf/authorizers.xml
  sed -i -e 's|<property name="Initial Admin Identity"></property>|<property name="Initial Admin Identity">'"${LDAP_MANAGER_DN}"'</property>|'  ${NIFI_HOME}/conf/authorizers.xml
  mkdir -p /opt/nifi/certs
  echo "begin generate certs"
  cd /opt/nifi/certs && /opt/nifi/nifi-toolkit-1.7.1/bin/tls-toolkit.sh client -t ${tls_token} -c nifi-ca
  echo "end generate certs"
  NIFI_KEYSTORE_PASSWORD=$(cat /opt/nifi/certs/config.json | jq -r .keyStorePassword)
  NIFI_TRUSTSTORE_PASSWORD=$(cat /opt/nifi/certs/config.json | jq -r .trustStorePassword)
  echo "begin sed 1"
  sed -i "s/nifi\.security\.keystore=.*/nifi.security.keystore=\/opt\/nifi\/certs\/keystore.jks/g" ${NIFI_HOME}/conf/nifi.properties
  sed -i "s/nifi\.security\.keystoreType=.*/nifi.security.keystoreType=${NIFI_KEYSTORE_TYPE}/g" ${NIFI_HOME}/conf/nifi.properties
  echo "begin NIFI_KEYSTORE_PASSWORD"
  echo ${NIFI_KEYSTORE_PASSWORD}
  echo "============1"
  echo ${NIFI_TRUSTSTORE_PASSWORD}
  echo "============2"
  sed -i "s?nifi\.security\.keystorePasswd=.*?nifi.security.keystorePasswd=${NIFI_KEYSTORE_PASSWORD}?g" ${NIFI_HOME}/conf/nifi.properties
  echo "end NIFI_KEYSTORE_PASSWORD"
  sed -i "s?nifi\.security\.keyPasswd=.*?nifi.security.keyPasswd=${NIFI_KEYSTORE_PASSWORD}?g" ${NIFI_HOME}/conf/nifi.properties
  sed -i "s/nifi\.security\.truststore=.*/nifi.security.truststore=\/opt\/nifi\/certs\/truststore.jks/g" ${NIFI_HOME}/conf/nifi.properties
  sed -i "s/nifi\.security\.truststoreType=.*/nifi.security.truststoreType=${NIFI_TRUSTSTORE_TYPE}/g" ${NIFI_HOME}/conf/nifi.properties
  sed -i "s?nifi\.security\.truststorePasswd=.*?nifi.security.truststorePasswd=${NIFI_TRUSTSTORE_PASSWORD}?g" ${NIFI_HOME}/conf/nifi.properties
  sed -i "s/nifi\.security\.needClientAuth=.*/nifi.security.needClientAuth=false/g" ${NIFI_HOME}/conf/nifi.properties
  #sed -i "s/nifi\.web\.proxy\.host=.*/nifi.web.proxy.host=35.225.252.114:8443/g" ${NIFI_HOME}/conf/nifi.properties

  echo "============3"
  sed -i "s/nifi\.security\.user\.authorizer=.*/nifi.security.user.authorizer=file-provider/g" ${NIFI_HOME}/conf/nifi.properties
  sed -i "s/nifi\.security\.user\.login\.identity\.provider=.*/nifi.security.user.login.identity.provider=ldap-provider/g" ${NIFI_HOME}/conf/nifi.properties
  echo "============4"


}

do_cluster_node_configure() {
  echo "begin do_cluster_node_configure"
  MY_IP=$(getent hosts $(hostname) | awk '{print $1}')
  sed -i "s/nifi\.web\.http\.host=.*/nifi.web.http.host=${MY_IP}/g" ${NIFI_HOME}/conf/nifi.properties
  #sed -i "s/nifi\.web\.https\.host=.*/nifi.web.https.host=${MY_IP}/g" ${NIFI_HOME}/conf/nifi.properties

  ZK_NODES=$(echo ${ZK_NODES_LIST} | sed -e "s/\s/,/g" -e "s/\(,\)*/\1/g")

  sed -i "s/clientPort=.*/clientPort=${ZK_CLIENT_PORT:-2181}/g" ${NIFI_HOME}/conf/zookeeper.properties
  ZK_CONNECT_STRING=$(echo $ZK_NODES | sed -e "s/,/:${ZK_CLIENT_PORT:-2181},/g" -e "s/$/:${ZK_CLIENT_PORT:-2181}/g")

  sed -i "s/nifi\.cluster\.protocol\.is\.secure=false/nifi.cluster.protocol.is.secure=false/g" ${NIFI_HOME}/conf/nifi.properties
  sed -i "s/nifi\.cluster\.is\.node=false/nifi.cluster.is.node=true/g" ${NIFI_HOME}/conf/nifi.properties
  sed -i "s/nifi\.cluster\.node\.address=.*/nifi.cluster.node.address=${MY_IP}/g" ${NIFI_HOME}/conf/nifi.properties

  if [ -z "$ELECTION_TIME" ]; then ELECTION_TIME="5 mins"; fi
  sed -i "s/nifi\.cluster\.flow\.election\.max\.wait\.time=.*/nifi.cluster.flow.election.max.wait.time=${ELECTION_TIME}/g" ${NIFI_HOME}/conf/nifi.properties

  sed -i "s/nifi\.cluster\.node\.protocol\.port=.*/nifi.cluster.node.protocol.port=${NODE_PROTOCOL_PORT:-2882}/g" ${NIFI_HOME}/conf/nifi.properties
  sed -i "s/nifi\.zookeeper\.connect\.string=.*/nifi.zookeeper.connect.string=$ZK_CONNECT_STRING/g" ${NIFI_HOME}/conf/nifi.properties

  if [ -z "$ZK_ROOT_NODE" ]; then ZK_ROOT_NODE="nifi"; fi
  sed -i "s/nifi\.zookeeper\.root\.node=.*/nifi.zookeeper.root.node=\/$ZK_ROOT_NODE/g" ${NIFI_HOME}/conf/nifi.properties
  sed -i "s/<property name=\"Connect String\">.*</<property name=\"Connect String\">$ZK_CONNECT_STRING</g" ${NIFI_HOME}/conf/state-management.xml

  if [ ! -z "$ZK_MYID" ]; then
    sed -i "s/nifi\.state\.management\.embedded\.zookeeper\.start=false/nifi.state.management.embedded.zookeeper.start=true/g" ${NIFI_HOME}/conf/nifi.properties
    mkdir -p ${NIFI_HOME}/state/zookeeper
    echo ${ZK_MYID} > ${NIFI_HOME}/state/ls/myid
  fi

  sed -i "/^server\./,$ d" ${NIFI_HOME}/conf/zookeeper.properties
  srv=1; IFS=","; for node in $ZK_NODES; do sed -i "\$aserver.$srv=$node:${ZK_MONITOR_PORT:-2888}:${ZK_ELECTION_PORT:-3888}" ${NIFI_HOME}/conf/zookeeper.properties; let "srv+=1"; done
}

#sh ${NIFI_HOME}/update_login_providers.sh
sed -i "s/nifi\.ui\.banner\.text=.*/nifi.ui.banner.text=${BANNER_TEXT}/g" ${NIFI_HOME}/conf/nifi.properties
do_site2site_configure

if [ ! -z "$IS_CLUSTER_NODE" ]; then do_cluster_node_configure; fi

#do_authentication_configure

tail -F ${NIFI_HOME}/logs/nifi-app.log &
${NIFI_HOME}/bin/nifi.sh run

