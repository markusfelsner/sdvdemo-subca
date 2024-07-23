#!/bin/bash -x

sudo echo "test-app.com 192.168.49.2" >> /etc/hosts
sudo echo "minikube.data.gov.au 127.0.0.1" >> /etc/hosts



# Minikube starten
minikube start --embed-certs

minikube addons enable ingress

# Helm installieren (falls nicht bereits installiert)
if ! command -v helm &> /dev/null
then
    echo "Helm wird installiert..."
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
fi

# cert-manager installieren
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.12.2

# Warte bis cert-manager bereit ist
kubectl wait --namespace cert-manager --for=condition=Available --timeout=600s deployment/cert-manager

# Root-CA und Sub-CA generieren
openssl genrsa -out root.key 2048
openssl req -x509 -new -nodes -key root.key -sha256 -days 1024 -out root.crt -subj "/CN=Root CA"
openssl genrsa -out sub.key 2048
openssl req -new -key sub.key -out sub.csr -subj "/CN=Sub CA"
openssl x509 -req -in sub.csr -CA root.crt -CAkey root.key -CAcreateserial -out sub.crt -days 500 -sha256

# Sub-CA Secret erstellen
kubectl create secret tls sub-ca-secret --cert=sub.crt --key=sub.key -n cert-manager

read -p "Press enter to continue"
# YAML Datei anwenden
kubectl apply -f resources.yaml

echo "Setup abgeschlossen. Zertifikate wurden ausgestellt."
