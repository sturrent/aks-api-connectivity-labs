param vnetAName string
param vnetBName string
param vnetAId string
param vnetBId string

resource peeringAtoB 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-07-01' = {
  name: '${vnetAName}/${vnetAName}-to-${vnetBName}'
  properties: {
    remoteVirtualNetwork: {
      id: vnetBId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource peeringBtoA 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-07-01' = {
  name: '${vnetBName}/${vnetBName}-to-${vnetAName}'
  properties: {
    remoteVirtualNetwork: {
      id: vnetAId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}
