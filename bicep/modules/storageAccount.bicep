// ************************
// Bicep Module File
// Microsoft.Storage Storage Account
//
// Create a Basic Storage Account
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
  @allowed([
    'Standard_LRS'
    'Standard_GRS'
    'Standard_RAGRS'
  ])
  param storageAccountSku string = 'Standard_LRS'
  @allowed([
    'Hot'
    'Cool'
  ])
  param storageAccessTier string = 'Hot'
  param supportsHttpsTrafficOnly bool = true
  param storageIsHnsEnabled bool = false
  param minimumTlsVersion string = 'TLS1_2'

//Resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' ={
  name: name
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: storageAccountSku
  }
  properties: {
    accessTier: storageAccessTier
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    isHnsEnabled: storageIsHnsEnabled
    minimumTlsVersion: minimumTlsVersion
  }
}

//outputs
output saName string = storageAccount.name
output saId string = storageAccount.id
output saPrimaryEndpoints object = storageAccount.properties.primaryEndpoints
output saSecondaryEndpoints object = storageAccountSku == 'Standard_LRS' ? {} : storageAccount.properties.secondaryEndpoints
