FROM openjdk:8-jre-alpine

ENV   DIST_MIRROR   https://archive.apache.org/dist/nifi/
ENV   NIFI_HOME     /opt/nifi-tls-toolkit
ENV   VERSION       1.7.1

RUN   apk --update add tar curl && \
        mkdir -p ${NIFI_HOME} && \
        curl ${DIST_MIRROR}/${VERSION}/nifi-toolkit-${VERSION}-bin.tar.gz | tar xvz -C ${NIFI_HOME} --strip-components=1 && \
        rm ${NIFI_HOME}/bin/*.bat

VOLUME /generated

WORKDIR /generated

ENTRYPOINT ["/opt/nifi-tls-toolkit/bin/tls-toolkit.sh"]