targetScope = 'subscription'

param location string = 'canadacentral'
param userName string = 'nsg-block'
param resourceName string = 'api'

@secure()
param clientVmPassword string

var aksResourceGroupName = 'aks-${resourceName}-${userName}-rg'
var vnetName = 'vnet-${resourceName}-${userName}'
var aksSubnetName = 'aks-subnet-${resourceName}-${userName}'
var clientSubnetName = 'client-subnet-${resourceName}-${userName}'
var nsgName = 'nsg-client-${resourceName}-${userName}'
var contributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

resource clusterrg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: aksResourceGroupName
  location: location
}

module aksvnet './modules/aks-vnet.bicep' = {
  name: vnetName
  scope: clusterrg
  params: {
    location: location
    aksSubnetName: aksSubnetName
    clientSubnetName: clientSubnetName
    nsgName: nsgName
    vnetName: vnetName
    vnetPreffix: [
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

// Client VM in a separate subnet with NSG blocking outbound TCP 443
module clientvm './modules/client-vm.bicep' = {
  name: 'clientvm'
  scope: clusterrg
  params: {
    location: location
    vmName: 'client-vm-${userName}'
    subnetId: aksvnet.outputs.clientSubnet
    adminPassword: clientVmPassword
  }
}
