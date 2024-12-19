#! /bin/bash
export REPO_PATH=/home/slickwarren/Github/suse-garage/rancher-local/k3s-ha
export PROVIDER="harvester"
cd $REPO_PATH/../../terraform/$PROVIDER
terraform apply --auto-approve

. $REPO_PATH/ips_from_terraform.sh
cd $REPO_PATH

export K8S_VERSION=v1.30.7+k3s1 # v1.27.13+k3s1 # v1.28.9+k3s1
export HARDENED=true
export SSH_USER=ubuntu
export RANCHER_PASSWORD=$ADMIN_PASSWORD
export RANCHER_CHART_VERSION=2.9.4
export VERSION=v2.9-head
export RANCHER_REPO=stgregistry.suse.com/rancher
export RANCHER_IMAGE=rancher #test-rancher
export RANCHER_HELM_REPO=https://charts.optimus.rancher.io/server-charts/latest # needed if adding a new helm repo to your setup
export HELM_NAME_RANCHER=staging-prime # staging-prime

ssh-add -k ~/.ssh/jenkins-rke-validation.pem

wait-for-ssh

. $REPO_PATH/create_k3s_server.sh
. $REPO_PATH/install_rancher_on_cluster.sh