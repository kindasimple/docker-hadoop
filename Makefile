
up:
	docker-compose up -d

shell:
	docker-compose run --name=hbase-submit --rm -it submit bash

setup:
	docker-compose run --rm -it setup

submit: setup
	docker-compose run --rm -it submit

clean:
	docker-compose run --rm -it submit hdfs dfs -cat /output/* && hdfs dfs -rm -r /output && hdfs dfs -rm -r /input

data:
	open http://localhost:9870

hadoop:
	open http://localhost:8088

.PHONY: submit data setup hadoop shell up