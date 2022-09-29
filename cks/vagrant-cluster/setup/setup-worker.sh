#!/bin/bash

### init k8s
kubeadm reset -f
systemctl daemon-reload
service kubelet start

echo "### executes join command to join the cluster ###"
sh /vagrant/tmp/master-join-command.sh
