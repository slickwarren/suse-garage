#!/bin/bash

echo "begin creating k3s cluster..."

ssh -o StrictHostKeyChecking=accept-new $SSH_USER@$SERVER_0 "ls -la"
ssh -o StrictHostKeyChecking=accept-new $SSH_USER@$SERVER_1 "ls -la"
ssh -o StrictHostKeyChecking=accept-new $SSH_USER@$SERVER_2 "ls -la"

if [ -z $HARDENED ]; then
    echo "Not hardening cluster..."
else
    if [ $HARDENED == "true" ]; then
        echo "Hardening nodes in cluster"
        . $REPO_PATH/harden.sh $SERVER_0&
        . $REPO_PATH/harden.sh $SERVER_1&
        . $REPO_PATH/harden.sh $SERVER_2&
        wait
    else
        echo "Not hardening cluster..."
    fi
fi

ssh -o StrictHostKeyChecking=accept-new $SSH_USER@$SERVER_0 "curl -sfL https://get.k3s.io | K3S_TOKEN=thisisahardpassword INSTALL_K3S_VERSION=$K8S_VERSION sh -s - server --cluster-init --node-name=initnode"

ssh -o StrictHostKeyChecking=accept-new $SSH_USER@$SERVER_1 "curl -sfL https://get.k3s.io | K3S_TOKEN=thisisahardpassword INSTALL_K3S_VERSION=$K8S_VERSION sh -s - server --server https://$SERVER_0:6443 --node-name=server1"&

ssh -o StrictHostKeyChecking=accept-new $SSH_USER@$SERVER_2 "curl -sfL https://get.k3s.io | K3S_TOKEN=thisisahardpassword INSTALL_K3S_VERSION=$K8S_VERSION sh -s - server --server https://$SERVER_0:6443 --node-name=server2"&
if [ $SSH_USER == "root" ]; then
    scp $REPO_PATH/.remote_script.sh $SSH_USER@$SERVER_0:/root/
    ssh $SSH_USER@$SERVER_0 "sudo su -c 'chmod 777 /root/.remote_script.sh && export SERVER_0=$SERVER_0 && export SERVER_1=$SERVER_1 && export SERVER_2=$SERVER_2 && . ./.remote_script.sh'"

else
    scp $REPO_PATH/.remote_script.sh $SSH_USER@$SERVER_0:/home/$SSH_USER/
    ssh $SSH_USER@$SERVER_0 "sudo su -c 'chmod 777 /home/$SSH_USER/.remote_script.sh && cd /home/$SSH_USER && export SERVER_0=$SERVER_0 && export SERVER_1=$SERVER_1 && export SERVER_2=$SERVER_2 && . ./.remote_script.sh'"
fi

wait

echo "getting kubeconfig from k3s"
ssh $SSH_USER@$SERVER_0 "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.k3s_kubeconfig.yaml
sed -i 's/127.0.0.1/'$SERVER_0'/g' ~/.k3s_kubeconfig.yaml
export KUBECONFIG=~/.k3s_kubeconfig.yaml

echo "installing certmanager on k3s cluster"
kubectl get nodes&
kubectl create namespace cattle-system&
kubectl create namespace cert-manager&
helm repo add jetstack https://charts.jetstack.io&
if [ -z "$(helm repo list | grep $HELM_NAME_RANCHER)" ]; then
    helm repo add $HELM_NAME_RANCHER $RANCHER_HELM_REPO&
    echo "added rancher helm repo"
fi
wait

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.15.2/cert-manager.crds.yaml

helm repo update

helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.15.2&

wait

echo "k3s cluster setup complete"
