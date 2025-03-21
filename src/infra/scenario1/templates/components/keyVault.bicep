param keyVaultName string
param keyVaultSKUName string = 'Standard'
param keyVaultSKUFamily string = 'A'

@description('Property to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param enabledForDeployment bool = false

@description('Property to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enabledForDiskEncryption bool = false

@description('Property to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enabledForTemplateDeployment bool = false

@description('Property that controls how data actions are authorized. When true, the key vault will use Role Based Access Control (RBAC) for authorization of data actions, and the access policies specified in vault properties will be ignored. When false, the key vault will use the access policies specified in vault properties, and any policy stored on Azure Resource Manager will be ignored. .')
param enableRbacAuthorization bool = true
param tenantId string

@description('Property to specify whether the \'soft delete\' functionality is enabled for this key vault.')
param enableSoftDelete bool = true

@description('softDelete data retention days. It accepts }=7 and {=90.')
param softDeleteRetentionInDays string = '90'

@description('Property specifying whether protection against purge is enabled for this vault. Setting this property to true activates protection against purge for this vault and its content - only the Key Vault service may initiate a hard, irrecoverable deletion. The setting is effective only if soft delete is also enabled.')
param enablePurgeProtection bool = true
param keyVaultFirewallDefaultAction string = 'deny'
param keyVaultFirewallBypass string = 'None'

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: resourceGroup().location
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enableRbacAuthorization: enableRbacAuthorization
    tenantId: tenantId
    sku: {
      name: keyVaultSKUName
      family: keyVaultSKUFamily
    }
    enableSoftDelete: enableSoftDelete
    enablePurgeProtection: enablePurgeProtection
    softDeleteRetentionInDays: softDeleteRetentionInDays
    networkAcls: {
      bypass: keyVaultFirewallBypass
      defaultAction: keyVaultFirewallDefaultAction
    }
  }
}
