// This module adds final NSG rules AFTER the client VM extension finishes.
// 1. DenyOutboundHTTPS: blocks outbound TCP 443 (the lab's deliberate break).
// 2. AllowSSHInbound: re-ensures SSH access survives Azure Policy that may
//    strip custom rules from the NSG created during initial deployment.

param nsgName string

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' existing = {
  name: nsgName
}

resource denyHttpsRule 'Microsoft.Network/networkSecurityGroups/securityRules@2024-07-01' = {
  parent: nsg
  name: 'DenyOutboundHTTPS'
  properties: {
    priority: 100
    direction: 'Outbound'
    access: 'Deny'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    description: 'Block all outbound TCP 443 - simulates restrictive NSG/firewall misconfiguration'
  }
}

resource allowSshRule 'Microsoft.Network/networkSecurityGroups/securityRules@2024-07-01' = {
  parent: nsg
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
