# git-ssh-server

A Pod running a copy of a Git repository (selected branch) and provides that as an ssh-accessible Git repo within the cluster.

## Installation

```shell
NAMESPACE=git-ssh
oc new-project $NAMESPACE
```

### Build the Image

* Adjust source Git repo values in `openshift-build/cm_git-source-server-config.yaml`

```shell
oc apply -n $NAMESPACE -f openshift-build
```

