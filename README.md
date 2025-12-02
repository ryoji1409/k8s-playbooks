# Kubernetes Cluster Setup with Ansible
## Overview
This repository provides Ansible playbooks to build Kubernetes clusters and related middleware (HAProxy, Rancher).

## Features
- Kubernetes cluster creation, cluster upgrade, and node add/remove operations based on kubeadm
- Use HAProxy as the kube-apiserver load balancer
- Support for CNI plugin selection (Cilium, Flannel, Canal)
- Rancher management node setup
- Ansible is executed inside a container, so Ansible does not need to be installed on the host server

## Prerequisites
- Docker
- Ubuntu
- Make
- SSH connectivity
- sudo privileges on the target machines

## Setup & Run
### 1. Prepare inventory (e.g. inventory/development)
```
├── inventory
│   ├── development
│   │   ├── group_vars
│   │   │   ├── all.yml
│   │   │   ├── k8s.yml
│   │   │   └── rancher_admin.yml
│   │   └── inventory.ini
│   └── sample
│       ├── group_vars
│       │   ├── all.yml
│       │   ├── k8s.yml
│       │   └── rancher_admin.yml
│       └── inventory.ini
```
### 2. Build the container image
```bash
make build
```
### 3. Create `.env` file (SSH login configuration)
```
SSH_PW=your_ssh_password
SSH_KEY_PATH=your_key_absolute_path
```
### 4. Run the container
```bash
make run
```
### 5. Setup SSH agent inside the container
```bash
source script/ssh-add.sh
```
## Execution Examples (inside container)
* Setup public SSH key to remote server
  ```bash
  ansible-playbook -i inventory/development/inventory.ini playbooks/setup-ssh-keys.yml \
    --ask-become-pass --ask-pass \
    -u <your_remote_user> -e "user=user" -e "key=~/.ssh/id_ed25519.pub"
  ```
* Run this command on all hosts to confirm their IP addresses
  ```bash
  ansible all -i inventory/development/inventory.ini -m shell -a "hostname -I" \
    -b --ask-become-pass -u <your_remote_user>
  ```
### Kubeadm
* Kubernetes node setup
  ```bash
  ansible-playbook -i inventory/development/inventory.ini playbooks/kubeadm/setup-k8s-node.yml \
    --ask-become-pass -u <your_remote_user>
  ```
* Build HAProxy for kube-apiserver load balancer
  ```bash
  ansible-playbook -i inventory/development/inventory.ini playbooks/setup-haproxy.yml \
    --ask-become-pass -u <your_remote_user>
  ```
* Kubernetes cluster creation
  * CNI plugin: cilium
      ```bash
      ansible-playbook -i inventory/development/inventory.ini playbooks/kubeadm/create-k8s-cluster.yml \
        --ask-become-pass -u <your_remote_user> -e cni=cilium
      ```
  * CNI plugin: flannel
      ```bash
      ansible-playbook -i inventory/development/inventory.ini playbooks/kubeadm/create-k8s-cluster.yml \
        --ask-become-pass -u <your_remote_user> -e cni=flannel
      ```
  * CNI plugin: canal
      ```bash
      ansible-playbook -i inventory/development/inventory.ini playbooks/kubeadm/create-k8s-cluster.yml \
        --ask-become-pass -u <your_remote_user> -e cni=canal
      ```
      * Specify `--tags cni` to deploy only the CNI plugin.
