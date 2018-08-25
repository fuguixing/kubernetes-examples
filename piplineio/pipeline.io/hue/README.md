Build:
```
docker build -t gcr.io/synapse-157713/hue:1.0.0 -t gcr.io/synapse-157713/hue:latest .
```

Push:
```
gcloud docker -- push gcr.io/synapse-157713/hue
```
