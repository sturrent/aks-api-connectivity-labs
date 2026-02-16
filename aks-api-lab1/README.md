# aks-api-lab1

This Bicep template deploys a public AKS cluster with a deliberate misconfiguration that prevents API server access from the engineer's network.

Use this lab to practice the troubleshooting workflow from the Start Here TSG.

## Deploy

```bash
az deployment sub create --name aks-api-lab1 -l canadacentral --template-file main.bicep
```

Note: Currently all files are referencing canadacentral location, but it can be changed using params.

```bash
az deployment sub create --name aks-api-lab1 -l southcentralus --template-file main.bicep --parameters location='southcentralus'
```

## Clean up

```bash
az group delete -n aks-api-lab1-rg --no-wait -y
```
