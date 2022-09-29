#!/bin/bash

echo 'Installing NGINX ingress controller'

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
echo 'Waiting for Ingress to get ready'
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s


echo 'Installing Tekton Pipelines'
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml


echo 'Installing Tekton Triggers'
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml


echo 'Waiting for Tekton Pipelines to get ready'
kubectl wait -n tekton-pipelines --for=condition=ready pod  --selector=app.kubernetes.io/part-of=tekton-pipelines,app.kubernetes.io/component=controller --timeout=90s


echo 'Installing Tekton Dashboard'
curl -sL https://raw.githubusercontent.com/tektoncd/dashboard/main/scripts/release-installer |  bash -s -- install latest


echo 'Waiting for Tekton Dashboard to get ready'
kubectl wait -n tekton-pipelines --for=condition=ready pod  --selector=app.kubernetes.io/part-of=tekton-dashboard,app.kubernetes.io/component=dashboard  --timeout=90s


echo 'Setting up an Ingress rule to access the Dashboard'
kubectl apply -n tekton-pipelines -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tekton-dashboard
spec:
  rules:
  - host: tekton-dashboard.127.0.0.1.nip.io
    http:
      paths:
      - pathType: ImplementationSpecific
        backend:
          service:
            name: tekton-dashboard
            port:
              number: 9097
EOF