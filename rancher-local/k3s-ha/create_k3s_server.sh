#!/bin/bash

ssh $SSH_USER@$SERVER_0 "ls -la"
ssh $SSH_USER@$SERVER_1 "ls -la"
ssh $SSH_USER@$SERVER_2 "ls -la"

ssh $SSH_USER@$SERVER_0 "curl -sfL https://get.k3s.io | K3S_TOKEN=thisisahardpassword INSTALL_K3S_VERSION=$K8S_VERSION sh -s - server --cluster-init --node-name=initnode"

ssh $SSH_USER@$SERVER_1 "curl -sfL https://get.k3s.io | K3S_TOKEN=thisisahardpassword INSTALL_K3S_VERSION=$K8S_VERSION sh -s - server --server https://$SERVER_0:6443 --node-name=server1"&

ssh $SSH_USER@$SERVER_2 "curl -sfL https://get.k3s.io | K3S_TOKEN=thisisahardpassword INSTALL_K3S_VERSION=$K8S_VERSION sh -s - server --server https://$SERVER_0:6443 --node-name=server2"&
if [ $SSH_USER == "root" ]; then
    scp ~/.remote_script.sh $SSH_USER@$SERVER_0:/root/
    ssh $SSH_USER@$SERVER_0 "sudo su -c 'chmod 777 /root/.remote_script.sh && export SERVER_0=$SERVER_0 && export SERVER_1=$SERVER_1 && export SERVER_2=$SERVER_2 && . ./.remote_script.sh'"

else
    scp ~/.remote_script.sh $SSH_USER@$SERVER_0:/home/$SSH_USER/
    ssh $SSH_USER@$SERVER_0 "sudo su -c 'chmod 777 /home/$SSH_USER/.remote_script.sh && cd /home/$SSH_USER && export SERVER_0=$SERVER_0 && export SERVER_1=$SERVER_1 && export SERVER_2=$SERVER_2 && . ./.remote_script.sh'"
fi

wait

ssh $SSH_USER@$SERVER_0 "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.k3s_kubeconfig.yaml
sed -i 's/127.0.0.1/'$SERVER_0'/g' ~/.k3s_kubeconfig.yaml
export KUBECONFIG=~/.k3s_kubeconfig.yaml

kubectl get nodes&
kubectl create namespace cattle-system&
kubectl create namespace cert-manager&
helm repo add jetstack https://charts.jetstack.io&
if [ -z "$(helm repo list | grep $HELM_NAME_RANCHER)" ]; then
    helm repo add $HELM_NAME_RANCHER $RANCHER_HELM_REPO&
fi

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml
wait

helm repo update

helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.11.0&

if [ $HELM_NAME_RANCHER = "staging-prime" ]; then
    helm install rancher $HELM_NAME_RANCHER/rancher --version $VERSION --namespace cattle-system --set bootstrapPassword=admin --set hostname=$SERVER_0.sslip.io  --set rancherImageTag=$RANCHER_IMAGE --set rancherImage=$RANCHER_REPO --set 'extraEnv[0].name=CATTLE_AGENT_IMAGE' --set \'extraEnv[0].value=stgregistry.suse.com/rancher/rancher-agent:$RANCHER_IMAGE\' --set 'extraEnv[1].name=RANCHER_PRIME' --set \"extraEnv[1].value='true'\" --set 'extraEnv[2].name=CATTLE_UI_BRAND' --set 'extraEnv[2].value=suse'&

else
    helm install rancher $HELM_NAME_RANCHER/rancher --version $VERSION --namespace cattle-system --set bootstrapPassword=admin --set hostname=$SERVER_0.sslip.io  --set rancherImageTag=$RANCHER_IMAGE --set rancherImage=$RANCHER_REPO 
fi
wait

kubectl -n cattle-system rollout status deploy/rancher

jsonOutput=$(curl --insecure -d '{"username" : "admin", "password" : "admin", "responseType" : "json"}'  https://$SERVER_0.sslip.io/v3-public/localproviders/local?action=login)

token=$(echo $jsonOutput | jq -cr .token)
userID=$(echo $jsonOutput | jq -cr .userId)

jsonData=$( jq -n --arg password "$RANCHER_PASSWORD" '{"newPassword" : $password}')
curl --insecure --user "$token" -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d "$jsonData" https://$SERVER_0.sslip.io/v3/users/$userID?action=setpassword

jsonData=$( jq -n --arg server "https://$SERVER_0.sslip.io" '{"name": "server-url", "value": $server}')
curl --insecure --user "$token" -X PUT -H 'Accept: application/json' -H 'Content-Type: application/json' -d "$jsonData" https://$SERVER_0.sslip.io/v3/settings/server-url

echo $SERVER_0.sslip.io
echo $RANCHER_PASSWORD

echo $token
