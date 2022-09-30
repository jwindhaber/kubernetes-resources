#!/bin/bash

### init k8s
rm /root/.kube/config || true
kubeadm init --kubernetes-version=${KUBE_VERSION} --apiserver-advertise-address=$MASTER_IP --ignore-preflight-errors=NumCPU --skip-token-print --pod-network-cidr $POD_NW_CIDR 

mkdir -p ~/.kube
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config


### TODO this should be changed to the newer version sourced directly from calico
# https://projectcalico.docs.tigera.io/getting-started/kubernetes/flannel/flannel
# kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/canal.yaml
# be aware of the pod-network-cidr if its not 10.244.0.0/16 than the yaml has to be changed => maybe better go with the default

### CNI
kubectl apply -f https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/calico.yaml


# Vagrant requires the first network device attached to the virtual machine to be a NAT device.
# The NAT device is used for port forwarding, which is how Vagrant gets SSH access to the virtual machine.
# https://www.oreilly.com/library/view/vagrant-up-and/9781449336103/ch04.html
kubectl get cm -n kube-system canal-config -o yaml | sed 's/\(canal_iface: \).*$/\1:eth1/' | kubectl replace -f -
kubectl -n kube-system set env daemonsets.apps/canal --containers="calico-node" IP_AUTODETECTION_METHOD=interface=eth1
kubectl -n kube-system get daemonsets.apps/canal -o json | jq '.spec.template.spec.containers[] | select(.name=="kube-flannel").command |=.+ ["--iface=eth1"]' | kubectl apply -f -



# etcdctl
ETCDCTL_VERSION=v3.5.1
ETCDCTL_VERSION_FULL=etcd-${ETCDCTL_VERSION}-linux-amd64
wget https://github.com/etcd-io/etcd/releases/download/${ETCDCTL_VERSION}/${ETCDCTL_VERSION_FULL}.tar.gz
tar xzf ${ETCDCTL_VERSION_FULL}.tar.gz
mv ${ETCDCTL_VERSION_FULL}/etcdctl /usr/bin/
rm -rf ${ETCDCTL_VERSION_FULL} ${ETCDCTL_VERSION_FULL}.tar.gz

echo
echo "### COMMAND TO ADD A WORKER NODE ###"
# writes token into file for the worker to pick it up for joining the cluster
kubeadm token create --print-join-command --ttl 0 > /vagrant/tmp/master-join-command.sh