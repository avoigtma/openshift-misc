FROM registry.redhat.io/rhel7/rhel
RUN yum install -y iperf3
ENTRYPOINT trap : TERM INT; sleep infinity & wait # Listen for kill signals and exit quickly.

