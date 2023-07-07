# Some useful stuff for this lesson

first you have to install the ingress controller:

https://kubernetes.github.io/ingress-nginx/deploy/

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Looking up the ingress class
k -n ingress-nginx get ingressclasses.networking.k8s.io


## We have to create some TLS certs in order to secure the ingress:

openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
	# Common Name: secure-ingress.com



# curl command to access, replace your IP and secure NodePort->443
curl https://secure-ingress.com:31047/service2 -kv --resolve secure-ingress.com:31047:34.105.246.174


# k8s docs
https://kubernetes.io/docs/concepts/services-networking/ingress/#tls


