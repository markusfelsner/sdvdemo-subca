sudo echo "test-app.com 192.168.49.2" >> /etc/hosts
sudo echo "minikube.data.gov.au 127.0.0.1" >> /etc/hosts

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.1/cert-manager.yaml

kubectl apply -f https://gist.githubusercontent.com/t83714/51440e2ed212991655959f45d8d037cc/raw/7b16949f95e2dd61e522e247749d77bc697fd63c/selfsigned-issuer.yaml

minikube addons enable ingress
