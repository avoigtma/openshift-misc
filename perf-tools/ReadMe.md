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

> TBD

* Mount a persistent volume to the Deployment/Pod
* run `fio`



# References

## `iperf3`

Testing Network Bandwidth in OpenShift using perftools Container.
https://access.redhat.com/articles/5233541

How to run perftools network performance tests in OpenShift Container Platform 4 [RHOCP]
https://access.redhat.com/solutions/6129701

Using perftools in Openshift Container Platform to check Network performance
https://access.redhat.com/solutions/7020142


## `fio`

FIO ReadTheDocs
https://fio.readthedocs.io/en/latest/index.html

FIO Github
https://github.com/axboe/fio


