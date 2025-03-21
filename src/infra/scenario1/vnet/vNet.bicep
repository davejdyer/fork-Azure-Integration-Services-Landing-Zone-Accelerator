param vNet object

resource vNet_frontEnd_nsg 'Microsoft.Network/networkSecurityGroups@2015-06-15' = {
  name: vNet.frontEnd.nsg
  location: resourceGroup().location
  tags: {
    displayName: 'NSG - Remote Access'
  }
  properties: {
    securityRules: [
      {
        name: 'allow-frontend'
        properties: {
          description: 'Allow FE Subnet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: vNet.frontEnd.address
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'block-internet'
        properties: {
          description: 'Block Internet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          access: 'Deny'
          priority: 200
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource vNet_backEnd_nsg 'Microsoft.Network/networkSecurityGroups@2015-06-15' = {
  name: vNet.backEnd.nsg
  location: resourceGroup().location
  tags: {
    displayName: 'NSG - Front End'
  }
  properties: {
    securityRules: [
      {
        name: 'rdp-rule'
        properties: {
          description: 'Allow RDP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'web-rule'
        properties: {
          description: 'Allow WEB'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 101
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vNet_name 'Microsoft.Network/virtualNetworks@2015-06-15' = {
  name: vNet.name
  location: resourceGroup().location
  tags: {
    displayName: 'VNet'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNet.address
      ]
    }
    subnets: [
      {
        name: vNet.frontEnd.name
        properties: {
          addressPrefix: vNet.frontEnd.address
          networkSecurityGroup: {
            id: vNet_frontEnd_nsg.id
          }
        }
      }
      {
        name: vNet.backEnd.name
        properties: {
          addressPrefix: vNet.backEnd.address
          networkSecurityGroup: {
            id: vNet_backEnd_nsg.id
          }
        }
      }
      {
        name: vNet.privateLink.name
        properties: {
          addressPrefix: vNet.privateLink.address
        }
      }
      {
        name: vNet.VM.name
        properties: {
          addressPrefix: vNet.VM.address
        }
      }
    ]
  }
}
