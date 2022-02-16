# proxmox-terraform-ansible-csgo
Deploy CSGO servers on a Proxmox server using Terraform, Ansible and Docker compose.

## Table of Contents  
[Prerequisite](#Prerequisite)  
[Pre-deployment configuration](https://github.com/deaumo/proxmox-terraform-ansible-csgo/blob/main/README.md#pre-deployment-configuration)  
[Set up VM template on Proxmox](https://github.com/deaumo/proxmox-terraform-ansible-csgo/blob/main/README.md#set-up-vm-template-on-proxmox)  
[Terraform configuration](https://github.com/deaumo/proxmox-terraform-ansible-csgo/blob/main/README.md#terraform-configuration)  
[Ansible configuration](https://github.com/deaumo/proxmox-terraform-ansible-csgo/blob/main/README.md#ansible-configuration)  
[CSGO variables ](https://github.com/deaumo/proxmox-terraform-ansible-csgo/blob/main/README.md#csgo-variables)  
[Deployment](https://github.com/deaumo/proxmox-terraform-ansible-csgo/blob/main/README.md#deployment)  
[VM Provisionning](https://github.com/deaumo/proxmox-terraform-ansible-csgo/blob/main/README.md#vm-provisionning)  
[VM Configuration](https://github.com/deaumo/proxmox-terraform-ansible-csgo/blob/main/README.md#vm-configuration)  
[Understanding tags](https://github.com/deaumo/proxmox-terraform-ansible-csgo/blob/main/README.md#understanding-tags)  
[Pre-configured CSGO Servers](https://github.com/deaumo/proxmox-terraform-ansible-csgo/blob/main/README.md#pre-configured-csgo-servers)  
[Usage](https://github.com/deaumo/proxmox-terraform-ansible-csgo/blob/main/README.md#pre-configured-csgo-servers#usage) 
[Network](https://github.com/deaumo/proxmox-terraform-ansible-csgo/blob/main/README.md#pre-configured-csgo-servers#network) 

## Prerequisite

Have terraform and ansible installed where you want to deploy and manage your infrastructure from. In my case, I went for a Ubuntu LXC instance for easier management. 

## Pre-deployment configuration

### Set up VM template on Proxmox

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

Define your user, password, DNS servers, and enter your SSH key from your terraform+ansible management host. You must then click "regenerate image" to apply changes. 

:information_source: I advise you to chose the same username both on your management host (the one with terraform+ansible installed) and on the target CSGO VM as it is how I configured it to be. 

:warning: Do not forget to resize the template disk accordingly to your needs ! For running 4 servers, I needed 200 GB. To achieve this go to hardware tab of the template, hard disk, resize, and specify an increment (the value will be added to predefined disk space). 

### Terraform configuration

Modify the vars.tf file according to your needs. The variables are self-explanatory and are accompanied by a description to help you figure it out. 

### Ansible configuration

In the ansible/setup.yml playbook file, define the variable username, the same you previously defined in the cloud-init section. 

You should also update the inventory.ini file. If the IP address of the future VM is 10.10.10.10, and your username is 'youruser', then your file has to look like this:
```
[csgo]
#Enter your VM IP here
10.10.10.10
[all:vars]
ansible_connection=ssh
ansible_user=youruser
```

### CSGO variables 

Define CSGO variables into files/.env file. This include public ip address for the srcds server, steam tokens, tickrate, and start maps. 

## Deployment 

### VM Provisionning

From proxmox-terraform-ansible-csgo/terraform directory:
```
terraform init
terraform apply
```
This will provision the pre-configured VM (according to your personalized variables) on to the proxmox host.

### VM Configuration

This time you need to locate yourself into the proxmox-terraform-ansible-csgo/ansible directory.

### Understanding tags
#### Pre-configured CSGO servers

| Number    | Type of server | Start Map    |
| --------- | -------------- | ------------ |
| csgo1     | Hostage        | cs_militia   |
| csgo2     | Armsrace       | de_bank      |
| csgo3     | Wingman        | de_lake      |
| csgo4     | Guardian       | gd_blacksite |

#### Usage

Let's say you want to deploy server 1 and 2 without server 3 and 4. You would go like this:
```
ansible-playbook setup.yml --skip-tags "csgo3,csgo4"
```
Skipping tags with the option --skip-tags will skip all tasks with the specified tags, in effect not deploying CSGO server 3 and 4.

After the playbook terminates, you need to wait for download, configuration and potentially updates to end. You can monitor the bandwith, cpu usage as well as the docker logs for indication: 
```
docker logs csgo1 --follow
```
### Network
You should, of course, open ports on your router, provided there is one in front of your VM. 
Here are the configured ports you need to allow passing through NATing : 

| Number    | Type of server | SRCDS Ports  | SRCDS TV Ports |
| --------- | -------------- | ------------ | -------------- |
| csgo1     | Hostage        | 27015        | 27020          |
| csgo2     | Armsrace       | 27016        | 27021          |
| csgo3     | Wingman        | 27017        | 27022          |
| csgo4     | Guardian       | 27018        | 27023          |
