
# Install

```shell
oc import-image -n openshift ubi8-ubi --from=registry.access.redhat.com/ubi8/ubi --confirm
oc apply -f openshift/namespace.iperf.yaml
oc apply -R -f openshift -n iperf
```

# References

Testing Network Bandwidth in OpenShift using iPerf Container.
https://access.redhat.com/articles/5233541

How to run iPerf network performance tests in OpenShift Container Platform 4 [RHOCP]
https://access.redhat.com/solutions/6129701


