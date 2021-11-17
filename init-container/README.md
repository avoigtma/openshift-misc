# Init Container Example

A simple example for InitContainers.

* Have an InitContainer create directory structures on a PVC-mounted file system before the actual (application workload) container starts.

See as well [https://docs.openshift.com/container-platform/4.9/nodes/containers/nodes-containers-init.html](https://docs.openshift.com/container-platform/4.9/nodes/containers/nodes-containers-init.html).

## Steps

Create PVC (assuming StorageClass `managed-nfs-storage` is available; adjust PVC creation otherwise):

```shell
oc apply -f pvc_sample.yaml
```

Rollout Deployment  
```shell
oc apply -f deployment_sample-InitContainer.yaml
```

Check the logs

```shell
# logs of init container
oc logs deploy/init-container-example -c init-directories

# logs of workload container
oc logs deploy/init-container-example -c init-container-example
```

