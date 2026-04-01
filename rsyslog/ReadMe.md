
# Rsyslog Container on OpenShift

* Example for 'rsyslog' target from OpenShift Logging
* This is based upon the Red Hat 'rsyslog' container. See <https://catalog.redhat.com/en/software/containers/rhel9/rsyslog>

## Configuration

The `rsyslog.conf` file is read into a ConfigMap and mounted into the container.

Adjust the configuration to your needs.



## Deploy the Example

* Note the container needs to run with elevated privileges :-)

```shell
oc new-project rsyslog
oc import-image -n openshift rhel9/rsyslog:latest --from=registry.redhat.io/rhel9/rsyslog:latest --scheduled=true --confirm
oc -n rsyslog create cm rsyslog-conf --from-file=./files/rsyslog.conf
oc -n rsyslog create sa rsyslog
oc -n rsyslog adm policy add-scc-to-user anyuid -z rsyslog
oc -n rsyslog apply -f openshift/svc_rsyslog.yaml
oc -n rsyslog apply -f openshift/deploy_rsyslog.yaml
```


## Configure OpenShift Logging LogForwarder for Rsyslog

* Note: this is an example only

Steps:
* Deploy OpenShift Logging Operator
* Create a `LogForwarder` instance (see example); ensure there is a `ServiceAccount` for the `LogForwarder` which has suitable permissions

Example: 

```shell
oc apply -n openshift-logging -f logforwarder/sa-rolebindings_logforwarder.yaml
oc apply -n openshift-logging -f logforwarder/logforwarder.yaml
```

Once the LogForwarder is rolled out, the resulting logs will be sent to the 'rsyslog' Pod.

Use the Pod Terminal of the 'rsyslog' Pod and `tail -f /var/log/messages` to see the received log output.


References:
* https://docs.redhat.com/en/documentation/red_hat_openshift_logging/6.4/html/configuring_logging/configuring-log-forwarding#cluster-role-binding-for-your-service-account
* https://docs.redhat.com/en/documentation/red_hat_openshift_logging/6.4/html/configuring_logging/configuring-log-forwarding#cluster-logging-collector-log-forward-syslog_configuring-log-forwarding

