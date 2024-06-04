#!/bin/bash

ssh -o StrictHostKeyChecking=accept-new $SSH_USER@$1 "sudo mkdir -p -m 700 /var/lib/rancher/k3s/server/manifests"
ssh -o StrictHostKeyChecking=accept-new $SSH_USER@$1 "sudo mkdir -p -m 700 /var/lib/rancher/k3s/server/logs"
ssh -o StrictHostKeyChecking=accept-new $SSH_USER@$1 "sudo mkdir -p -m 700 /etc/rancher/k3s/"
ssh -o StrictHostKeyChecking=accept-new $SSH_USER@$1 "sudo mkdir -p -m 700 /etc/sysctl.d/"


cat $REPO_PATH/90-kubelet.yml | ssh $SSH_USER@$1 "sudo tee -a /etc/sysctl.d/90-kubelet.conf"
ssh -o StrictHostKeyChecking=accept-new $SSH_USER@$1 "sudo sysctl -p /etc/sysctl.d/90-kubelet.conf"

cat $REPO_PATH/audit.yml | ssh $SSH_USER@$1 "sudo tee -a /var/lib/rancher/k3s/server/audit.yml"

cat $REPO_PATH/psa.yml | ssh $SSH_USER@$1 "sudo tee -a /var/lib/rancher/k3s/server/psa.yml"

cat $REPO_PATH/config.yml | ssh $SSH_USER@$1 "sudo tee -a /etc/rancher/k3s/config.yaml"
