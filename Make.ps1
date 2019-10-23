$DOCKER_NETWORK = "docker-hadoop_default"
$ENV_FILE = "hadoop.env"
$current_branch ="3.2.1" # $(shell git rev-parse --abbrev-ref HEAD)
function build() {
	docker build -t cicorias/hadoop-base:$current_branch ./base
	docker tag cicorias/hadoop-base:$current_branch cicorias/hadoop-base:latest
	docker build -t cicorias/hadoop-namenode:$current_branch ./namenode
	docker build -t cicorias/hadoop-datanode:$current_branch ./datanode
	docker build -t cicorias/hadoop-resourcemanager:$current_branch ./resourcemanager
	docker build -t cicorias/hadoop-nodemanager:$current_branch ./nodemanager
	docker build -t cicorias/hadoop-historyserver:$current_branch ./historyserver
	docker build -t cicorias/hadoop-submit:$current_branch ./submit
}
  
function wordcount() {
	docker build -t hadoop-wordcount ./submit
	docker run --network $DOCKER_NETWORK --env-file $ENV_FILE cicorias/hadoop-base:$current_branch hdfs dfs -mkdir -p /input/
	docker run --network $DOCKER_NETWORK --env-file $ENV_FILE cicorias/hadoop-base:$current_branch hdfs dfs -copyFromLocal /opt/hadoop-3.2.1/README.txt /input/
	docker run --network $DOCKER_NETWORK --env-file $ENV_FILE hadoop-wordcount
	docker run --network $DOCKER_NETWORK --env-file $ENV_FILE cicorias/hadoop-base:$current_branch hdfs dfs -cat /output/*
	docker run --network $DOCKER_NETWORK --env-file $ENV_FILE cicorias/hadoop-base:$current_branch hdfs dfs -rm -r /output
	docker run --network $DOCKER_NETWORK --env-file $ENV_FILE cicorias/hadoop-base:$current_branch hdfs dfs -rm -r /input
}

build
wordcount
