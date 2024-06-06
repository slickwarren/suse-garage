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
export HARDENED=true
export SSH_USER=root
export RANCHER_PASSWORD="thisisahardpassword"
export RANCHER_CHART_VERSION=2.8.4
export VERSION=v2.8.4
export RANCHER_REPO=rancher # registry/rancher
export RANCHER_IMAGE=rancher # rancher
# export RANCHER_HELM_REPO=https://releases.rancher.com/server-charts/latest # needed if adding a new helm repo to your setup
export HELM_NAME_RANCHER=rancher-latest # staging-prime


wait-for-ssh

. $REPO_PATH/create_k3s_server.sh


```