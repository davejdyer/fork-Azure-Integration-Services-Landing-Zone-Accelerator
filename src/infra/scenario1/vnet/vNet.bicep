@description('Org name abbreviation used in naming resources')
param orgName string = 'djd'

@description('System prefix used in naming resources')
param systemPrefix string = 'ais'

@description('Type of environment')
@allowed([
  'dev'
  'uat'
  'prod'
])
param environment string = 'dev'

param buildIteration string = '01'

@description('CIDR prefix for the VNet address space.')
param vnetAddressSpace string = '192.168.0.0/16'

@description('CIDR address prefix for the front end subnet.')
param frontEndSubnet string = '192.168.1.0/24'

@description('CIDR address prefix for the back end subnet.')
param backEndSubnet string = '192.168.2.0/24'

@description('CIDR address prefix for the private link.')
param privateLinkSubnet string = '192.168.10.0/24'

@description('CIDR address prefix for the IaaS VMs.')
param vmSubnet string = '192.168.20.0/24'

// Platform target
var azRegion = resourceGroup().location

// vNet object
var vNet = {
  name: 'vnet-${orgName}-${systemPrefix}-${environment}-${azRegion}-${buildIteration}'
  address: vnetAddressSpace
  frontEnd: {
    nsg: 'nsg-frontend-${orgName}-${systemPrefix}-${environment}-${azRegion}-${buildIteration}'
    address: frontEndSubnet
  }
  backEnd: {
    nsg: 'nsg-backend-${orgName}-${systemPrefix}-${environment}-${azRegion}-${buildIteration}'
    address: backEndSubnet
  }
  privateLink: {
    address: privateLinkSubnet
  }
  VM: {
    address: vmSubnet
  }
}

resource vNet_frontEnd_nsg 'Microsoft.Network/networkSecurityGroups@2015-06-15' = {
  name: vNet.frontEnd.nsg
  location: resourceGroup().location
  tags: {
    displayName: 'NSG - Remote Access'
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

resource vNet_backEnd_nsg 'Microsoft.Network/networkSecurityGroups@2015-06-15' = {
  name: vNet.backEnd.nsg
  location: resourceGroup().location
  tags: {
    displayName: 'NSG - Front End'
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

resource vNet_name 'Microsoft.Network/virtualNetworks@2015-06-15' = {
  name: vNet.name
  location: resourceGroup().location
  tags: {
    displayName: '${orgName}-${systemPrefix}-vnet'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNet.address
      ]
    }
    subnets: [
      {
        name: 'snet-frontEnd-${vNet.name}'
        properties: {
          addressPrefix: vNet.frontEnd.address
          networkSecurityGroup: {
            id: vNet_frontEnd_nsg.id
          }
        }
      }
      {
        name: 'snet-backEnd-${vNet.name}'
        properties: {
          addressPrefix: vNet.backEnd.address
          networkSecurityGroup: {
            id: vNet_backEnd_nsg.id
          }
        }
      }
      {
        name: 'snet-pep-${vNet.name}'
        properties: {
          addressPrefix: vNet.privateLink.address
        }
      }
      {
        name: 'snet-vm-${vNet.name}'
        properties: {
          addressPrefix: vNet.VM.address
        }
      }
    ]
  }
}
