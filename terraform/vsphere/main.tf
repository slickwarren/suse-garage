terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
    }
  }
}

#Provider settings
provider "vsphere" {
  user 			= var.vsphere_user
  password		= var.vsphere_password
  vsphere_server	= var.vsphere_server
  allow_unverified_ssl	= true
}

#Data sources

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_host" "hosts" {
  name			= var.vsphere_host
  datacenter_id		= data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name			= var.vsphere_datastore
  datacenter_id         = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name			= var.vsphere_network
  datacenter_id		= data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name			= var.vm_template_name
  datacenter_id         = data.vsphere_datacenter.dc.id
}

# Define your resource pool
data "vsphere_resource_pool" "rp" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

#Resource
resource "vsphere_virtual_machine" "vm" {
  for_each 		= var.vms

  datastore_id		= data.vsphere_datastore.datastore.id
  resource_pool_id	= data.vsphere_resource_pool.rp.id
  guest_id		= var.vm_guest_id

  network_interface {
    network_id 		= data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  name 			= each.value.name
  
  num_cpus 		= var.vm_vcpu
  memory		= var.vm_memory
  firmware		= var.vm_firmware 
  disk {
    label		= var.vm_disk_label
    size		= var.vm_disk_size
    thin_provisioned	= var.vm_disk_thin
  }


  clone {
    template_uuid       = data.vsphere_virtual_machine.template.id
    # customize {
    #   linux_options {
    #     host_name       = each.value.name
    #     domain = ""
    #     script_text = <<-SCRIPT
    #       #!/bin/bash
    #       mkdir -p /home/ubuntu/.ssh
    #       echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFUv+k+U70vTe/fR13CBmu+zqYs4GwcN62PiCp8TLEr" > /home/ubuntu/.ssh/authorized_keys
    #       chmod 600 /home/ubuntu/.ssh/authorized_keys
    #       chown -R ubuntu:ubuntu /home/ubuntu/.ssh
    #     SCRIPT
    #   }
    #   network_interface {
    #     ipv4_address	= each.value.vm_ip
    #     ipv4_netmask	= var.vm_ipv4_netmask
    #     dns_server_list	= var.vm_dns_servers
    #   }
    #   ipv4_gateway = var.vm_ipv4_gateway
#    }
  }

  cdrom {
    client_device = true
  }
  extra_config = {
    "guestinfo.ssh_key" = var.public_ssh_key 
  }
 }



#Provider -  VMware vSphere Provider

variable "vsphere_user" { 
  description = "vSphere username to use to connect to the environment"
}

variable "vsphere_password" {
  description = "vSphere password to use to connect to the environment"
}

variable "vsphere_server" {
  description = "vCenter server FQDN or IP"
}

variable "vsphere_resource_pool" {
  description = "resource pool in vsphere"
}

# Infrastructure - vCenter / vSPhere environment
variable "public_ssh_key" {
  description = "public ssh key to add to all nodes"
}

variable "vsphere_datacenter" {
  description = "vSphere datacenter in which the virtual machine will be deployed"
}

variable "vsphere_host" {
  description = "vSphere ESXi host FQDN or IP" 
}

variable "vsphere_compute_cluster" { 
  description = "vSPhere cluster in which the virtual machine will be deployed"
}

variable "vsphere_datastore" {
  description = "Datastore in which the virtual machine will be deployed"
}

variable "vsphere_network" {
  description = "Portgroup to which the virtual machine will be connected"
}

variable "vm_firmware" {
  description = "Firmware of virtual machine, if templates is different from default"
}

#VM

variable "vm_template_name" {
  description = "VM template with vmware-tools and perl installed"
}

variable "vm_guest_id" {
  description = "VM guest ID"
}

variable "vm_vcpu" {
  description = "The number of virtual processors to assign to this virtual machine."
  default = "1"
}

variable "vm_memory" {
  description = "The size of the virtual machine's memory in MB"
  default = "1024"
}

# variable "vm_ipv4_netmask" {
#   description = "The IPv4 subnet mask"
# }

# variable "vm_ipv4_gateway" {
#   description = "The IPv4 default gateway"
# }

# variable "vm_dns_servers" {
#   description = "The list of DNS servers to configure on the virtual machine"
# }

variable "vms" {
  type = map(any)
  description = "List of virtual machines to be deployed"
}

variable "vm_disk_label" {
  description = "Disk label of the created virtual machine"
}

variable "vm_disk_size" {
  description = "Disk size of the created virtual machine in GB"
}

variable "vm_disk_thin" {
  description = "Disk type of the created virtual machine , thin or thick"
}