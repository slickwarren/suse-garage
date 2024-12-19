# resource "harvester_clusternetwork" "cluster-vlan" {
#   name = "auto-vlan"
# }

# resource "harvester_vlanconfig" "cluster-vlan-node1" {
#   name = "cluster-vlan-node1"

#   cluster_network_name = harvester_clusternetwork.cluster-vlan.name

#   uplink {
#     nics = [
#       "eno50"
#     ]

#     bond_mode = "active-backup"
#     mtu       = 1500
#   }
# }

# resource "harvester_network" "mgmt-vlan1-drlatest" {
#   name      = "mgmt-vlan1-drlatest"
#   namespace = "default"

#   vlan_id = 2011

#   route_mode           = "auto"
#   route_dhcp_server_ip = ""

#   cluster_network_name = var.NETWORK_NAME
# }

# resource "harvester_image" "ubuntu2204-jammy-drlatest" {
#   name      = "ubuntu-2204-drlatest"
#   namespace = "default"
#   storage_class_name = "harvester-longhorn"
#   display_name = "jammy-server-cloudimg-amd64-disk-kvm-drlatest.img"
#   source_type  = "download"
#   url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img"
# }


resource "harvester_ssh_key" "drlatest-ssh-key" {
  name      = "drlatest-ssh-key"
  namespace = "default"

  public_key = var.SSH_KEY
}

locals {
  cloud_init_drlatest = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - qemu-guest-agent
    runcmd:
      - - systemctl
        - enable
        - --now
        - qemu-guest-agent.service
    ssh_authorized_keys:
      - ${var.SSH_KEY}
    EOT
}

resource "kubernetes_secret" "drlatest-cloud-config-secret" {
  metadata {
    name      = "drlatest-cc-secret"
    namespace = "default"
    labels = {
      "sensitive" = "false"
    }
  }
  data = {
    "userdata" = local.cloud_init_drlatest
  } 
}

resource "harvester_virtualmachine" "drlatest-vm" {
  for_each = {1: "1", 2: "2", 3: "3"}

  depends_on = [
    kubernetes_secret.drlatest-cloud-config-secret
  ]
  name                 = "${var.DRLATEST_NAME}${each.value}"
  namespace            = "default"
  restart_after_update = true

  description = "Caleb Testing"
  tags = {
    ssh-user = "ubuntu"
  }

  cpu    = var.DRLATEST_DESIRED_CPU
  memory = var.DRLATEST_DESIRED_MEM

  efi         = true
  secure_boot = false

  run_strategy = "RerunOnFailure"
  hostname     = var.DRLATEST_NAME
  machine_type = "q35"

  ssh_keys = [
    harvester_ssh_key.drlatest-ssh-key.id
  ]

  network_interface {
    name           = "nic-1"
    wait_for_lease = true
    model = "virtio"
    type = "bridge"
    network_name = var.NETWORK_NAME
  }

  disk {
    name       = "rootdisk"
    type       = "disk"
    size       = var.DRLATEST_DISK_SIZE
    bus        = "virtio"
    boot_order = 1

    image       = var.IMAGE_ID
    auto_delete = true
  }

  cloudinit {
    user_data_secret_name = "drlatest-cc-secret"
    network_data = ""
  }
}