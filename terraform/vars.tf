# PROXMOX SETTINGS 

variable "username" {
  description = "The username for the proxmox user"
  type        = string
  sensitive = false
  default = "root@pam"
  
}
variable "password" {
  description = "The password for the proxmox user"
  type        = string
  sensitive = true
  default = "Y0urP@ssword"
}

variable "proxmox-host" {
  description = "proxmox host address here"
  type        = string
  default = "pve.example.com"  
}

# VM SETTINGS

variable "vmname" {
  description = "name of the VM to deploy for CSGO"
  default = "csgo"
}

variable "node" {
  description = "proxmox node on which to deploy the VM"
  default = "pve"
}

variable "vcpu" {
  description = "How many virtual cpus allocated to the VM"
 default = 8
}

variable "memory" {
  description = "RAM allocated to the VM in MB - 2GB = 2048, 4GB = 4096, 8GB = 8192, etc."
  default = "4096"
}

variable "tamplate_vm_name" {
  description = "name of the template to clone from"
  default = "ubuntu-focal-cloudinit-csgo-template"
}

variable "onboot" {
  description = "whether or not to automatically start the VM with the proxmox host (options > "start at boot" setting in VM)"
  default = "true"
}

variable "ip" {
  description = "set VM ip address here"
  default = "10.10.10.10"
}

variable "gateway" {
  description = "set VM gateway address here"
  default = "10.10.10.1"
}
