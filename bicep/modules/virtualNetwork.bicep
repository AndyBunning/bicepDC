// ************************
// Bicep Module File
// Microsoft.Network virtualNetworks
//
// Create a Basic Virtual Network 
//
// Created By:   Andrew Bunning
// Last Updated By:   Andrew Bunning
// Last Updates On:   25/07/2022
// Version:   v1.0
//
// For more information, please see the associated virtualNetworks.md file
// ************************

// Parameters
param name string
param location string = resourceGroup().location
param tags  object = {}
param vNetIPRanges array
param subNets array

// Resources
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: vNetIPRanges
    }
    subnets: [for subNet in subNets: {
      name: subNet.name
      properties: {
        addressPrefix: subNet.addressPrefix
      }
    }]
  }
}

// Outputs
output vNetName string = virtualNetwork.name
output vNetId string = virtualNetwork.id
output SubnetIDs array = [for (subNet, i) in subNets: {
  subnetName: subNet.name
  subnetID: virtualNetwork.properties.subnets[i].id
}]
