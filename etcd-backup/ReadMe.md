# Etcd Backup


## Create the Container Image

### Prerequisites

* a RHEL 9 machine / VM running Podman
* Red Hat account to pull UBI9 image
* (optional) an account at `quay.io` or any other registry to store the build image
    * we use `quay.io` as example


### Build the Image


## Install on OpenShift

```shell
oc apply -f openshift/00-namespace.yaml
oc apply -R -f openshift -n etcd-backup
```



# References

OpenShift Documentation 

