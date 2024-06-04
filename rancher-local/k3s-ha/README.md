# Create K3s HA rancher server

```bash

### If manually providing nodes, uncomment the below block and fill in your IP addresses
# export SERVER_0=<ip0>
# export SERVER_1=<ip1>
# export SERVER_2=<ip2>

### If using integration with cloud-cli-helpers + linode, uncomment this block to create the server e2e
# linode-create-3
# linode-wait-all-ready

export REPO_PATH=/home/slickwarren/Github/suse-garage/rancher-local/k3s-ha

export K8S_VERSION=v1.28.9+k3s1
export HARDENED=true # Hardens the local cluster in order for CIS scan to pass
export SSH_USER=root
export RANCHER_PASSWORD="thisisahardpassword"
export VERSION=2.9.0-alpha3
export RANCHER_IMAGE=v2.9-head
export RANCHER_REPO=rancher # some.internal.registry/rancher
# export RANCHER_HELM_REPO=https://releases.rancher.com/server-charts/latest # needed if adding a new helm repo to your setup
export HELM_NAME_RANCHER=rancher-alpha # rancher-prime, etc. 

wait-for-ssh

. $REPO_PATH/create_k3s_server.sh

```