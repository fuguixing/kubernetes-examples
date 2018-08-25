# Setup cluster in Google Cloud platform
For first you need to [Setup Docker and Kubernetes CLI](https://github.com/fluxcapacitor/pipeline/wiki/Setup-Docker-and-Kubernetes-CLI)

Then you need to [Create Kubernetes Cluster on GCP](https://github.com/fluxcapacitor/pipeline/wiki/Setup-Pipeline-Google)

# Configure cluster
For first you need to set [Virtual memory](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html) settings for Elasticsearch cluster.
For this, go to the [Compute Engine](https://console.cloud.google.com/compute/instances) in the GCP and choose connect via SSH.
Then in console enter:
```
sudo /sbin/sysctl vm.max_map_count=262144
```

Then you need to add NGINX Ingress controller. By using Kubernetes dashboard you need to upload `ingresss/deployment/nginx-ingress-controller.yaml` file.

This config is based on https://github.com/kubernetes/ingress/blob/master/examples/deployment/nginx/nginx-ingress-controller.yaml
More detailed guide about this ingress here https://github.com/kubernetes/ingress/tree/master/examples/deployment/nginx
Because there is [bug](https://github.com/kubernetes/ingress/issues/210) with permisions for passwords you need to use custom config with old version of NGINX docker image `0.8.3`.

# Kubernetes entry points
kubernetes-dashboard is running at https://104.196.110.166/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard
Kubernetes master is running at https://104.196.110.166
GLBCDefaultBackend is running at https://104.196.110.166/api/v1/proxy/namespaces/kube-system/services/default-http-backend
Heapster is running at https://104.196.110.166/api/v1/proxy/namespaces/kube-system/services/heapster
KubeDNS is running at https://104.196.110.166/api/v1/proxy/namespaces/kube-system/services/kube-dns

# Deploy Pipeline.IO stack
Use [this guide](https://github.com/fluxcapacitor/pipeline/wiki/Setup-Pipeline-on-Kubernetes) as base, but then you come to step [Deploy PipelineIO Services](https://github.com/fluxcapacitor/pipeline/wiki/Setup-Pipeline-on-Kubernetes#deploy-pipelineio-services) use this deploy description:
```
##############################
# Dashboard Services
##############################
echo '...Dashboard - Weavescope...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/dashboard.ml/weavescope/weavescope.yaml
kubectl describe svc weavescope-app

echo '...Dashboard - Turbine...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/dashboard.ml/turbine-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/dashboard.ml/turbine-svc.yaml
kubectl describe svc turbine

echo '...Dashboard - Hystrix...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/dashboard.ml/hystrix-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/dashboard.ml/hystrix-svc.yaml

echo '...Prometheus Metrics Collector...'
# TODO:  https://github.com/coreos/kube-prometheus

##############################
# Training Services
##############################
echo '...MySql...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/sql.ml/mysql-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/sql.ml/mysql-svc.yaml

echo '...HDFS...'
kubectl create -f https://raw.githubusercontent.com/MallCloud/AFIntegration/master/pipeline.io/hdfs/hdfs-rc.yaml?token=AAaPqVCbHqbf_2F_tMObw3WIhrMoZ4btks5Yue_0wA%3D%3D
kubectl create -f https://raw.githubusercontent.com/MallCloud/AFIntegration/master/pipeline.io/hdfs/hdfs-svc.yaml?token=AAaPqT4x6JuxHngazerF70UqsI1hVIbgks5YufAKwA%3D%3D

echo '...HUE...'
kubectl create -f https://raw.githubusercontent.com/MallCloud/AFIntegration/master/pipeline.io/hue/hue-rc.yaml?token=AAaPqb7KACD2H0f0ibrQZU6qUQNtRMtCks5YufAvwA%3D%3D
kubectl create -f https://raw.githubusercontent.com/MallCloud/AFIntegration/master/pipeline.io/hue/hue-svc.yaml?token=AAaPqV3CoZgyDPltQq_B3x86zSJEqckIks5YufA8wA%3D%3D

echo '...Cassandra...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/cassandra.ml/cassandra-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/cassandra.ml/cassandra-svc.yaml

echo '...Redis...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/keyvalue.ml/redis-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/keyvalue.ml/redis-svc.yaml

echo '...Elasticsearch...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/elasticsearch.ml/elasticsearch-2-3-0-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/elasticsearch.ml/elasticsearch-2-3-0-svc.yaml

echo '...Kibana...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/kibana.ml/kibana-4-5-0-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/kibana.ml/kibana-4-5-0-svc.yaml

echo '...Spark - Master...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/apachespark.ml/spark-master-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/apachespark.ml/spark-master-svc.yaml

echo '...Spark - Worker...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/apachespark.ml/spark-worker-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/apachespark.ml/spark-worker-svc.yaml

echo '...Hive Metastore...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/metastore.ml/metastore-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/metastore.ml/metastore-svc.yaml

echo '...Zookeeper...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/zookeeper.ml/zookeeper-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/zookeeper.ml/zookeeper-svc.yaml

echo '...Kafka...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/stream.ml/kafka-0.10-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/stream.ml/kafka-0.10-svc.yaml

echo '...JupyterHub...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/jupyterhub.ml/jupyterhub-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/jupyterhub.ml/jupyterhub-svc.yaml

echo '...Zeppelin...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/zeppelin.ml/zeppelin-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/zeppelin.ml/zeppelin-svc.yaml

echo '...Apache - Home...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/web.ml/home-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/web.ml/home-svc.yaml

echo '...Scheduler - Airflow...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/scheduler.ml/airflow-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/scheduler.ml/airflow-svc.yaml

##############################
# Prediction Services
##############################
echo '...Prediction - PMML...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/prediction.ml/pmml-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/prediction.ml/pmml-svc.yaml

echo '...Prediction - CodeGen...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/prediction.ml/codegen-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/prediction.ml/codegen-svc.yaml

echo '...Prediction - TensorFlow...'
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/prediction.ml/tensorflow-rc.yaml
kubectl create -f https://raw.githubusercontent.com/fluxcapacitor/pipeline/master/prediction.ml/tensorflow-svc.yaml
```

# Deploy proxies with basic auth
## Generate secret
[Original guide](https://github.com/kubernetes/contrib/blob/master/ingress/controllers/nginx/examples/auth/README.md)
For first you need to generate secret that contains a file generated with `htpasswd`:
```
$ htpasswd -c auth-file {username}
New password: {password}
Re-type new password: {password}
Adding password for user {username}
```
you'll get file `auth-file`, then create secret called `basic-auth` by using `kubectl`:
```
$ kubectl create secret generic basic-auth --from-file=auth-file
secret "basic-auth" created
```
## Upload proxies
Uplaod ingress files from this directory `ingress/proxies` by using Kubernetes dashboard.

# Pipeline.IO entry points
The way how in Kubernetes NGINX ingress controller works, all services are only available by domain names.
Because at current moment we don't have subdomains for cluster, the only way to access it - is to modify local `hosts` file.
To do this you need to add this entries in your local `hosts` file:
```
35.185.23.87 weavescope.kg-af.knowledgegrids.com
35.185.23.87 airflow.kg-af.knowledgegrids.com
35.185.23.87 jupyterhub.kg-af.knowledgegrids.com
35.185.23.87 spark-master.kg-af.knowledgegrids.com
35.185.23.87 hdfs.kg-af.knowledgegrids.com
35.185.23.87 hue.kg-af.knowledgegrids.com
35.185.23.87 hbase.kg-af.knowledgegrids.com
```

Here is how to do this on different OS: https://www.howtogeek.com/howto/27350/beginner-geek-how-to-edit-your-hosts-file/
For Mac better use this one: http://www.imore.com/how-edit-your-macs-hosts-file-and-why-you-would-want

# Tricks to run in `minikube`
Like described [here](https://cloud.google.com/container-registry/docs/advanced-authentication) you need to generate access token by executing next command:
```
gcloud auth print-access-token
```

Then, like described [here](https://github.com/kubernetes/minikube/issues/321#issuecomment-265222572), you need to login to the GCR:
```
minikube start (if it wasn't already running)
minikube ssh
sudo docker login https://gcr.io
Username: oauth2accesstoken
Password: {generated token}
exit
```

After that, before running pods, pull images from GCR manually inside `minikube`:
```
docker pull gcr.io/synapse-157713/hdfs:latest
```

And then you add RC set:
```
imagePullPolicy: "Never"
```
so it will use local registry to build containers.

Additional good link: https://ryaneschinger.com/blog/using-google-container-registry-gcr-with-minikube/

# Switching `kubectl` contexts
Use this command to switch between contexts:
```
kubectl config use-context gke_synapse-157713_us-east1-b_synapse-1
```
or
```
kubectl config use-context minikube
```

# Copy files to Google Cloud
```
gcloud compute copy-files {file name} gke-synapse-1-default-pool-aa76ca07-0v5k:~/{file name} --zone us-east1-b
```

Connect to bash od docker container:
```
docker exec -it <container id or name> bash
```

Copy to HDFS
```
hadoop fs -put /output.json /user/admin/output
```
