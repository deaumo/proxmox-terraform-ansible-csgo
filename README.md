# proxmox-terraform-ansible-csgo
Deploy CSGO servers on a Proxmox server using Terraform, Ansible and Docker

## Prerequisite

Have terraform and ansible installed where you want to deploy and manage your infrastructure from. In my case, I went for a Ubuntu LXC instance for easier management. 

## Proxmox configuration

### Set up VM template

In this part we will set up a Ubuntu template on our Proxmox server.

What you need: 
- What bridge will the VM be connected to ?
- What is the IP address of the VM going to be ?
- How many CSGO servers do you want to run ? (needed for compute and disk space dimensionning) 

The following commands on display will be adapted to my case. Change accordingly to your needs. My bridge will be vmbr3. I will run 4 CSGO servers on this VM, therefore I need at least 200 GB of disk space. On my server, I set 8vcpu for servers to spin up faster. (vcpus will be set in the terraform part). 4 GB of RAM seems to be enough.

On our PVE host I run the following to create a template: 
```
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
virt-customize -a focal-server-cloudimg-amd64.img --install qemu-guest-agent
qm create 9000 --name "ubuntu-focal-cloudinit-template" --memory 4096 --net0 virtio,bridge=vmbr3
mv focal-server-cloudimg-amd64.img focal-server-cloudimg-amd64.qcow2
qm importdisk 9000 focal-server-cloudimg-amd64.qcow2 local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm template 9000
```
Next go to your template, cloud-init tab. 

![image](https://user-images.githubusercontent.com/96586524/154258805-6d763a62-e1bb-4c65-b93b-ba4020ff94de.png)

Define your user, password, DNS servers, and enter your SSH key from your terraform+ansible management host. 

## Terraform configuration

Modify the vars.tf file according to your needs. The variables are self-explanatory and are accompanied by a description to help you figure it out. 

## CSGO variables 
