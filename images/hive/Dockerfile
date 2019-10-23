ARG HIVE_VERSION=3.1.2
ARG HADOOP_IMAGE=adruzenko/kbd-hadoop3:3.2.0

FROM ${HADOOP_IMAGE} as HDP

FROM adruzenko/kbd-base

ARG HIVE_VERSION

LABEL maintainer="alex@druzenko.com"
LABEL kbd.docker=true

ENV ZULU_OPENJDK_VERSION="8=8.38.0.13"

ENV ZULU_OPENJDK_VERSION="8=8.38.0.13"

ENV HIVE_HOME=/usr/local/hive \
    HIVE_CONF_DIR=/etc/hive \
    HIVE_LOG_DIR=/var/log/hive \
    HADOOP_HOME=/usr/local/hadoop \
    HADOOP_CONF_DIR=/etc/hadoop \
    HADOOP_LOG_DIR=/var/log/hadoop

ENV JAVA_HOME=/usr/lib/jvm/zulu-8-amd64 \
    PATH=${PATH}:/usr/local/hive/bin:/usr/local/hadoop/bin

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
  echo "===> Downloading Hive ${HIVE_VERSION}"; \
  mkdir -p /tmp/hive; \
  curl -fSL https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz -o /tmp/hive/apache-hive-${HIVE_VERSION}-bin.tar.gz; \
  curl -fSL https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz.asc -o /tmp/hive/apache-hive-${HIVE_VERSION}-bin.tar.gz.asc; \
  curl -fSL https://www.apache.org/dist/hive/KEYS -o /tmp/hive/KEYS; \
  export GNUPGHOME="$(mktemp -d)"; \
  gpg --import /tmp/hive/KEYS; \
  gpg --verify /tmp/hive/apache-hive-${HIVE_VERSION}-bin.tar.gz.asc; \
  \
  echo "===> Installing Hive ${HIVE_VERSION}"; \
  tar xzvf /tmp/hive/apache-hive-${HIVE_VERSION}-bin.tar.gz -C /usr/local; \
  mv /usr/local/apache-hive-${HIVE_VERSION}-bin /usr/local/hive-${HIVE_VERSION}; \
  ln -s /usr/local/hive-${HIVE_VERSION} /usr/local/hive; \
  rm -rf /tmp/hive "$GNUPGHOME"; \
  \
  echo "===> Installing mysql client libraries and procps"; \
  apt-get update && apt-get install -y mysql-client procps; \
  apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/*; \
  mkdir -p /tmp/mysql; \
  curl -fSL https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.48.tar.gz -o /tmp/mysql/mysql-connector-java-5.1.48.tar.gz; \
  tar xzvf /tmp/mysql/mysql-connector-java-5.1.48.tar.gz -C /tmp/mysql; \
  cp /tmp/mysql/mysql-connector-java-5.1.48/mysql-connector-java-5.1.48.jar /usr/local/hive/lib/; \
  rm -rf /tmp/mysq; \
  \
  echo "===> Setting up Hive ${HIVE_VERSION} users"; \
  groupadd -r hadoop; \
  useradd -r -g hadoop hadoop; \
  useradd -r -g hadoop hdfs; \
  useradd -r -g hadoop yarn; \
  useradd -r -g hadoop mapred; \
  useradd -r -g hadoop hive;

COPY --from=hdp /usr/local/hadoop /usr/local/hadoop

WORKDIR /usr/local/hive
