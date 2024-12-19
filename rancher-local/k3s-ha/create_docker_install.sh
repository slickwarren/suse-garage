#! /bin/bash


ssh -o StrictHostKeyChecking=accept-new $SSH_USER@$SERVER_0 "ls -la"

echo "Not hardening cluster..."

ssh -o StrictHostKeyChecking=accept-new $SSH_USER@$SERVER_0 "curl https://releases.rancher.com/install-docker/26.0.sh | sh"

ssh -o StrictHostKeyChecking=accept-new $SSH_USER@$SERVER_0 "sudo usermod -aG docker ubuntu"
ssh -o StrictHostKeyChecking=accept-new $SSH_USER@$SERVER_0 "docker run -d --restart=unless-stopped --privileged -p 80:80 -p 443:443 -e CATTLE_BOOTSTRAP_PASSWORD=$RANCHER_PASSWORD rancher/rancher:$VERSION --trace"

sleep 60

jsonOutput=$(curl --insecure -d "$(printf '{"username" : "admin", "password" : "%s", "responseType" : "json"}' "$RANCHER_PASSWORD")" https://$SERVER_0.sslip.io/v3-public/localproviders/local?action=login)

token=$(echo $jsonOutput | jq -cr .token)
userID=$(echo $jsonOutput | jq -cr .userId)

jsonData=$( jq -n --arg password "$RANCHER_PASSWORD" '{"newPassword" : $password}')
curl --insecure --user "$token" -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d "$jsonData" https://$SERVER_0.sslip.io/v3/users/$userID?action=setpassword

jsonData=$( jq -n --arg server "https://$SERVER_0.sslip.io" '{"name": "server-url", "value": $server}')
curl --insecure --user "$token" -X PUT -H 'Accept: application/json' -H 'Content-Type: application/json' -d "$jsonData" https://$SERVER_0.sslip.io/v3/settings/server-url

echo https://$SERVER_0.sslip.io
echo $RANCHER_PASSWORD

echo $token
