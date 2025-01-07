#! /bin/bash

export REPO_PATH=$(realpath $(dirname ${BASH_SOURCE[0]})) 

. $REPO_PATH/e2e.env

cd $REPO_PATH/../../terraform/$PROVIDER
terraform init
terraform apply --auto-approve

. $REPO_PATH/ips_from_terraform.sh
cd $REPO_PATH

eval `ssh-agent -s`

ssh-add -k $SSH_PATH

wait-for-ssh()
{
  export server0Access=1
  export server1Access=1
  export server2Access=1
  export connectionRefused="Connection refused"
  while (( $server0Access != 0 && $server1Access != 0 && $server2Access != 0 ));
  do
    if [[ $server0Access != 0 ]]; then
      export sshOutput=$(ssh -i $SSH_KEY_PATH -o StrictHostKeyChecking=accept-new $SSH_USER@$SERVER_0 "ls -la" 2>&1)
      if [[ $sshOutput != *"$connectionRefused"* ]]; then
        export server0Access=0
        continue;
      fi
    fi

    if [[ $server1Access != 0 ]]; then
      export sshOutput=$(ssh -i -o StrictHostKeyChecking=accept-new $SSH_KEY_PATH $SSH_USER@$SERVER_1 "ls -la" 2>&1)
      if [[ $sshOutput != *"$connectionRefused"* ]]; then
        export server1Access=0
        continue;
      fi
    fi


    if [[ $server2Access != 0 ]]; then
      export sshOutput=$(ssh -i -o StrictHostKeyChecking=accept-new $SSH_KEY_PATH $SSH_USER@$SERVER_2 "ls -la" 2>&1)
      if [[ $sshOutput != *"$connectionRefused"* ]]; then
        export server2Access=0
        continue;
      fi
    fi
  done
  sleep 20
  echo "K3s Server Nodes ready for ssh"
}

wait-for-ssh

. $REPO_PATH/create_k3s_server.sh
. $REPO_PATH/install_rancher_on_cluster.sh