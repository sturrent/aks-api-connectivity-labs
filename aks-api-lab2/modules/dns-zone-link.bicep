// Links an existing private DNS zone (created by AKS for the private cluster)
// to the client VNet so the VM can resolve the private FQDN.
// The zone name includes a GUID prefix, so we derive it from the cluster's privateFqdn.

param privateFqdn string
param clientVnetId string
param clientVnetName string

// privateFqdn = 'clustername-hash.GUID.privatelink.region.azmk8s.io'
// Strip the first label to get the DNS zone name
var dnsZoneName = join(skip(split(privateFqdn, '.'), 1), '.')

resource dnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: dnsZoneName
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: dnsZone
  name: '${clientVnetName}-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: clientVnetId
    }
    registrationEnabled: false
  }
}
