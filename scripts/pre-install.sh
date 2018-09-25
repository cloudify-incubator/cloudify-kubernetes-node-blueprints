#!/bin/bash

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

setenforce 0

yum -t -y install docker-1.13.1 kubelet-1.9.6-0 kubeadm-1.9.6-0 kubectl-1.9.6-0 kubernetes-cni-0.6.0-0 ca-certificates

groupadd docker
# Override
usermod -aG docker ec2-user

update-ca-trust force-enable

swapon -s | awk '{print "sudo swapoff " $1}' | grep -v "Filename" | sh -

sed -i 's|cgroup-driver=systemd|cgroup-driver=systemd --provider-id='`hostname`'|g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet

iptables --flush
iptables -tnat --flush
mkdir -p /tmp/data
chcon -Rt svirt_sandbox_file_t /tmp/data
