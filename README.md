# ansiblePlaybooks

Ansible playbooks for production and lab virtual machines. All plays utilize a Ubuntu 20.04 LTS LXC/KVM.

## Plays

### deploy_docker_infra.yml

Clone Ubuntu 24.04 template and install docker with the following services:

* Portainer
* Traefik
* Traefik Certs Dumper
* Dashy
* Vaultwarden
* SMTP Relay
* Snappass
* Authentik
* SMTP Relay

---

### deploy_docker_app.yml

Clone Ubuntu 24.04 template and install docker with the following services:

* Portainer Agent
* Nextcloud
* Photoprisim
* Paperless NGX
* HortusFox
* Plants
* Wedding


---

### deploy_plex.yml

Clone Ubuntu 20.04 LXC template and install Plex, configure nightly backups

---

### deploy_docker_frigate.yml

---

### deploy_downloader.yml

Clone Ubuntu 20.04 LXC KVM template, install docker with remote portainer support hosting the services:

- OpenVPN client
- qBittorrent
- Prowlarr
- Sonarr
- Lidarr
- Radarr
- Overseerr

## KVMTemplate Creation

adapted from https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/

Requirements

- the proxmox host requires libguestfs-tools installed
- a file `/root/id_ed25519.pub` exists containing the public key
- a file `/root/ansible` exists containing `ansible ALL=(ALL) NOPASSWD: ALL`

```console
#customize image
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img -O os.img
apt update -y && apt install libguestfs-tools net-tools -y
virt-customize -a os.img --install qemu-guest-agent
virt-customize -a os.img --run-command 'useradd --shell /bin/bash ansible'
virt-customize -a os.img --run-command 'usermod --password $(echo ansible | openssl passwd -1 -stdin) ansible'
virt-customize -a os.img --run-command 'mkdir -p /home/ansible/.ssh'
virt-customize -a os.img --ssh-inject ansible:file:/root/id_ed25519.pub
virt-customize -a os.img --run-command 'chown -R ansible:ansible /home/ansible'
virt-customize -a os.img --upload ansible:/etc/sudoers.d/ansible
virt-customize -a os.img --run-command 'chmod 0440 /etc/sudoers.d/ansible'
virt-customize -a os.img --run-command 'chown root:root /etc/sudoers.d/ansible'

#create template
qm create 9000 --name "ubuntu-2404-cloudinit-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 os.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --ide2 local-lvm:cloudinit
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

## Root CA Creation

```

# create root CA certificate conf file using cat <<EOF > root-ca.conf
cat <<EOF > root-ca.conf
[ req ]
distinguished_name = root_ca_dn
x509_extensions = v3_ca
prompt = no

[ root_ca_dn ]
C = US
ST = Kansas
L = Clown
O = Bob
CN = Root CA

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
EOF



# create conf file using cat <<EOF > vault-node.conf
cat <<EOF > vault-node.conf

[ req ]
distinguished_name = hcv_1
req_extensions = v3_req
prompt = no

[ hcv_1 ]
C = US
ST = Kansas
L = Clown
O = Bob
CN = hcv_1

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = hcv_1
DNS.2 = hcv_2
DNS.3 = hcv_3
IP.1 = 127.0.0.1
EOF


openssl ecparam -name prime256v1 -genkey -noout -out root-ca.key
openssl req -x509 -new -sha256 -key root-ca.key -config root-ca.conf -days 3650 -out root-ca.crt
openssl ecparam -name prime256v1 -genkey -noout -out vault-node.key
openssl req -new -sha256 -key vault-node.key -config vault-node.conf -out vault-node.csr
openssl x509 -req -in vault-node.csr -CA root-ca.crt -CAkey root-ca.key -CAcreateserial -extfile vault-node.conf -extensions v3_req -days 365 -out vault-node.crt
cat vault-node.crt root-ca.crt > vault-node-fullchain.crt
```