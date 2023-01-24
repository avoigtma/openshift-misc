# Simple Linux Tools container

Simple example for a fully-fledged Linux container to provide selected tools.

E.g. common containers do not have various networking tools installed.

This example uses an example of CentOS(Streams) to add some networking packages. Adjust to your needs :-)

There is a 'privileged' variant as well which allows 'sudo' within the container terminal and have full host access using the 'privileged' SCC. Use with care :-).

Plus a variant settling on Ubuntu (not complete, NOT preferred) for some testing.


```shell
oc import-image centosstream8 --from=quay.io/centos/centos:stream8 -n openshift --confirm --scheduled=true
oc import-image fedora36 --from=quay.io/fedora/fedora:36 -n openshift --confirm --scheduled=true
oc import-image ubuntu --from=ubuntu:latest -n openshift --confirm --scheduled=true

oc apply -f openshift/namespace.tools.yaml
oc apply -R -f openshift -n linux-container
oc adm policy add-scc-to-user anyuid -z rootable-sa -n linux-container
oc adm policy add-scc-to-user privileged -z privileged-sa -n linux-container
```



