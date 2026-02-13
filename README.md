# aks-api-connectivity-labs

Set of Bicep templates to deploy AKS environments for hands-on troubleshooting of cluster API connectivity issues.
Each directory has a README with more details.

These labs complement the **TSG: AKS – Troubleshooting Cluster API Connectivity Issues (Start Here Workflow)** wiki page.

## Scenarios

| Directory | Scenario | TSG Branch |
| --- | --- | --- |
| `aks-api-auth-ip` | Authorized IP ranges mismatch (public cluster) | Authorized IP ranges / NAT egress mismatch |
| `aks-api-nsg-block` | NSG blocking outbound TCP 443 (public cluster + client VM) | TCP 443 reachability / Routing / Firewall / NSG |

## Related

- [Existing lab: Private DNS zone not linked](https://github.com/lualvare/aks-api-connectivity) — covers the private cluster DNS resolution scenario.
Set of Bicep templates to deploy AKS environments for hands-on troubleshooting of cluster API connectivity issues.
