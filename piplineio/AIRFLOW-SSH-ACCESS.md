### Intro
To do all in this guide, you will need to have access to the Google Cloud.

### Connect to the Google Cloud VM instance
Connect to Google Cloud using `gcloud` console util. Connection string for Google Cloud environment:
```
gcloud compute --project "synapse-157713" ssh --zone "us-east1-b" "gke-synapse-1-default-pool-aa76ca07-0v5k"
```
or by using browser shell [here](https://console.cloud.google.com/compute/instances?project=synapse-157713)
use `SSH` button.

### Connect to the container
When you inside Google Cloud VM instance, list docker containers by:
```
docker ps
```

Connect to the AirFlow container with:
```
docker exec -it <container id or name> bash
```

### Inside AirFlow container
`dags` folder inside `/root/airflow/dags`.  
R scripts put in `/root/r_scripts`.

To enter `R shell` type `R` in terminal.

Install R packages by using this commands inside R shell:
```
install.packages("readr")
install.packages("dplyr")
install.packages("rstan")
install.packages("bayesplot")
install.packages("ggplot2")
install.packages("mclust")
```