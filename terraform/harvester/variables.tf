variable "SSH_KEY" {
  description = "your public ssh key"
  type = string
}

variable "DRLATEST_VM_PW" {
  description = "vm password for docker rancher latest vm"
  type = string
  sensitive = false
  default = "ubuntupw"
}

variable "DRLATEST_DESIRED_CPU" {
  description = "the desired cpu"
  type = number
  default = 2
}

variable "DRLATEST_DESIRED_MEM" {
  description = "the desired mem"
  type = string
  default = "4Gi"
}

variable "DRLATEST_DISK_SIZE" {
  description = "disk size"
  type = string 
  default = "20Gi"
}

variable "DRLATEST_NAME" {
  description = "docker rancher latest host name"
  type = string
  default = "docker-rancher-latest"
}

variable "NETWORK_NAME" {
  description = "name of VM Network to use that's already up in your harvester ENV"
  type = string
  default = "mgmt"
}

variable "IMAGE_ID" {
  description = "ID of pre-downloaded image to use for VMs"
  type = string
  default = "welp"
}