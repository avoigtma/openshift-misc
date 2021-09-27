# Prometheus Pushgateway on OpenShift v4

The Prometheus Pushgateway ([https://github.com/prometheus/pushgateway](https://github.com/prometheus/pushgateway]) allows components which do not allow (direct) scraping of metrics from Prometheus to push metrics to the PushGateway for further consumption.

The following shows a simple apporach how to deploy PushGateway on OpenShift v4 and connect Pushgateway to OpenShift v4's User-Workload-Monitoring.

> The following deployment does not (yet) cover specific configurations of Pushgateway.

## Prerequisites

Deploy/Configure OpenShift User-Workload Monitoring as described in the OpenShift documentation ([Enabling monitoring for user-defined projects, https://docs.openshift.com/container-platform/4.8/monitoring/enabling-monitoring-for-user-defined-projects.html](https://docs.openshift.com/container-platform/4.8/monitoring/enabling-monitoring-for-user-defined-projects.html)).

## Deploy Prometheus Pushgateway

Note: Pushgateway container image source is from Prometheus repository on 'quay.io': [https://quay.io/repository/prometheus/pushgateway?tab=info](https://quay.io/repository/prometheus/pushgateway?tab=info)

### Deploy Pushgateway and create Service

```shell
oc apply -f pushgateway.yaml
```

File `pushgateway.yaml`

```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: pushgateway
  labels:
     app: pushgateway
spec:
   replicas: 1
   selector:
     matchLabels:
       app: pushgateway
   template:
      metadata:
         labels:
           app: pushgateway
      spec:
        containers:
         - name: pushgateway
           image: quay.io/prometheus/pushgateway:latest
           ports:
           - containerPort: 9091
           imagePullPolicy: Always
---
kind: Service
apiVersion: v1
metadata:
  labels:
    app: pushgateway
  name: pushgateway
spec:
  selector:
    app: pushgateway
  ports:
  - name: pushgateway
    protocol: TCP
    port: 9091
    targetPort: 9091
```

### (optional) Create Route

A route on the Pushgateway Service can be created optionally. Overall, a route is not recommended as the Pushgateway exposes information without protection without additional configuration.

To create a route

```shell
oc apply -f route_pushgateway.yaml
```

File: `route_pushgateway.yaml`

```yaml
kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: pushgateway
  namespace: prometheus-pushgateway
  labels:
    app: pushgateway
spec:
  to:
    kind: Service
    name: pushgateway
    weight: 100
  port:
    targetPort: pushgateway
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Allow
  wildcardPolicy: None
```


## Connect to OpenShift User-Workload Monitoring

Create a `ServiceMonitor` for user workload on OpenShift in the 

```shell
oc apply -f serviceMonitor_pushgateway.yaml
```

File `serviceMonitor_pushgateway.yaml`

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: pushgateway-monitor
  name: pushgateway-monitor
spec:
  endpoints:
  - interval: 10s
    port: pushgateway
    scheme: http
    honorLabels: true
    honorTimestamps: true
  selector:
    matchLabels:
      app: pushgateway
```

## Pushing Example Metrics and viewing Examples

### Pushing Example Metrics

For pushing metrics to the Pushgateway, use some arbitrary pod running on OpenShift (likely in the same namespace as the Pushgateway or having access to Pushgateway service (honoring available NetworkPolicies).

Open a terminal to such Pod and push metrics using 'curl':

```shell
cat <<EOF | curl --data-binary @- http://pushgateway.prometheus-pushgateway.svc:9091/metrics/job/demo_job/instance/demo_instance
# TYPE my_metric counter
my_metric{label="myVal"} 1
# TYPE my_other_metric gauge
# HELP my_other_metric Just an example.
my_other_metric 42.0
EOF

sleep 60

cat <<EOF | curl --data-binary @- http://pushgateway.prometheus-pushgateway.svc:9091/metrics/job/demo_job/instance/demo_instance
# TYPE my_metric counter
my_metric{label="myVal"} 2
# TYPE my_other_metric gauge
# HELP my_other_metric Just an example.
my_other_metric 233.0
EOF

sleep 60

cat <<EOF | curl --data-binary @- http://pushgateway.prometheus-pushgateway.svc:9091/metrics/job/demo_job/instance/demo_instance
# TYPE my_metric counter
my_metric{label="myVal"} 3
# TYPE my_other_metric gauge
# HELP my_other_metric Just an example.
my_other_metric 47.93
EOF

```

### Viewing the Example Metrics

Go to OpenShift WebConsole > Monitoring > Metrics.

Add two queries for the pushed custom metrics `my_metric` and `my_other_metric` and run the queries.

The result will look similar to

![Example of Pushed Metrics in OpenShift WebConsole Metrics view](sample.png)
