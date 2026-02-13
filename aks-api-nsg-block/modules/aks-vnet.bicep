param location string
param vnetName string
param aksSubnetName string
param clientSubnetName string
param nsgName string
param vnetPreffix array

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'DenyOutboundHTTPS'
        properties: {
          priority: 100
          direction: 'Outbound'
          access: 'Deny'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          description: 'Block outbound TCP 443 to Internet — simulates firewall/NSG misconfiguration'
        }
      }
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
      {
        name: 'AllowSSHInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          description: 'Allow SSH for engineer access to client VM'
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
      addressPrefixes: vnetPreffix
    }
    subnets: [
      {
        name: aksSubnetName
        properties: {
          addressPrefix: '10.100.0.0/24'
        }
      }
      {
        name: clientSubnetName
        properties: {
          addressPrefix: '10.100.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

var aksSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, aksSubnetName)
var clientSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, clientSubnetName)

output aksVnetId string = vnet.id
output akssubnet string = aksSubnetId
output clientSubnet string = clientSubnetId
output vnetName string = vnet.name
output nsgId string = nsg.id
