
resource "random_string" "random_suffix" {
  length  = 3
  special = false
  upper   = false
}

resource "harvester_ssh_key" "drlatest-ssh-key" {
  name      = "drlatest-ssh-key-${random_string.random_suffix.result}"
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
    name      = "drlatest-cc-secret-${random_string.random_suffix.result}"
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
  name                 = "${var.DRLATEST_NAME}${each.value}-${random_string.random_suffix.result}"
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
  hostname     = "${var.DRLATEST_NAME}${each.value}-${random_string.random_suffix.result}"
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
    user_data_secret_name = "drlatest-cc-secret-${random_string.random_suffix.result}"
    network_data = ""
  }
}