#!/usr/bin/env bash
hdfs dfs -rm -r /output
hdfs dfs -rm -r /input
hdfs dfs -mkdir -p /input/
hdfs dfs -copyFromLocal -f /opt/hadoop-3.2.1/README.txt /input/