#! /bin/bash


if [ $HELM_NAME_RANCHER = "staging-prime" ]; then
    helm install rancher $HELM_NAME_RANCHER/rancher --version $RANCHER_CHART_VERSION --namespace cattle-system --set bootstrapPassword=admin --set hostname=$SERVER_0.sslip.io  --set rancherImageTag=$VERSION --set rancherImage=$RANCHER_REPO/$RANCHER_IMAGE --set 'extraEnv[0].name=CATTLE_AGENT_IMAGE' --set \'extraEnv[0].value=$RANCHER_REPO/rancher-agent:$RANCHER_IMAGE_CHART_TAG\' --set 'extraEnv[1].name=RANCHER_PRIME' --set \"extraEnv[1].value='true'\" --set 'extraEnv[2].name=CATTLE_UI_BRAND' --set 'extraEnv[2].value=suse'&

else
    helm install rancher $HELM_NAME_RANCHER/rancher --version $RANCHER_CHART_VERSION --namespace cattle-system --set bootstrapPassword=admin --set hostname=$SERVER_0.sslip.io  --set rancherImageTag=$VERSION --set rancherImage=$RANCHER_REPO/$RANCHER_IMAGE&
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

echo https://$SERVER_0.sslip.io
echo $RANCHER_PASSWORD

echo $token
