ARG HADOOP_VERSION=3.2.0

FROM adruzenko/kbd-base

ARG HADOOP_VERSION

LABEL maintainer="alex@druzenko.com"
LABEL kbd.docker=true

ENV ZULU_OPENJDK_VERSION="8=8.38.0.13"

ENV HADOOP_HOME=/usr/local/hadoop \
    HADOOP_CONF_DIR=/etc/hadoop \
    HADOOP_LOG_DIR=/var/log/hadoop

ENV JAVA_HOME=/usr/lib/jvm/zulu-8-amd64 \
    PATH=${PATH}:/usr/local/hadoop/bin

RUN set -ex; \
	\
  echo "===> Installing Zulu OpenJDK ${ZULU_OPENJDK_VERSION}"; \
  apt-key adv --keyserver hkps://keyserver.ubuntu.com:443 --recv-keys 0x27BC0C8CB3D81623F59BDADCB1998361219BD9C9; \
  echo "deb http://repos.azulsystems.com/debian stable  main" >> /etc/apt/sources.list.d/zulu.list; \
  apt-get -qq update; \
  apt-get -y install zulu-${ZULU_OPENJDK_VERSION}; \
  apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/*;

RUN set -ex; \
	\
  echo "===> Downloading Hadoop ${HADOOP_VERSION}"; \
  mkdir -p /tmp/hadoop; \
  curl -fSL https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz -o /tmp/hadoop/hadoop-${HADOOP_VERSION}.tar.gz; \
  curl -fSL https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.asc -o /tmp/hadoop/hadoop-${HADOOP_VERSION}.tar.gz.asc; \
  curl -fSL https://www.apache.org/dist/hadoop/common/KEYS -o /tmp/hadoop/KEYS; \
  export GNUPGHOME="$(mktemp -d)"; \
  gpg --import /tmp/hadoop/KEYS; \
  gpg --verify /tmp/hadoop/hadoop-${HADOOP_VERSION}.tar.gz.asc; \
  \
  echo "===> Installing Hadoop ${HADOOP_VERSION}"; \
  tar xzvf /tmp/hadoop/hadoop-${HADOOP_VERSION}.tar.gz -C /usr/local; \
  ln -s /usr/local/hadoop-${HADOOP_VERSION} /usr/local/hadoop; \
  rm -rf /tmp/hadoop "$GNUPGHOME"; \
  \
  echo "===> Setting up Hadoop ${HADOOP_VERSION} users"; \
  groupadd -r hadoop; \
  useradd -r -g hadoop hadoop; \
  useradd -r -g hadoop hdfs; \
  useradd -r -g hadoop yarn; \
  useradd -r -g hadoop mapred; \
  \
  echo "===> Setting up Hadoop ${HADOOP_VERSION} dirs"; \
  mkdir -p /var/log/hadoop && chown -R hadoop:hadoop /var/log/hadoop; \
  mkdir -p /var/log/hadoop/hdfs && chown -R hdfs:hadoop /var/log/hadoop/hdfs; \
  mkdir -p /var/log/hadoop/yarn && chown -R yarn:hadoop /var/log/hadoop/yarn; \
  mkdir -p /var/log/hadoop/mapred && chown -R mapred:hadoop /var/log/hadoop/mapred; \
  mkdir -p /var/local/hadoop/dfs/namenode /var/local/hadoop/dfs/datanode /var/local/hadoop/dfs/journalnode; \
  chown -R hdfs:hadoop /var/local/hadoop/dfs;

VOLUME ["/var/local/hadoop"]

# NameNode Ports (http, https, rpc)
EXPOSE 9870 9871 8020

# DataNode Ports (http, https, data transfer, ipc)
EXPOSE 9864 9865 9866 9867

# JournalNode Ports (http, https, rpc)
EXPOSE 8480 8481 8485

# ResourceManager Ports (http, https, scheduler, resource-tracker, resource manager, admin)
EXPOSE 8088 8090 8030 8031 8032 8033

# NodeManager Ports (http, https, localizer ipc, collector)
EXPOSE 8042 8044 8040 8048

# HistoryServer Ports (http, https, rpc, admin)
EXPOSE 19888 19890 10020 10033

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

WORKDIR /usr/local/hadoop
