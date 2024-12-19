#! /bin/bash

export REPO_PATH=$(realpath $(dirname ${BASH_SOURCE[0]})) 

. e2e.env
cd $REPO_PATH/../../terraform/$PROVIDER
terraform apply --auto-approve

. $REPO_PATH/ips_from_terraform.sh
cd $REPO_PATH


ssh-add -k ~/.ssh/jenkins-rke-validation.pem

wait-for-ssh

. $REPO_PATH/create_k3s_server.sh
. $REPO_PATH/install_rancher_on_cluster.sh