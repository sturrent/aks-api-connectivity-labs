# aks-api-auth-ip

This Bicep template deploys a public AKS cluster with `apiServerAccessProfile.authorizedIpRanges` set to a dummy CIDR (`192.0.2.0/24` — RFC 5737 TEST-NET-1) that will NOT include the engineer's egress IP.

This simulates the common scenario where a customer has API server authorized IP ranges enabled but the allow list doesn't include their actual client network's NAT/egress IP.

## Deploy

```bash
az deployment sub create --name aks-api-auth-ip -l canadacentral --template-file main.bicep
```

Note: Currently all files are referencing canadacentral location, but it can be changed using params.

```bash
az deployment sub create --name aks-api-auth-ip -l southcentralus --template-file main.bicep --parameters location='southcentralus'
```

## Clean up

```bash
az group delete -n aks-api-auth-ip-rg --no-wait -y
```
