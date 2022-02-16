terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">=2.8.0"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://${var.proxmox-host}:8006/api2/json"
  pm_user         = var.username
  pm_password     = var.password
  pm_tls_insecure = "true"
  pm_parallel     = 10
}

resource "proxmox_vm_qemu" "proxmox_vm_master" {
  count       = 1
  name        = var.vmname
  target_node = var.node
  clone       = var.tamplate_vm_name
  os_type     = "cloud-init"
  agent       = 1
  memory      = var.memory
  cores       = var.vcpu
  onboot      = var.onboot

  ipconfig0 = "ip=var.ip,gw=var.gateway"

}
