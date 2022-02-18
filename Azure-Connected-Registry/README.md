## AZURE CONNECTED REGISTRY ON AKS HCI

- service ip selected: 10.96.0.82 #must be checked before each deployment and must be a CLUSTER IP

- Get Connection String of ACR on Cloud

- Get storage class of K8s: 
```console
kubectl get storageclass
```
1) Creation of certificate
```console
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ./mycert.key -x509 -days 365 -out ./ca.crt -addext "subjectAltName = IP:10.96.0.82"
```
2) Export inside variables of certificate and key
```console
export TLS_CRT=$(cat ca.crt | base64 -w0) 
export TLS_KEY=$(sudo cat mycert.key | base64 -w0)
```
2) Deploy registry
```console
helm upgrade --namespace connected-registry --create-namespace --install --set connectionString="ConnectedRegistryName=snreb00002acrsergnano;SyncTokenName=snreb00002acrsergnano;SyncTokenPassword=5y7fjJtpc77A418DXWYsYL0WIu88pCf/;ParentGatewayEndpoint=snreb00002acr.westeurope.data.azurecr.io;ParentEndpointProtocol=https" --set service.clusterIP=10.96.0.82  --set pvc.storageClassName="default" --set image="mcr.microsoft.com/acr/connected-registry:0.6.0" --set tls.crt=$TLS_CRT --set tls.key=$TLS_KEY connected-registry ./connected-registry
```
3) Copy the certificate inside each node of the cluster HCI
```console
scp -i /root/akshci_rsa ca.crt clouduser@10.64.92.6:/home/clouduser/ca.crt
```
4) ssh on the node
```console
ssh -i /root/akshci_rsa clouduser@10.64.92.6
``` 
5) Create the directory inside each node:
```console
sudo mkdir -p /etc/containerd/certs.d/10.96.0.82:443
```
6) Copy the certificate: 
```console
sudo cp /home/clouduser/ca.crt /etc/containerd/certs.d/10.96.0.82:443
sudo ls /etc/containerd/certs.d/10.96.0.82:443
```
7) Modify config.toml as follow:
```console
sudo nano /etc/containerd/config.toml
```

version = 2
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    sandbox_image = "ecpacr.azurecr.io/pause:3.4.1"
  [plugins."io.containerd.grpc.v1.cri".registry]
    config_path = "/etc/containerd/certs.d"     
  [plugins."io.containerd.grpc.v1.cri".registry.configs."10.96.0.82:443".tls]
    ca_file   = "/etc/containerd/certs.d/10.96.0.82:443/ca.crt"

8) Restart daemon
```console
sudo systemctl restart containerd
```

# Test pull from new connected registry

1) Create K8s secret:
```console
kubectl create secret docker-registry regcred --docker-server=10.96.0.82:443 --docker-username=username --docker-password=password --docker-email=email
```
3) Make a test deployment to see if pull from connected registry work correctly:
```console
kubectl apply -f deployment-test.yaml
```
