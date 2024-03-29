---
layout: post
title: "AxKeyVaultExtension"
date:   2023-02-19 08:00:28 +0000
categories: blogpost
---

# Introduction

This [Microsoft.PowerShell.SecretManagement](https://github.com/PowerShell/SecretManagement) extension is for cloud architects, who often access multiple secrets on multiple subscriptions in multiple tenants and everyone else interested in keeping secrets secret in Azure Key Vault.

The benefits of Microsoft.PowerShellSecretManagement is that all the nice things you know from PowerShell like tab-completion and well-known switches is wrapped around the extensions.

# Pre-reqs

You need to have the modules Az.Accounts and Az.KeyVault on your machine - most people install the Az module, that includes these modules. You also need to connect to at least one subscription with a Key Vault. By running ```Connect-AzAccount -SubscriptionId <YourGuidHere>```, an Azure Context is stored on your machine.

You can see a list of contexts on your mashine by running ```Get-AzContext -ListAvailable```. These contexts can be renamed to something more simple the the autogenerated names by running ```Rename-AzContext -SourceName <longWierdName> -TargetName <NiceShortName>```

Of course the account you use to connect to your Az Context, also needs to have access to the Key Vault on the Key Vault Access Policy.

# Install

Install the following modules:

```powershell
Install-Module Microsoft.PowerShell.SecretManagement
Install-Module AxKeyVault
```

Setup your SecretVault:

```powershell
$AzContextName = 'AxContext' # Name of a context in your context objects
$KeyVaultName = 'kv-ax-private-p' # A key vault on the context account with proper access policies
$SecretVaultName = 'AxKeys' # The name for your local SecretVault

$regParams = @{
  VaultParameters = @{
    ContextName = $AzContextName
    KeyVaultName   = $KeyVaultName
  }
  Name = $SecretVaultname
  ModuleName = 'AxKeyVault'
}
Register-SecretVault @regParams
```

Your Vault is now reedy to use. If you query a vault in another context then the current, the secret is retrieved and context reset to what it was before the secret retrieval.

If VaultName is omitted, the default Vault is used

Getting a secret is as easy as:

```powershell
Get-Secret -Name MySecret

<#
Returns:
System.Security.SecureString

If you need the clear text value run:
#>

Get-Secret -Name MySecret -AsPlainText
<#
Returns:
Pa$$w0rd
#>
```

# Additional functionality

The AxKeyVault extension supports storing credential objects in the Key Vault

```powershell
$Cred = Get-Credential # Fill in your credential set

Set-Secret -Name $Cred -Vault AxKeys

Get-Secret -Name AxCred -Vault AxKeys

<#
Returns:
UserName                     Password
--------                     --------
Axel     System.Security.SecureString
#>
```