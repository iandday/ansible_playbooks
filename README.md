# ansiblePlaybooks

Ansible playbooks for production and lab virtual machines. All plays utilize a Ubuntu 20.04 LTS LXC/KVM.

## Plays

### deploy_docker.yml

Clone Ubuntu 20.04 LTS KVM template, install Docker and Docker-Compose to run the following services

- Portainer
- Traefik
- Dashy
- Bitwarden
- Duo Auth Proxy
- SMTP Relay
- Watchtower
- Snappass
- GoDaddy DNS Updater
- Netflow Collector
- [Taiga](https://docs.taiga.io/)

---

### deploy_nextcloud.yml

Clone Ubuntu 20.04 LXC template, install Nextcloud, MariaDB, and Nginx

---

### deploy_plex.yml

Clone Ubuntu 20.04 LXC template and install Plex, configure nightly backups

---

### deploy_gitlab.yml

Clone Ubuntu 20.04 KVM template. Install Docker, Gitlab EE and Gitlab runner. Configure docker for remote adminstration over TLS.

### deploy_wiki.yml

Clone Ubuntu 20.04 LTS LXC template and install Dokuwiki and Nginx

### restore_wiki.yml

Restore wiki content and settings from backup

---

### deploy_music_server.yml

Clone Ubuntu 20.04 LXC template, install mopidy, snapcast server, and spotify connect client for distributed audio

---

### deploy_pihole.yml

Clone Ubuntu 20.04 LXC template, install PiHole and cloudflared for DoH, configure syslog-ng to export logs to syslog collector

---

### deploy_log_collector.yml

Clone Ubuntu 20.04 LXC template, install syslog-ng to collect logs from:

- OpnSense
- UnFi Controller
- PiHole

---

### deploy_splunk.yml

Clone Ubuntu 20.04 LXC template, install Splunk Enterprise using a NFS bind mount for bucket storage

### deploy_unifi.yml

Clone Ubuntu 20.04 LXC template, install UniFi controller

### deploy_downloader.yml

Clone Ubuntu 20.04 LXC KVM template, install docker with remote portainer support hosting the services:

- OpenVPN client
- qBittorrent
- Prowlarr
- Sonarr
- Lidarr
- Radarr
- Overseerr

## TODO

- Guacamole
- Backup rotation

## KVMTemplate Creation

adapted from https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/

Requirements

- the proxmox host requires libguestfs-tools installed
- a file `/root/id_ed25519.pub` exists containing the public key
- a file `/root/ansible` exists containing `ansible ALL=(ALL) NOPASSWD: ALL`

```console
#customize image
wget https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img
virt-customize -a ubuntu-24.04-server-cloudimg-amd64.img --update
virt-customize -a ubuntu-24.04-server-cloudimg-amd64.img --install qemu-guest-agent
virt-customize -a ubuntu-24.04-server-cloudimg-amd64.img --run-command 'useradd --shell /bin/bash ansible'
virt-customize -a ubuntu-24.04-server-cloudimg-amd64.img --run-command 'mkdir -p /home/ansible/.ssh'
virt-customize -a ubuntu-24.04-server-cloudimg-amd64.img --ssh-inject ansible:file:/root/id_ed25519.pub
virt-customize -a ubuntu-24.04-server-cloudimg-amd64.img --run-command 'chown -R ansible:ansible /home/ansible'
virt-customize -a ubuntu-24.04-server-cloudimg-amd64.img --upload /root/ansible:/etc/sudoers.d/ansible
virt-customize -a ubuntu-24.04-server-cloudimg-amd64.img --run-command 'chmod 0440 /etc/sudoers.d/ansible'
virt-customize -a ubuntu-24.04-server-cloudimg-amd64.img --run-command 'chown root:root /etc/sudoers.d/ansible'

#create template
qm create 9000 --name "ubuntu-2404-cloudinit-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm set 9000 --scsi0 iso:0,import-from=/root/ubuntu-24.04-server-cloudimg-amd64.img
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --ide2 iso:cloudinit
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent enabled=1
qm template 9000
```

## LXC Template Creation

https://www.chucknemeth.com/proxmox/lxc/lxc-template#create-the-template

list current templates 

`pveam list nas`

update container database 

`pveam update`

list available 

`pveam available | grep ubuntu`

download 

`pveam download nas ubuntu-22.04-standard_22.04-1_amd64.tar.zst`

create temp lxc via GUI

enter container

 `pct enter 111`

configure

`useradd --shell /bin/bash ansible`
`mkdir -p /home/ansible/.ssh`
`nano /home/ansible/.ssh/authorized_keys`
`chown -R ansible:ansible /home/ansible`
`chmod 0400 /home/ansible/.ssh/authorized_keys`
`chmod 0700 /home/ansible/.ssh/`
`echo "ansible ALL=(ALL) NOPASSWD: ALL chmod 0440" >> /etc/sudoers.d/ansible` 
`chmod 0440 /etc/sudoers.d/ansible`
`chown root:root /etc/sudoers.d/ansible`

exit container 

`exit`

delete NIC 

`pct set 111 --delete net0`

backup lxc 

`vzdump 111 --mode stop --compress gzip --dumpdir /mnt/nas/template/cache/`


rename template 

`mv vzdump-lxc-111-2023_05_13-12_17_07.tar.gz ubuntu-22.04-standard_22.04-1_amd64_ansible.tar.zst`
