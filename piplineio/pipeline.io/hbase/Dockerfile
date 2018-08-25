FROM ubuntu:16.04

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:webupd8team/java -y
RUN apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install oracle-java8-installer -y
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle

RUN apt-get install -y tar \
    && apt-get install -y wget \
    && mkdir /hbase-setup

WORKDIR /hbase-setup

RUN wget http://apache.ip-connect.vn.ua/hbase/1.2.4/hbase-1.2.4-bin.tar.gz
RUN tar zxf hbase-1.2.4-bin.tar.gz -C /opt/ \
    && ln -s /opt/hbase-1.2.4 /opt/hbase

ADD hbase-site.xml /opt/hbase/conf/hbase-site.xml
ADD start-k8s-hbase.sh /opt/hbase/bin/start-k8s-hbase.sh
RUN chmod +x /opt/hbase/bin/start-k8s-hbase.sh

WORKDIR /opt/hbase/bin

ENV PATH=$PATH:/opt/hbase/bin

CMD /opt/hbase/bin/start-k8s-hbase.sh
