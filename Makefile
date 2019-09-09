HADOOP3_VERSION ?= 3.2.0

build: build-base build-hadoop

build-base:
	docker build -t adruzenko/kbd-base:latest -f images/base/Dockerfile images/base

build-hadoop: build-hadoop3

build-hadoop3:
	docker build -t adruzenko/kbd-hadoop3:latest --build-arg HADOOP_VERSION=${HADOOP3_VERSION} -f images/hadoop/hadoop-3/Dockerfile images/hadoop/hadoop-3

	docker tag adruzenko/kbd-hadoop3:latest adruzenko/kbd-hadoop3:${HADOOP3_VERSION}
