FROM debian:9 as base

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      openjdk-8-jdk \
      net-tools \
      curl \
      netcat \
      gnupg \
      libsnappy-dev \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64/

RUN curl -O https://dist.apache.org/repos/dist/release/hadoop/common/KEYS

RUN gpg --import KEYS

ENV HADOOP_VERSION 3.2.1
ENV HADOOP_URL https://archive.apache.org/dist/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz

RUN set -x \
    && curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
    && curl -fSL "$HADOOP_URL.asc" -o /tmp/hadoop.tar.gz.asc \
    && gpg --verify /tmp/hadoop.tar.gz.asc \
    && tar -xvf /tmp/hadoop.tar.gz -C /opt/ \
    && rm /tmp/hadoop.tar.gz*

RUN ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop

RUN mkdir /opt/hadoop-$HADOOP_VERSION/logs

RUN mkdir /hadoop-data

ENV HADOOP_HOME=/opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1
ENV USER=root
ENV PATH $HADOOP_HOME/bin/:$PATH

ADD ./scripts /scripts
RUN chmod a+x /scripts/*.sh

RUN mkdir -p /hadoop/yarn/timeline
RUN mkdir -p /hadoop/dfs/data
RUN mkdir -p /hadoop/dfs/name
RUN mkdir -p /hadoop/yarn/timeline

VOLUME /hadoop/yarn/timeline
VOLUME /hadoop/dfs/data
VOLUME /hadoop/dfs/name
VOLUME /hadoop/yarn/timeline


# datanode
EXPOSE 9864
# resourcemanager
EXPOSE 8088
# namenode
EXPOSE 9870
# nodemanager
EXPOSE 8042
# historyserver
EXPOSE 8188

ENTRYPOINT ["/scripts/entrypoint.sh"]

############################################
FROM base as submit

ARG PORT

HEALTHCHECK CMD curl -f http://localhost:${PORT}/ || exit 1

COPY submit/WordCount.jar /opt/hadoop/applications/WordCount.jar
ENV JAR_FILEPATH="/opt/hadoop/applications/WordCount.jar"
ENV CLASS_TO_RUN="WordCount"
ENV PARAMS="/input /output"

CMD ["/scripts/run_submit.sh"]