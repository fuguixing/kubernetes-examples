#!/bin/bash -ex

# 1 - value to search for
# 2 - value to replace
prop_replace () {
  sed -i -e "s|^$1=.*$|$1=$2|"  ${nifi_props_file}
}

# NIFI_HOME is defined by an ENV command in the backing Dockerfile
nifi_props_file=${NIFI_HOME}/conf/nifi.properties

hostname=$(hostname)

prop_replace 'nifi.remote.input.host' "${hostname}"

if [ -n "${LDAP_AUTHENTICATION_STRATEGY}" ]; then
  . ${NIFI_BASE_DIR}/sh/update_login_providers.sh

  echo "Found that LDAP was set, updating properties for secure mode."
  sed -i -e 's|<property name="Initial Admin Identity"></property>|<property name="Initial Admin Identity">'"${LDAP_MANAGER_DN}"'</property>|'  ${NIFI_HOME}/conf/authorizers.xml

  if [ "${GENERATE_CERTIFICATES}" == "true" ]; then
    if [ -z "{tls_token}" ]; then
      echo "Cannot request certificates without environment variable tls_token."
      exit 1;
    fi

    echo "Requesting certificate with CSR."
    mkdir -p /opt/nifi/certs
    cd /opt/nifi/certs && /opt/nifi/nifi-toolkit-1.3.0/bin/tls-toolkit.sh client -t ${tls_token} -c nifi-ca
  fi

  # Disable HTTP and enable HTTPS
  prop_replace 'nifi.web.http.host' ""
  prop_replace 'nifi.web.http.port' ""

  prop_replace 'nifi.web.https.host' "${hostname}"
  prop_replace 'nifi.web.https.port' '8443'
  prop_replace 'nifi.remote.input.secure' 'true'
  prop_replace 'nifi.security.needClientAuth' 'false'
  prop_replace 'nifi.security.user.login.identity.provider' 'ldap-provider'

  # Setup keystore
  prop_replace 'nifi.security.keystore' "${NIFI_KEYSTORE}"
  prop_replace 'nifi.security.keystoreType' "${NIFI_KEYSTORE_TYPE}"
  if [ -z "${NIFI_KEYSTORE_PASSWORD}" ]; then
    echo "Keystore password was not provided, defaulting to generated location."
    NIFI_KEYSTORE_PASSWORD=$(cat /opt/nifi/certs/config.json | jq -r .keyStorePassword)
  fi
  prop_replace 'nifi.security.keystorePasswd' "${NIFI_KEYSTORE_PASSWORD}"
  prop_replace 'nifi.security.keyPasswd' "${NIFI_KEYSTORE_PASSWORD}"


  # Setup truststore
  prop_replace 'nifi.security.truststore' "${NIFI_TRUSTSTORE}"
  prop_replace 'nifi.security.truststoreType' "${NIFI_TRUSTSTORE_TYPE}"
  if [ -z "${NIFI_TRUSTSTORE_PASSWORD}" ]; then
    echo "Truststore password was not provided, defaulting to generated location."
    NIFI_TRUSTSTORE_PASSWORD=$(cat /opt/nifi/certs/config.json | jq -r .trustStorePassword)
  fi
  prop_replace 'nifi.security.truststorePasswd' "${NIFI_TRUSTSTORE_PASSWORD}"

else

  prop_replace 'nifi.web.http.host' "${hostname}" ${nifi_props_file}
  prop_replace 'nifi.cluster.node.address' "${hostname}" ${nifi_props_file}
  prop_replace 'nifi.remote.input.host' "${hostname}" ${nifi_props_file}

fi

# Continuously provide logs so that 'docker logs' can produce them
tail -F ${NIFI_HOME}/logs/nifi-app.log &
${NIFI_HOME}/bin/nifi.sh run &
PID="$!"

trap "for i in {1..5}; do echo Received SIGTERM, beginning shutdown...; done" SIGKILL SIGTERM SIGHUP SIGINT EXIT;

echo NiFi running with PID ${PID}.
wait $PID
