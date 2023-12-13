// ************************
// Main Bicep File
// ABunning-VMs Resource Group
//
// Deploy resources to support development to ABunning-VMs RG.
//
// Created By : Andrew Bunning
// Last Updates On : 21/03/2023
// Version : 0.1
// Status : Dev
//
// ************************

// Parameters
param namePrefix string
param location string
param tags object

param vNetIPRanges array

param domain string
param netbiosName string
param adminUserName string
@secure()
param adminPassword string

// Variables
var saNameMax = '${toLower(namePrefix)}${toLower(take(replace(location, ' ', ''), 3))}stor${uniqueString(resourceGroup().id)}'
var saName = take(saNameMax,24)
var pipName = '${namePrefix}-pip'
var pipDnsName = toLower(namePrefix)
var vNetName = '${namePrefix}-vNet'
var vMName = '${namePrefix}-DC01'

// Modules

  // Storage Account
    module sa 'modules/storageAccount.bicep' ={
      name: 'StorageAccount'
      params: {
        name: saName
        location: location
        tags: tags
      }
    }

  // Public IP Address
    module pip 'modules/publicIPAddress.bicep' ={
      name: 'PublicIP'
      params: {
        name: pipName
        location: location
        tags: tags
        sku: 'Basic'
        domainNameLabel: pipDnsName
      }
    }

  // Virtual Network
    module SubnetCalc 'utility/hubSubnets.bicep' ={
      name: 'SubnetCalculator'
      params: {
        vNetIPRanges: vNetIPRanges
      }
    }

    module vNet 'modules/virtualNetwork.bicep' ={
      name: 'VirtualNetwork'
      params: {
        name: vNetName
        location: location
        tags: tags
        vNetIPRanges: vNetIPRanges
        subNets: SubnetCalc.outputs.subnets
      }
    }

  // Virtual Machine
    module vm 'modules/virtualMachineDomainController.bicep' ={
      name: 'VirtualMachine'
      params: {
        name: vMName
        location: location
        tags: tags
        subnetId: vNet.outputs.SubnetIDs[3].subnetID
        publicIPAddressID: pip.outputs.pIPId
        domain: domain
        netbiosName: netbiosName
        adminUserName: adminUserName
        adminPassword: adminPassword
        bootDiagsUri: sa.outputs.saPrimaryEndpoints.blob
      }
    }


// Outputs
output vmFQDN string = pip.outputs.pIPFQDN
