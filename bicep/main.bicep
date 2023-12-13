// **********
//
// Deployment of a simple vNet and Windows Server Domain Controller.
// Secrets Stored in Keyvault.
//
// main.bicep file
//
// **********

targetScope = 'subscription'

// Parameters

param domain string = 'domain.local'
param namePrefix string = '${split(domain,'.')[0]}${uniqueString(subscription().id)}'
param location string = deployment().location
param tags object = {
  Creator: 'andrew@abunning.com'
  Customer: 'Personal'
  Environment: 'Development'
  DeploymentDate : utcNow('yyyy-MM-dd')
}

param vNetIPRanges array = [
  '10.0.0.0/24'
]

param netbiosName string = split(domain,'.')[0]
param adminUserName string
@secure()
param adminPassword string

// Variables

var rgName = '${namePrefix}-RG'

// Resources

  // Resource Group
  resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' ={
    name: rgName
    location: location
    tags: tags
  }

  // Infrastrucutre
  module infrastrucutre 'infra.bicep' ={
    name: 'InfraDeployment'
    params: {
      location: location
      tags: tags
      namePrefix: namePrefix
      vNetIPRanges: vNetIPRanges
      domain: domain
      netbiosName: netbiosName
      adminUserName: adminUserName
      adminPassword: adminPassword
    }
    scope: rg
  }

// Outputs
