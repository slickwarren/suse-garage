output "ip" {
  # value = <<-EOF
  #   Hello!
  #   Docker Rancher Latest is FINISHED Provisioning, hooray!
  #   It is up at: ${harvester_virtualmachine.drlatest-vm.network_interface[0].ip_address}
  #   With the respective ports open of: 80 & 443
  #   Also!
  #   The VM's SSH User is: ubuntu
  #   With the password of: ${var.DRLATEST_VM_PW}
  #   You'll still want to get the bootstrapd password for Rancher Latest via something like:
  #   ```
  #   ssh-keygen -f ~/.ssh/known_hosts -R "${harvester_virtualmachine.drlatest-vm.network_interface[0].ip_address}"
  #   ssh -oStrictHostKeyChecking=no ubuntu@${harvester_virtualmachine.drlatest-vm.network_interface[0].ip_address} 
  #   sudo su
  #   # NOTE: you may need to re-run this a few times, so possibly firing a loop, and just hitting cntrl+c when you see it: 
  #   for i in {1..65}; do echo "on $i iteration, searching logs for bootstrap password..."; docker logs $(docker ps | tail -1 | sed -e 's/ .*$//g')| grep -e "Bootstrap Password:"; sleep 1; done
  #   ```
  # EOF
  value = [for vm in harvester_virtualmachine.drlatest-vm : vm.network_interface[0].ip_address] 

}