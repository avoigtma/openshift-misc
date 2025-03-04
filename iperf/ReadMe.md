# Container Image to run Network Performance Tools like `iperf3` on OpenShift

## Example Container Image

See my example repository on `quay.io`: `quay.io/avoigtma/netperf`. Please note that may be outdated!


## Create the Container Image

### Prerequisites

* a RHEL 9 machine / VM running Podman
* Red Hat account to pull UBI9 image
* (optional) an account at `quay.io` or any other registry to store the build image
    * we use `quay.io` as example


### Build the Image

```shell
podman login registry.redhat.io
podman build -t netperf -f container/Containerfile-iperf.podman
```

### Push image to target registry

Remark: '2025-MM-DD' is meant as month and date.

```shell
podman login -u=<user> -p=<token> quay.io
podman tag localhost/netperf:latest quay.io/avoigtma/netperf:latest
podman tag localhost/netperf:latest quay.io/avoigtma/netperf:2025-MM-DD
podman push quay.io/avoigtma/netperf:2025-03-03
podman push quay.io/avoigtma/netperf:latest
```


## Install on OpenShift

```shell
oc apply -f openshift/namespace.iperf.yaml
oc apply -R -f openshift -n iperf
```

## Run `iperf3` Tests

Modify the `Deployment` resources for both client and server part of the 'iperf' Deployment to bind the Pods to the target nodes. Adjust the `Deployment.spec.template.spec.nodeName` value to the target node name.

Go to the terminal (WebUI or `oc rsh`) of the server Pod and run `iperf3`, e.g.:

```shell
iperf3 -s -p 5201 --forceflush
```

Determine the IP address of the server pod, e.g. `10.131.0.19`.

Go to the terminal (WebUI or `oc rsh`) of the client Pod and run `iperf3`, e.g.:

```shell
iperf3 -c <iperf3-server-ip>  -t 15 -w 64k -P 1 -p 5201
```

Adjust `iperf3` parameters as required.

Instead of running on a Pod, the 'server'-side of `iperf3` can be run on any other target system (VM, etc.) outside of OpenShift which can be reached by the client-side `iperf3` Pod.




# References

Testing Network Bandwidth in OpenShift using iPerf Container.
https://access.redhat.com/articles/5233541

How to run iPerf network performance tests in OpenShift Container Platform 4 [RHOCP]
https://access.redhat.com/solutions/6129701

Using Iperf in Openshift Container Platform to check Network performance
https://access.redhat.com/solutions/7020142



