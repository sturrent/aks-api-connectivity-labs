# aks-api-lab2

This Bicep template deploys a **private AKS cluster** and a client VM in **separate peered VNets**, simulating a hub/spoke topology. The client VM has a deliberate network misconfiguration that prevents it from reaching the AKS API server.

Architecture:

- **VNet A** (`10.100.0.0/16`): Private AKS cluster
- **VNet B** (`10.200.0.0/16`): Client VM with tools pre-installed
- **Bidirectional VNet peering** between VNet A and VNet B
- **Private DNS zone** linked to both VNets (DNS resolves from the client VM)

The AKS cluster itself deploys and runs normally. The issue is only visible when trying to run `kubectl` or `curl` from the client VM.

## Deploy

The template uses your local SSH public key (`~/.ssh/id_rsa.pub`) for the client VM. No password needed.

```bash
az deployment sub create --name aks-api-lab2 -l canadacentral --template-file main.bicep --parameters sshPublicKey="$(cat ~/.ssh/id_rsa.pub)"
```

Note: Currently all files are referencing canadacentral location, but it can be changed using params.

```bash
az deployment sub create --name aks-api-lab2 -l southcentralus --template-file main.bicep --parameters location='southcentralus' sshPublicKey="$(cat ~/.ssh/id_rsa.pub)"
```

## Clean up

```bash
az group delete -n aks-api-nsg-block-rg --no-wait -y
```
