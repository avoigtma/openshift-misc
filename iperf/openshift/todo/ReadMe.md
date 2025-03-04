# TODO

* Build the `iperf3` container image on OpenShift.


Current issue: required repositories are not accessible when building on OCP. This might be an entitlement topic.


Adding subscription entitlements as a build secret
https://docs.openshift.com/container-platform/4.17/cicd/builds/running-entitled-builds.html#builds-source-secrets-entitlements_running-entitled-builds

As the entitlement keys may be too large for `oc apply` to act, the following can be used.


```shell
oc get secret etc-pki-entitlement -n openshift-config-managed -o 'go-template={{index .data "entitlement-key.pem"}}' >entitlement-key.pem
oc get secret etc-pki-entitlement -n openshift-config-managed -o 'go-template={{index .data "entitlement.pem"}}' >entitlement.pem
oc create secret generic etc-pki-entitlement --from-file=entitlement-key.pem=./entitlement-key.pem --from-file=entitlement.pem=./entitlement.pem
```

