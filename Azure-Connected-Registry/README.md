## AZURE CONNECTED REGISTRY ON AKS HCI

- sudo apt install helm=3.6.3-1

- service ip selected: <cluster-ip> #must be checked before each deployment and must be a CLUSTER IP. To avoid select an IP already in use launch:
```console
kubectl get services -A 
```

- Get Connection String of ACR on Cloud

- Get storage class of K8s: 
```console
kubectl get storageclass
```
1) Creation of certificate
```console
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ./mycert.key -x509 -days 365 -out ./ca.crt -addext "subjectAltName = IP:<cluster-ip>"
```
2) Export inside variables of certificate and key
```console
export TLS_CRT=$(cat ca.crt | base64 -w0) 
export TLS_KEY=$(sudo cat mycert.key | base64 -w0)
```
2) Deploy registry
```console
helm upgrade --namespace connected-registry --create-namespace --install --set connectionString="<connection-string>" --set service.clusterIP=<cluster-ip>  --set pvc.storageClassName="<storage-class>" --set image="mcr.microsoft.com/acr/connected-registry:0.6.0" --set tls.crt=$TLS_CRT --set tls.key=$TLS_KEY connected-registry ./connected-registry
```
3) Copy the certificate inside each node of the cluster HCI
```console
scp -i /root/akshci_rsa ca.crt clouduser@<ip-of-each-node>:/home/clouduser/ca.crt
```
4) ssh on the node
```console
ssh -i /root/akshci_rsa clouduser@<ip-of-each-node>
``` 
5) Create the directory inside each node:
```console
sudo mkdir -p /etc/containerd/certs.d/<cluster-ip>:443
```
6) Copy the certificate: 
```console
sudo cp /home/clouduser/ca.crt /etc/containerd/certs.d/<cluster-ip>:443
sudo ls /etc/containerd/certs.d/<cluster-ip>:443
```
7) Modify config.toml as follow:
```console
sudo nano /etc/containerd/config.toml
```
``` yaml
version = 2
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    sandbox_image = "ecpacr.azurecr.io/pause:3.4.1"
  [plugins."io.containerd.grpc.v1.cri".registry]
    config_path = "/etc/containerd/certs.d"     
  [plugins."io.containerd.grpc.v1.cri".registry.configs."<cluster-ip>:443".tls]
    ca_file   = "/etc/containerd/certs.d/<cluster-ip>:443/ca.crt"
```
8) Restart daemon
```console
sudo systemctl restart containerd
```

# Test pull from new connected registry

1) Create K8s secret:
```console
kubectl create secret docker-registry regcred --docker-server=<cluster-ip>:443 --docker-username=username --docker-password=password --docker-email=email
```
3) Make a test deployment to see if pull from connected registry work correctly:
```console
kubectl apply -f deployment-test.yaml
```
