param location string
param vnetName string
param clientSubnetName string
param nsgName string
param vnetPrefix array

// Initial NSG without the deny rule - allows VM extension to install tools over HTTPS.
// The DenyOutboundHTTPS and AllowSSHInbound rules are added by the nsg-block-rule module
// after the VM is fully provisioned (applied last to survive Azure Policy overrides).
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowOutboundHTTP'
        properties: {
          priority: 200
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          description: 'Allow outbound HTTP for package installation'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetPrefix
    }
    subnets: [
      {
        name: clientSubnetName
        properties: {
          addressPrefix: '10.200.0.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

output clientVnetId string = vnet.id
output clientVnetName string = vnet.name
output clientSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, clientSubnetName)
output nsgName string = nsg.name
