# Container Image to run Performance Tools like `iperf3` (network performance) or `fio` (disk performance) on OpenShift

Tools covered

* `iperf3` (network performance)
* `fio` (disk performance)

## Example Container Image

See my example repository on `quay.io`: `quay.io/avoigtma/perftools`. Please note that may be outdated!


## Create the Container Image

### Prerequisites

* a RHEL 9 machine / VM running Podman
* Red Hat account to pull UBI9 image
* (optional) an account at `quay.io` or any other registry to store the build image
    * we use `quay.io` as example


### Build the Image

```shell
podman login registry.redhat.io
podman build -t perftools -f container/Containerfile-perf-tools.podman
```

### Push image to target registry

Remark: '2025-MM-DD' is meant as month and date.

```shell
podman login -u=<user> -p=<token> quay.io
podman tag localhost/perftools:latest quay.io/avoigtma/perftools:latest
podman tag localhost/perftools:latest quay.io/avoigtma/perftools:$(date "+%Y-%m-%d")
podman push quay.io/avoigtma/perftools:$(date "+%Y-%m-%d")
podman push quay.io/avoigtma/perftools:latest
```


## Install on OpenShift


* two PVCs will be created using default storageclass - adjust the PVC yaml files in case a specific storageclass needs to be used

```shell
oc apply -f openshift/namespace.perftools.yaml
oc apply -R -f openshift -n perftools
```

## Run `iperf3` Tests

Modify the `Deployment` resources for both client and server part of the 'perftools' Deployment to bind the Pods to the target nodes. Adjust the `Deployment.spec.template.spec.nodeName` value to the target node name.

Go to the terminal (WebUI or `oc rsh`) of the server Pod and run `perftools3`, e.g.:

```shell
iperf3 -s -p 5201 --forceflush
```

Determine the IP address of the server pod, e.g. `10.131.0.19`.

Go to the terminal (WebUI or `oc rsh`) of the client Pod and run `iperf3`, e.g.:

```shell
iperf3 -c <iperf3-server-ip>  -t 15 -w 64k -P 1 -p 5201
```

Adjust `iperf3` parameters as required.

Instead of running on a Pod, the 'server'-side of `iperf3` can be run on any other target system (VM, etc.) outside of OpenShift which can be reached by the client-side Pod.


## Run `fio` Tests

* the 'perftools' Deployment has a PVC attached (default on `/fiotest`)
* run `fio` using suitable parameters against that volume
* a script is included in `/scripts` which runs a number of tests using different parameters (*sick* are these suitable)
* a Job runs the script automatically and and copies the output to a ConfigMap
  * gather the result data from the ConfigMap and delete the ConfigMap afterwards in order not to flood 'etcd' with unneeded data


# References

## `iperf3` - Network Performance Tests

Testing Network Bandwidth in OpenShift using perftools Container.
https://access.redhat.com/articles/5233541

How to run perftools network performance tests in OpenShift Container Platform 4 [RHOCP]
https://access.redhat.com/solutions/6129701

Using perftools in Openshift Container Platform to check Network performance
https://access.redhat.com/solutions/7020142


## `fio` - Disk Performance Tests

FIO ReadTheDocs
https://fio.readthedocs.io/en/latest/index.html

FIO Github
https://github.com/axboe/fio


## S3 Performance Tests

The creators/vendor of Mino provides a tool called 'warp' for measuring S3 access performance.

Links to 'warp' tool and several blogs on usage:

Warp Github
https://github.com/minio/warp

Benchmarking AIStor with WARP and Perf test
https://blog.min.io/how-to-benchmark-minio-warp-speedtest/

Introducing Performance Test for MinIO
https://blog.min.io/introducing-speedtest-for-minio/

Benchmarking MinIO with WARP and Speedtest
https://hackernoon.com/benchmarking-minio-with-warp-and-speedtest




# Examples: Running Performance-Tests for S3

```shell
S3URL="https://$(oc get route -n minio minio-s3 --template='{{ .spec.host }}')"
S3SRV=$(oc get route -n minio minio-s3 --template='{{ .spec.host }}')

mc alias set warptest $S3URL $(jq -r .accessKey credentials.json) $(jq -r  .secretKey credentials.json)
mc admin info warptest

mc mb warptest/warptest
mc ls warptest/warptest

#warp mixed --host=$S3SRV --access-key=$(jq -r .accessKey credentials.json) --secret-key=$(jq -r  .secretKey credentials.json) --autoterm --bucket=warptest/warptest

# Mixed benchmark - read and write
warp mixed --host=$S3SRV --access-key=$(jq -r .accessKey credentials.json) --secret-key=$(jq -r  .secretKey credentials.json) --autoterm --tls

# List benchmark
warp list --host=$S3SRV --access-key=$(jq -r .accessKey credentials.json) --secret-key=$(jq -r  .secretKey credentials.json) --autoterm --tls

# Get benchmark
warp get --host=$S3SRV --access-key=$(jq -r .accessKey credentials.json) --secret-key=$(jq -r  .secretKey credentials.json) --autoterm --tls --range


````
