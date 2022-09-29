#!/bin/bash

### init k8s
rm /root/.kube/config || true
kubeadm init --kubernetes-version=${KUBE_VERSION} --apiserver-advertise-address=$MASTER_IP --ignore-preflight-errors=NumCPU --skip-token-print --pod-network-cidr $POD_NW_CIDR 

mkdir -p ~/.kube
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config

### CNI
kubectl apply -f https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/calico.yaml


# etcdctl
ETCDCTL_VERSION=v3.5.1
ETCDCTL_VERSION_FULL=etcd-${ETCDCTL_VERSION}-linux-amd64
wget https://github.com/etcd-io/etcd/releases/download/${ETCDCTL_VERSION}/${ETCDCTL_VERSION_FULL}.tar.gz
tar xzf ${ETCDCTL_VERSION_FULL}.tar.gz
mv ${ETCDCTL_VERSION_FULL}/etcdctl /usr/bin/
rm -rf ${ETCDCTL_VERSION_FULL} ${ETCDCTL_VERSION_FULL}.tar.gz

# replace the canal interface to not pick the default but the given eth1 interface, since the default is the virtualbox virtual network
kubectl get cm -n kube-system canal-config -o yaml | sed 's/\(canal_iface: \).*$/\1:eth1/' | kubectl replace -f -
# add the IP_AUTODETECTION_METHOD env variable to signal calico to not take the default interface from virtualbox
kubectl -n kube-system set env daemonsets.apps/canal IP_AUTODETECTION_METHOD=eth1

echo
echo "### COMMAND TO ADD A WORKER NODE ###"
# writes token into file for the worker to pick it up for joining the cluster
kubeadm token create --print-join-command --ttl 0 > /vagrant/tmp/master-join-command.sh