Distributed HBase based on HDFS above Kubernetes with 2 masters and 2 regionservers.

## How to run
Build:
```
docker build -t gcr.io/synapse-157713/hbase:1.2.4 -t gcr.io/synapse-157713/hbase:latest .
```

Push:
```
gcloud docker -- push gcr.io/synapse-157713/hbase
```
