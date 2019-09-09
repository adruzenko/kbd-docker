#!/usr/bin/env bash
set -e

: ${DFS_NAMENODE_NAME_DIR:="/var/local/hadoop/dfs/namenode"}

initialize_namenode()
{
    dirs=$1
    IFS=","
    for dir in ${dirs[@]}; do
        if [ ! -d $dir/current ]; then
            echo "Formatting namenode dir $dir"
            hdfs namenode -format
        fi
        chown -R hdfs:hadoop $dir
    done
    unset IFS
}

start_hadoop()
{
    command=$1
    shift

    case "$command" in
    "namenode" | "datanode" | "journalnode")
      HADOOP_USER="hdfs"
      HADOOP_LOG_DIR=/var/log/hadoop/hdfs
      ;;
    "resourcemanager" | "nodemanager")
      HADOOP_USER="yarn"
      HADOOP_LOG_DIR=/var/log/hadoop/yarn
      ;;
    "historyserver")
      HADOOP_USER="mapred"
      HADOOP_LOG_DIR=/var/log/hadoop/mapred
      ;;
    *)
      HADOOP_USER="hadoop"
      HADOOP_LOG_DIR=/var/log/hadoop
      ;;
    esac

    # ensure logs directory exist
    [ -d $HADOOP_LOG_DIR ] || mkdir $HADOOP_LOG_DIR

    # perform initializations before switching to "hadoop" user as
    # it may be required to have "root" privileges
    if [ "$command" == "namenode" ]; then
        initialize_namenode $DFS_NAMENODE_NAME_DIR
    fi

    # allow the container to be started with `--user`
    if [ "$(id -u)" = '0' ]; then
	    chown -R $HADOOP_USER:hadoop $HADOOP_LOG_DIR
      chmod o+w /dev/std*

      # Execute the current script as "hadoop" user
	    gosu $HADOOP_USER "$BASH_SOURCE" "hadoop" "$command" "$@"
    fi

    if [ "$command" = "namenode" ]; then
        exec "hdfs" "namenode"
    fi

    if [ "$command" = "datanode" ]; then
        exec "hdfs" "datanode"
    fi

    if [ "$command" = "journalnode" ]; then
        exec "hdfs" "journalnode"
    fi

    if [ "$command" = "resourcemanager" ]; then
        exec "yarn" "resourcemanager"
    fi

    if [ "$command" = "nodemanager" ]; then
        exec "yarn" "nodemanager"
    fi

    if [ "$command" = "historyserver" ]; then
        exec "mapred" "historyserver"
    fi

    if [ "$command" = "sh" ]; then
        exec /bin/bash "$@"
    fi

    echo "Unknown argument: $command"
    exit 1
}

if [ "$1" = "hadoop" ]; then
    shift
    start_hadoop "$@"
fi

exec "$@"
