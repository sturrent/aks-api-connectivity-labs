targetScope = 'subscription'

param location string = 'canadacentral'
param userName string = 'nsg-block'
param resourceName string = 'api'
param sshPublicKey string

var aksResourceGroupName = 'aks-${resourceName}-${userName}-rg'
var aksClusterName = 'aks-${resourceName}-${userName}'
var nodeResourceGroupName = 'MC_${aksResourceGroupName}_${aksClusterName}_${location}'
var aksVnetName = 'vnet-aks-${userName}'
var aksSubnetName = 'aks-subnet-${userName}'
var clientVnetName = 'vnet-client-${userName}'
var clientSubnetName = 'client-subnet-${userName}'
var nsgName = 'nsg-client-${userName}'
var contributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

resource clusterrg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: aksResourceGroupName
  location: location
}

// VNet A: AKS private cluster
module aksvnet './modules/aks-vnet.bicep' = {
  name: aksVnetName
  scope: clusterrg
  params: {
    location: location
    aksSubnetName: aksSubnetName
    vnetName: aksVnetName
    vnetPrefix: [
      '10.100.0.0/16'
    ]
  }
}

// VNet B: Client VM (separate VNet, simulates hub/spoke or on-prem peered network)
module clientvnet './modules/client-vnet.bicep' = {
  name: clientVnetName
  scope: clusterrg
  params: {
    location: location
    clientSubnetName: clientSubnetName
    nsgName: nsgName
    vnetName: clientVnetName
    vnetPrefix: [
      '10.200.0.0/16'
    ]
  }
}

// Bidirectional VNet peering
module vnetpeering './modules/vnet-peering.bicep' = {
  name: 'vnetPeering'
  scope: clusterrg
  params: {
    vnetAName: aksVnetName
    vnetBName: clientVnetName
    vnetAId: aksvnet.outputs.aksVnetId
    vnetBId: clientvnet.outputs.clientVnetId
  }
}

// Private AKS cluster in VNet A
module akscluster './modules/aks-cluster.bicep' = {
  name: resourceName
  scope: clusterrg
  params: {
    location: location
    clusterName: aksClusterName
    aksSubnetId: aksvnet.outputs.aksSubnetId
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

// Link the AKS private DNS zone to the client VNet so the VM can resolve the private FQDN.
// The private DNS zone is created by AKS in the node resource group (MC_*).
module dnsZoneLink './modules/dns-zone-link.bicep' = {
  name: 'dnsZoneLink'
  scope: resourceGroup(nodeResourceGroupName)
  params: {
    privateFqdn: akscluster.outputs.privateFqdn
    clientVnetId: clientvnet.outputs.clientVnetId
    clientVnetName: clientVnetName
  }
}

// Client VM in VNet B
module clientvm './modules/client-vm.bicep' = {
  name: 'clientvm'
  scope: clusterrg
  dependsOn: [
    vnetpeering
  ]
  params: {
    location: location
    vmName: 'client-vm-${userName}'
    subnetId: clientvnet.outputs.clientSubnetId
    sshPublicKey: sshPublicKey
  }
}

// Apply the NSG deny rule AFTER the VM extension installs tools.
// This ensures kubectl and az CLI are available before HTTPS is blocked.
module nsgBlockRule './modules/nsg-block-rule.bicep' = {
  name: 'nsgBlockRule'
  scope: clusterrg
  dependsOn: [
    clientvm
  ]
  params: {
    nsgName: nsgName
  }
}
