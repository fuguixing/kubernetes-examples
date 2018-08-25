FROM       alpine
MAINTAINER Fugui <xingfugui111@gmail.com>
ARG        DIST_MIRROR=http://archive.apache.org/dist/nifi
ARG        VERSION=1.7.1
ENV        NIFI_HOME=/opt/nifi \
           JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk \
           PATH=$PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

RUN        apk add --no-cache bash curl openjdk8 jq xmlstarlet && \
           mkdir -p ${NIFI_HOME} \
           mkdir -p ${NIFI_HOME}/conf/templates
ADD        nifi-${VERSION} ${NIFI_HOME}
ADD        resources/nifi-toolkit-${VERSION}-bin.tar.gz /opt/nifi/

#RUN        apk add --no-cache bash curl openjdk8 && \
#           mkdir -p ${NIFI_HOME} && \
#           curl ${DIST_MIRROR}/${VERSION}/nifi-${VERSION}-bin.tar.gz | tar xvz -C ${NIFI_HOME} && \
#           mv ${NIFI_HOME}/nifi-${VERSION}/* ${NIFI_HOME} && \
#           rm -rf ${NIFI_HOME}/nifi-${VERSION} && \
#           rm -rf *.tar.gz

EXPOSE     8080 8081 8443
VOLUME     ${NIFI_HOME}/logs \
           ${NIFI_HOME}/flowfile_repository \
           ${NIFI_HOME}/database_repository \
           ${NIFI_HOME}/content_repository \
           ${NIFI_HOME}/provenance_repository
#WORKDIR    ${NIFI_HOME}
#CMD        ./bin/nifi.sh run

ENV        BANNER_TEXT="" \
           S2S_PORT=""
COPY       start_nifi.sh /${NIFI_HOME}/
COPY       update_login_providers.sh /${NIFI_HOME}/
VOLUME     /opt/datafiles \
           /opt/scriptfiles \
           /opt/certfiles
WORKDIR    ${NIFI_HOME}
RUN        chmod +x ./start_nifi.sh
CMD        ./start_nifi.sh
