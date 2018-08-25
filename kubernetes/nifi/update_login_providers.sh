#!/bin/sh -ex

login_providers_file=${NIFI_HOME}/conf/login-identity-providers.xml
property_xpath='//loginIdentityProviders/provider/property'

# Update a given property in the login-identity-providers file if a value is specified
edit_property() {
  property_name=$1
  property_value=$2

  if [ -n "${property_value}" ]; then
    xmlstarlet ed --inplace -u "${property_xpath}[@name='${property_name}']" -v "${property_value}" "${login_providers_file}"
  fi
}

# Remove comments to enable the ldap-provider
sed -i.bak -e '66d;96d' "${login_providers_file}"

edit_property 'Authentication Strategy'     "${LDAP_AUTHENTICATION_STRATEGY}"
edit_property 'Manager DN'                  "${LDAP_MANAGER_DN}"
edit_property 'Manager Password'            "${LDAP_MANAGER_PASSWORD}"
edit_property 'TLS - Keystore'              "${LDAP_TLS_KEYSTORE}"
edit_property 'TLS - Keystore Password'     "${LDAP_TLS_KEYSTORE_PASSWORD}"
edit_property 'TLS - Keystore Type'         "${LDAP_TLS_KEYSTORE_TYPE}"
edit_property 'TLS - Truststore'            "${LDAP_TLS_TRUSTSTORE}"
edit_property 'TLS - Truststore Password'   "${LDAP_TLS_TRUSTSTORE_PASSWORD}"
edit_property 'TLS - Truststore Type'       "${LDAP_TLS_TRUSTSTORE_TYPE}"
edit_property 'TLS - Protocol'              "${LDAP_TLS_PROTOCOL}"
edit_property 'Url'                         "${LDAP_URL}"
edit_property 'User Search Base'            "${LDAP_USER_SEARCH_BASE}"
edit_property 'User Search Filter'          "${LDAP_USER_SEARCH_FILTER}"
edit_property 'Identity Strategy'           "${LDAP_IDENTITY_STRATEGY}"
