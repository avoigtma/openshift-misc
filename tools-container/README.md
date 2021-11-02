# Simple Linux Tools container

Simple example for a fully-fledged Linux container to provide selected tools.

E.g. common containers do not have various networking tools installed.

This example uses an example of CentOS to add some networking packages. Adjust to your needs :-)

```shell
oc import-image centos --from=registry.centos.org/centos:centos8 -n openshift --confirm
oc apply -f openshift/namespace.tools.yaml
oc apply -R -f openshift
```



