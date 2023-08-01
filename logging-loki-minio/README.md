# logging-loki-minio

## Purpose

Deploy OpenShift Logging with Loki and use Minio as S3 storage base for Loki (quick-and-dirty setup)

## Steps

```

# install krew
## see https://krew.sigs.k8s.io/docs/user-guide/setup/install/
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
# put the 'export' to your $HOME/.bashrc


# rollout minio

oc krew install minio
oc minio -n minio-operator init
oc -n minio-operator adm policy add-scc-to-user anyuid -z console-sa
oc -n minio-operator adm policy add-scc-to-user anyuid -z minio-operator
oc -n minio-operator expose service console
oc patch -n minio-operator route/console -p='{"spec":{"tls":{"termination":"edge", "insecureEdgeTerminationPolicy":"Redirect"}}}'


# login to the minio console using the JWT derived from
oc minio proxy -n minio-operator
## note that command fails on 'oc'

# gather under Tenants > 'myminio' > Configuration the MINIO_ROOT_USER and password once the instance is created with the steps below

# create instance
oc minio -n minio-operator tenant create myminio --servers 4 --volumes 16 --capacity 64Gi
oc -n minio-operator adm policy add-scc-to-user anyuid -z myminio-sa
oc -n minio-operator expose service myminio-console --target-port='https-console'
oc -n minio-operator expose service minio --target-port='https-minio'
oc patch -n minio-operator route/myminio-console -p='{"spec":{"tls":{"termination":"passthrough", "insecureEdgeTerminationPolicy":"Redirect"}}}'
oc patch -n minio-operator route/minio -p='{"spec":{"tls":{"termination":"passthrough", "insecureEdgeTerminationPolicy":"Redirect"}}}'


# create access key on the Minio instance after logging in (via created route/myminio-console using MINIO_ROOT_USER
# write down/export the access-key-id and access-key-secret for future access

# test access to the Minio instance, e.g. using 's3cmd'
s3cmd configure
## put the created Route as URL, access-key-id, access-key-secret
s3cmd mb s3://test
s3cmd mb s3://loki

# install OpenShift Logging Operator
# install Loki Operator

# adjust the bucket-secret.yaml for the access-key-id, access-key-secret
oc apply -f bucket-secret.yaml
oc -n minio-operator get secret myminio-tls -o jsonpath="{.data.public\.crt}" | base64 -d > ./minio-crt.crt
oc -n openshift-logging create cm lokistack-minio-ca --from-file=service-ca.crt=./minio-crt.crt
oc apply -f lokistack.yaml
oc apply -f clusterlogging.yaml




```