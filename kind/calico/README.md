# Calico Setup

## Create a Cluster with the following command:

```bash
kind create cluster --name calico --config calico-kind.yaml 
```
See page for details: https://alexbrand.dev/post/creating-a-kind-cluster-with-calico-networking/


## Install Calico Operator:

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/custom-resources.yaml
```
See page for details: https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart