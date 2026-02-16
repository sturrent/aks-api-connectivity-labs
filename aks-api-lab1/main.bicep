targetScope = 'subscription'

param location string = 'canadacentral'
param userName string = 'lab1'
param resourceName string = 'api'

var aksResourceGroupName = 'aks-${resourceName}-${userName}-rg'
var vnetName = 'vnet-${resourceName}-${userName}'
var subnetName = 'aks-subnet-${resourceName}-${userName}'
var contributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

// Dummy authorized IP range that will NOT match the engineer's real egress IP
// This simulates a customer misconfiguration where the allow list doesn't include
// the actual client network's NAT/egress IP.
var dummyAuthorizedIpRanges = [
  '192.0.2.0/24'   // TEST-NET-1 (RFC 5737) — will never be a real client IP
]

resource clusterrg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: aksResourceGroupName
  location: location
}

module aksvnet './modules/aks-vnet.bicep' = {
  name: vnetName
  scope: clusterrg
  params: {
    location: location
    subnetName: subnetName
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.100.0.0/24'
        }
      }
    ]
    vnetName: vnetName
    vvnetPreffix: [
      '10.100.0.0/16'
    ]
  }
}

module akscluster './modules/aks-cluster.bicep' = {
  name: resourceName
  scope: clusterrg
  params: {
    location: location
    clusterName: 'aks-${resourceName}-${userName}'
    aksSubnetId: aksvnet.outputs.akssubnet
    authorizedIpRanges: dummyAuthorizedIpRanges
  }
}

module roleAuthorization './modules/aks-auth.bicep' = {
  name: 'roleAuthorization'
  scope: clusterrg
  params: {
    principalId: akscluster.outputs.aks_principal_id
    roleDefinition: contributorRoleId
  }
}
