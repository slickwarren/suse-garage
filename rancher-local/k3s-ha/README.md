# Create K3s HA rancher server

```bash
export SERVER_0=<ip0>
export SERVER_1=<ip1>
export SERVER_2=4<ip2>

export K8S_VERSION=v1.28.8+k3s1 # v1.27.11+k3s1 must be available upstream

export SSH_USER=root
export VERSION=2.8.3 # chart version of rancher to use
export RANCHER_IMAGE=v2.8-head # rancher version to use
export RANCHER_REPO=rancher/rancher
# export RANCHER_HELM_REPO=https://releases.rancher.com/server-charts/latest # if specified, will override helm repo with name of HELM_NAME_RANCHER
export HELM_NAME_RANCHER=rancher-latest # staging-prime this can be an existing name in your helm repo list

. ./home/slickwarren/Github/suse-garage/rancher-local/k3s-ha/create_k3s_server.sh
```