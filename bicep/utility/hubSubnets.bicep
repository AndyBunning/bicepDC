// ************
// Bicep Utility File
// Hub Network Subnet Configuration
//
// Customer: Development
// Created By: Andrew Bunning
// Last Updates On : 22/12/2022
// Status: Dev
//
// ************

// Parameters
  param vNetIPRanges array

// Variables
  var IPRangeSplit = split(vNetIPRanges[0],'.')

// Outputs
  output subnets array = [
    {
      name: 'GatewaySubnet'
      addressPrefix: '${IPRangeSplit[0]}.${IPRangeSplit[1]}.${IPRangeSplit[2]}.0/26'
      nsg: ''
    }
    {
      name: 'AzureFirewallSubnet'
      addressPrefix: '${IPRangeSplit[0]}.${IPRangeSplit[1]}.${IPRangeSplit[2]}.64/26'
      nsg: ''
    }
    {
      name: 'AzureBastionSubnet'
      addressPrefix: '${IPRangeSplit[0]}.${IPRangeSplit[1]}.${IPRangeSplit[2]}.128/26'
      nsg: ''
    }
    {
      name: 'Default'
      addressPrefix: '${IPRangeSplit[0]}.${IPRangeSplit[1]}.${IPRangeSplit[2]}.192/26'
      nsg: ''
    }
  ]
