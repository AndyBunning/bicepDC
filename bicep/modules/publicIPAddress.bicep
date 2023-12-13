// ************************
// Bicep Module File
// Microsoft.Network publicIPAddresses
//
// Create a Basic Public IP Address 
//
// Created By: Andrew Bunning
// Latest Update : 02/08/2022
// Version: v1.0
//
// For more information, please see the associated publicIPAddress.md file
// ************************

// Parameters
param name string
param location string = resourceGroup().location
param tags  object = {}
@allowed([
  'Basic'
  'Standard'
])
param sku string = 'Standard'
@allowed([
  'Dynamic'
  'Static'
])
param pIPAllocationMethod string = 'Static'
param domainNameLabel string = ''

// Resources
resource publicIp 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: (domainNameLabel == '') ? {
    publicIPAllocationMethod: pIPAllocationMethod
  } : {
    publicIPAllocationMethod: pIPAllocationMethod
    dnsSettings: {
      domainNameLabel: domainNameLabel
    }
  }
}

// Outputs
output pIPName string = publicIp.name
output pIPId string = publicIp.id
output pIPFQDN string = (empty(domainNameLabel)) ? '' : publicIp.properties.dnsSettings.fqdn
