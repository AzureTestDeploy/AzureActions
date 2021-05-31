@description('Name of the virtual machine')
param vmName string

@description('Location of the virtual machine')
param location string = resourceGroup().location

@description('Local Admin usernam of the virtual machine')
param adminUsername string = 'azadmin'

@description('Local admin password of the virtual machine')
@secure()
param adminPassword string

@allowed([
  'MicrosoftWindowsServer'
  'MicrosoftWindowsDesktop'
])
@description('Select image publisher for the virtual machine')
param publisher string = 'MicrosoftWindowsServer'

@allowed([
  'WindowsServer'
  'Windows-10'
])
@description('Select image offer for the virtual machine')
param offer string = 'WindowsServer'

@allowed([
  '2019-Datacenter'
  'rs5-pro'
])
@description('Select image SKU (aka os edition) for the virtual machine')
param windowsOsVersion string = '2019-Datacenter'

@description('Size of the virtual machine')
param vmSize string = 'Standard_D2as_v4'

@description('Subnet where the virtual machine belongs to')
param subnetId string

param resourceTags object = {
  Environment: 'Test'
  Project: ''
}

var nicName_var = '${vmName}-nic'


resource nicName 'Microsoft.Network/networkInterfaces@2019-09-01' = {
  name: nicName_var
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          //publicIPAddress: ''  
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vmName_resource 'Microsoft.Compute/virtualMachines@2019-03-01' = {
  name: vmName
  location: location
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: publisher
        offer: offer
        sku: windowsOsVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
        storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          diskSizeGB: 64
          lun: 0
          createOption: 'Empty'
          caching: 'ReadOnly'
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
            }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicName.id
        }
      ]
    }
  }
}

resource vmName_AADLoginForWindows 'Microsoft.Compute/virtualMachines/extensions@2019-03-01' = {
  name: '${vmName_resource.name}/AADLoginForWindows'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADLoginForWindows'
    typeHandlerVersion: '0.4'
    autoUpgradeMinorVersion: true
  }
}

resource vmName_IaaSAntimalware 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${vmName_resource.name}/IaaSAntimalware'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.1'
    autoUpgradeMinorVersion: true
    settings: {
      AntimalwareEnabled: true
      Exclusions: {
        Paths: ''
        Extensions: ''
        Processes: ''
      }
      RealtimeProtectionEnabled: 'true'
      ScheduledScanSettings: {
        isEnabled: 'true'
        scanType: 'Quick'
        day: '7'
        time: '120'
      }
    }
    protectedSettings: null
  }
}
