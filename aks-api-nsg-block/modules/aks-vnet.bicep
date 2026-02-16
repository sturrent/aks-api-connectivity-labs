param location string
param vnetName string
param aksSubnetName string
param vnetPrefix array

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetPrefix
    }
    subnets: [
      {
        name: aksSubnetName
        properties: {
          addressPrefix: '10.100.0.0/24'
        }
      }
    ]
  }
}

output aksVnetId string = vnet.id
output aksVnetName string = vnet.name
output aksSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, aksSubnetName)
