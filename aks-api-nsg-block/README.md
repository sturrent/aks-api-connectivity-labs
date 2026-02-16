# aks-api-nsg-block

This Bicep template deploys a **private AKS cluster** and a client VM in **separate peered VNets**, simulating a hub/spoke topology. The client subnet has an NSG with a deny rule blocking all outbound TCP 443.

Architecture:

- **VNet A** (`10.100.0.0/16`): Private AKS cluster
- **VNet B** (`10.200.0.0/16`): Client VM with restrictive NSG
- **Bidirectional VNet peering** between VNet A and VNet B
- **Private DNS zone** linked to both VNets (DNS resolves from the client VM)
- **NSG** on client subnet: denies all outbound TCP 443 (blocks traffic to the private API server)

This simulates the scenario where a customer's client network (hub/spoke VM, on-prem via peering, CI agent) has DNS working fine but TCP 443 to the private API server is blocked by an NSG or firewall rule.

The AKS cluster itself deploys and runs normally. The issue is only visible when trying to run `kubectl` or `curl -kIv` from the client VM.

## Deploy

The template uses your local SSH public key (`~/.ssh/id_rsa.pub`) for the client VM. No password needed.

```bash
az deployment sub create --name aks-api-nsg-block -l canadacentral --template-file main.bicep --parameters sshPublicKey="$(cat ~/.ssh/id_rsa.pub)"
```

Note: Currently all files are referencing canadacentral location, but it can be changed using params.

```bash
az deployment sub create --name aks-api-nsg-block -l southcentralus --template-file main.bicep --parameters location='southcentralus' sshPublicKey="$(cat ~/.ssh/id_rsa.pub)"
```

## Clean up

```bash
az group delete -n aks-api-nsg-block-rg --no-wait -y
```
