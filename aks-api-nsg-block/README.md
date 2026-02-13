# aks-api-nsg-block

This Bicep template deploys a public AKS cluster and a "client VM" in a separate subnet. The client subnet has an NSG with a deny rule blocking outbound TCP 443 to Internet.

This simulates the scenario where a customer's client network (on-prem / VNet VM / CI agent) has DNS working fine but TCP 443 to the API server is blocked by an NSG or firewall rule.

The AKS cluster itself deploys and runs normally. The issue is only visible when trying to run `kubectl` or `curl -kIv` from the client VM.

## Deploy

You will be prompted for the client VM password (must meet Azure complexity requirements: 12+ chars, upper, lower, number, special char).

```bash
az deployment sub create --name aks-api-nsg-block -l canadacentral --template-file main.bicep --parameters clientVmPassword='<YOUR_PASSWORD>'
```

Note: Currently all files are referencing canadacentral location, but it can be changed using params.

```bash
az deployment sub create --name aks-api-nsg-block -l southcentralus --template-file main.bicep --parameters location='southcentralus' clientVmPassword='<YOUR_PASSWORD>'
```

## Clean up

```bash
az group delete -n aks-api-nsg-block-rg --no-wait -y
```
