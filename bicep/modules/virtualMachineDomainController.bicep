// ************************
// Bicep Module File
// Microsoft.Network Network Interfaces
// Microsoft.Compute Virtual Machines
// Microsoft.Compute/virtualMachines Extensions
//
// Create a Windows Server with Anti-Malware and Monitoring Extensions
//
// Created By:   Andrew Bunning
// Last Updates On:   05/08/2022
// Version:   v1.1
//
// For more information, please see the associated storageAccount.md file
// ************************

// Parameters
param name string
param location string = resourceGroup().location
param tags object = {}
param subnetId string
@allowed( [
    'Static'
    'Dynamic'
] )
param privateIPAllocationMethod string = 'Dynamic'
param publicIPAddressID string = ''
param vmconfig object = {}
param domain string
param netbiosName string
param adminUserName string
@secure()
param adminPassword string
param bootDiagsUri string
param vmSize string = contains(vmconfig, 'vmSize') ? vmconfig.vmSize : 'Standard_D2s_v4'
param osSku string = contains(vmconfig, 'osSku') ? vmconfig.osSku : '2019-Datacenter'
param osVersion string = contains(vmconfig, 'osVersion') ? vmconfig.osVersion : 'latest'
param dataDisks array = contains(vmconfig, 'DataDisks') ? vmconfig.DataDisks : []

// Variables
var vmNICName = '${name}-nic'

// Resources
  // NIC
  resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' ={
    name: vmNICName
    location: location
    tags: tags
    properties: {
      ipConfigurations: [
        {
          name: 'ipconfig1'
          properties: (empty(publicIPAddressID)) ? {
            privateIPAllocationMethod: privateIPAllocationMethod
            subnet: {
              id: subnetId
            }
          } : {
            privateIPAllocationMethod: privateIPAllocationMethod
            subnet: {
              id: subnetId
            }
            publicIPAddress: {
              id: publicIPAddressID
            }
          }
        }
      ]
    }
  }


  // VM
  resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' ={
    name: name
    location: location
    tags: tags
    properties: {
      hardwareProfile: {
        vmSize: vmSize
      }
      osProfile: {
        computerName: name
        adminUsername: adminUserName
        adminPassword: adminPassword
      }
      storageProfile: {
        imageReference: {
          publisher: 'MicrosoftWindowsServer'
          offer: 'WindowsServer'
          sku: osSku
          version: osVersion
        }
        dataDisks: dataDisks
      }
      networkProfile: {
        networkInterfaces: [
          {
            id: nic.id
          }
        ]
      }
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
          storageUri: bootDiagsUri
        }
      }
    }
  }


  // Anti-Malware Extension
  resource vmAntiMalware 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' ={
    parent: vm
    name: 'AntiMalware'
    location: location
    properties: {
      publisher: 'Microsoft.Azure.Security'
      type: 'IaaSAntimalware'
      typeHandlerVersion: '1.1'
      autoUpgradeMinorVersion: true
      settings: {
        AntimalwareEnabled: true
        Exclusions: {
          Paths: 'C:\\Users'
          Extensions: '.txt'
          Processes: 'taskmgr.exe'
        }
        RealtimeProtectionEnabled: true
        ScheduledScanSettings: {
          isEnabled: true
          scanType: 'Quick'
          day: 7
          time: 120
        }
      }
    }
  }

  //  Monitoring Extension
  resource vmMonitoring 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' ={
    parent: vm
    name: 'AzureMonitorWindowsAgent'
    location: location
    properties: {
      publisher: 'Microsoft.Azure.Monitor'
      type: 'AzureMonitorWindowsAgent'
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true
      enableAutomaticUpgrade: true
    }
  }

  //  Custom Extension to dcpromo
  resource vmDCPromo 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' ={
    parent: vm
    name: 'DomainPromo'
    location: location
    properties: {
      publisher: 'Microsoft.Compute'
      type: 'CustomScriptExtension'
      typeHandlerVersion: '1.10'
      autoUpgradeMinorVersion: true
      settings: {
        fileUris: [
          'https://raw.githubusercontent.com/AndyBunning/bicepDC/main/scripts/dcpromo.ps1'
          'https://raw.githubusercontent.com/AndyBunning/bicepDC/main/scripts/dcpromo_unattend.txt'
        ]
      }
      protectedSettings: {
        commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File dcpromo.ps1 -domain ${domain} -netbiosName ${netbiosName} -safeModePass ${adminPassword}'
      }
    }
  }
