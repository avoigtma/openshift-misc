
# Build the Container Image on OpenShift

'etcd-backup' requires a backup target which can e.g. be a PVC mounted from an external NFS server or a 'scp/sftp' target on an external system. Other options like S3 targets may apply as well.

In order to use a 'scp/sftp' target on an external system, the `etcd-backup` Pod requires the respective commands.
An out-of-the-box UBI9 image does not cover these commands. The 'Containerfile' creates a custom UBI9-based image adding the required commands.



* Build the `ubi9sshclient` container image on OpenShift for use with 'etcd-backup'.


Current issue: required repositories are not accessible when building on OCP. This might be an entitlement topic.


Adding subscription entitlements as a build secret
https://docs.openshift.com/container-platform/4.17/cicd/builds/running-entitled-builds.html#builds-source-secrets-entitlements_running-entitled-builds

As the entitlement keys may be too large for `oc apply` to act, the following can be used.


```shell
oc import-image ubi9 -n openshift --from=registry.redhat.io/ubi9 --scheduled=true --confirm
oc get secret etc-pki-entitlement -n openshift-config-managed -o 'go-template={{index .data "entitlement-key.pem"}}' >entitlement-key.pem
oc get secret etc-pki-entitlement -n openshift-config-managed -o 'go-template={{index .data "entitlement.pem"}}' >entitlement.pem
oc -n etcd-backup create secret generic etc-pki-entitlement --from-file=entitlement-key.pem=./entitlement-key.pem --from-file=entitlement.pem=./entitlement.pem
oc -n etcd-backup apply -f openshift-build/is.ubi9.yaml -n etcd-backup
oc -n etcd-backup apply -f openshift-build/buildcfg.ubi9.yaml -n etcd-backup
```


# Manually build the image using Podman

Build the target image locally on a RHEL 9 machine using 'podman'.

```shell
podman build -t ubi9sshclient -f container/Containerfile-ubi9.podman
```

Push the image to OpenShift's image registry or an external image registry for use with the CronJob.