* Kubernetes cluster upgrade
  1. Upgrade the first control plane node (e.g. upgrade to v1.33.3)
      ```bash
      ansible-playbook -i inventory/development/inventory.ini playbooks/kubeadm/upgrade-k8s-cluster.yml \
        --ask-become-pass -l kube_control_plane[0] --tags first-control-plane-node,upgrade \
        -u <your_remote_user> -e apply_k8s_version=v1.33.3
      ```
  1. Upgrade the other control plane nodes (e.g. upgrade to v1.33.3)
      ```bash
      ansible-playbook -i inventory/development/inventory.ini playbooks/kubeadm/upgrade-k8s-cluster.yml \
        --ask-become-pass -l kube_control_plane,\!kube_control_plane[0] --tags other-node,upgrade \
        -u <your_remote_user> -e apply_k8s_version=v1.33.3
      ```
  1. Upgrade the worker nodes (e.g. upgrade to v1.33.3)
      ```bash
      ansible-playbook -i inventory/development/inventory.ini playbooks/kubeadm/upgrade-k8s-cluster.yml \
        --ask-become-pass -l kube_node --tags other-node,upgrade \
        -u <your_remote_user> -e apply_k8s_version=v1.33.3
      ```
* Add nodes
  ```bash
  ansible-playbook -i inventory/development/inventory.ini playbooks/kubeadm/join-nodes.yml \
    --ask-become-pass -u <your_remote_user> -l control_plane02,node04
  ```
* Remove nodes
  ```bash
  ansible-playbook -i inventory/development/inventory.ini playbooks/kubeadm/remove-nodes.yml \
    --ask-become-pass -u <your_remote_user> -l control_plane02,node04
  ```
* Destroy cluster
  1. Reset and remove all nodes except the initial control plane node
      ```bash
      ansible-playbook -i inventory/development/inventory.ini playbooks/kubeadm/remove-nodes.yml \
        --ask-become-pass -u <your_remote_user>
      ```
  1. Reset the initial control plane node
      ```bash
      ansible-playbook -i inventory/development/inventory.ini playbooks/kubeadm/remove-control_plane01.yml \
        --ask-become-pass -u <your_remote_user>
      ```
### Rancher(RKE2)
* Rancher management node setup
  ```bash
  ansible-playbook -i inventory/development/inventory.ini playbooks/rancher/run-rancher-admin-node.yml \
    --ask-become-pass -u <your_remote_user>
  ```
* Kubernetes node setup
  ```bash
  ansible-playbook -i inventory/development/inventory.ini playbooks/rancher/setup-rke2-k3s-nodes.yml \
    --ask-become-pass -u <your_remote_user>
  ```
* Kubernetes cluster creation
  ```bash
  ansible-playbook -i inventory/development/inventory.ini playbooks/rancher/create-k8s-cluster.yml \
    --ask-become-pass -u <your_remote_user> -e "rancher_api_token=<token>"
  ```
* Add Rancher users
  ```bash
  ansible-playbook -i inventory/development/inventory.ini playbooks/rancher/add-rancher-user.yml \
    --ask-become-pass -u <your_remote_user> -e "rancher_api_token=<token>"
  ```
* Create Rancher projects
  ```bash
  ansible-playbook -i inventory/development/inventory.ini playbooks/rancher/create-project.yml \
    --ask-become-pass -u <your_remote_user> -e "rancher_api_token=<token>"
  ```
* Manage project members
  ```bash
  ansible-playbook -i inventory/development/inventory.ini playbooks/rancher/manage-project-members.yml \
    --ask-become-pass -u <your_remote_user> -e "rancher_api_token=<token>"
  ```
* Manage role templates
  ```bash
  ansible-playbook -i inventory/development/inventory.ini playbooks/rancher/manage-roletemplates.yml \
    --ask-become-pass -u <your_remote_user> -e "rancher_api_token=<token>"
  ```
* Cleaning up nodes (except the initial control plane node)
  ```bash
  ansible-playbook -i inventory/development/inventory.ini playbooks/rancher/clean-nodes.yml \
    --ask-become-pass -u <your_remote_user> -l node03,node04
  ```
* Cleaning up the initial control plane node
  ```bash
  ansible-playbook -i inventory/development/inventory.ini playbooks/rancher/clean-control_plane01.yml \
    --ask-become-pass -u <your_remote_user>
  ```
