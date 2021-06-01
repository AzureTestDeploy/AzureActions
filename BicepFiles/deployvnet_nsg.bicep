param suffix string = 'rccshared'
param prefix string = 'euwe-prod'
param owner string = 'Sebbe'
param costCenter string = '12345'
param environment string = 'Prod'
param addressPrefix string = '10.11.0.0/16'
param subnet1Name string = 'test1-snet'
param subnet2Name string = 'test2-snet'
param subnet1Addressprefix string = '10.11.1.0/24'
param subnet2Addressprefix string = '10.11.2.0/24'
param networkSecurityGroup01Name string =''
param networkSecurityGroup02Name string =''
var vnetName = 'vnet-${suffix}-${prefix}'


resource networkSecurityGroup01Name_resource 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: networkSecurityGroup01Name
  location: resourceGroup().location
  properties: {
//Rule to be enabled later 
    securityRules: [
      {
        name: 'HTTPS'
        properties: {
          description: 'Open HTTPS to Public'
          protocol: 'Tcp'
          sourcePortRange: '443'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 101
          direction: 'Inbound'
        }
      }
    ]
  } 
}


resource networkSecurityGroup02Name_resource 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: networkSecurityGroup02Name
  location: resourceGroup().location
  properties: {
    /*securityRules: [
      {
        name: 'HTTPS'
        properties: {
          description: 'Open HTTPS to Public'
          protocol: 'Tcp'
          sourcePortRange: '443'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 101
          direction: 'Inbound'
        }
      }
    ] */
  }
}
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: resourceGroup().location
  tags: {
    Environment: environment 
    Owner: owner
    CostCenter: costCenter
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    enableVmProtection: false
    enableDdosProtection: false
 
  }
  dependsOn: [
    networkSecurityGroup01Name_resource
    networkSecurityGroup02Name_resource

  ]
}
resource vnetName_subnet1Name 'Microsoft.Network/virtualNetworks/subnets@2018-10-01' = {
  name: '${vnet.name}/${subnet1Name}'
  properties: {
    addressPrefix: subnet1Addressprefix
    networkSecurityGroup: {
      id: networkSecurityGroup01Name_resource.id
    }
    
  }
  dependsOn: [
    networkSecurityGroup01Name_resource
    networkSecurityGroup02Name_resource
    vnet

  ]
    }
    resource vnetName_subnet2Name 'Microsoft.Network/virtualNetworks/subnets@2018-10-01' = {
      name: '${vnet.name}/${subnet2Name}'
      properties: {
        addressPrefix: subnet2Addressprefix
        networkSecurityGroup: {
          id: networkSecurityGroup02Name_resource.id
        }
      }
      dependsOn: [
        networkSecurityGroup01Name_resource
        networkSecurityGroup02Name_resource
        vnet
      ]
        }

