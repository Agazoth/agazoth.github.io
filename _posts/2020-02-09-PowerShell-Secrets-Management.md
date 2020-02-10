---
layout: post
title: "PowerShell Secrets Management"
date:   2020-2-9 17:00:28 +0200
categories: blogpost
---

## Introduction

Getting your keys from different vaults from within your code or in the console when working with sensitive data and several tokens, passwords and API secrets has been a drag for a long time. Now the long awaited PowerShell SecretsManagement module has been released in a in a Development release. And what a release it is (at least for Windows - for now)!

## The module

Installing the module is a breeze. Just run the following:

```powershell
Install-Module -Name Microsoft.PowerShell.SecretsManagement -AllowPrerelease
```

This gives you these cmdlets:

```powershell
Add-Secret
Get-Secret
Get-SecretInfo
Get-SecretsVault
Register-SecretsVault
Remove-Secret
Unregister-SecretsVault
```

This gives you the basic functions for managing credentials in the local credentials vault. You can store secrets and credentials locally and these credentials are governed by the local Credential Manager.

## Secrets

You can add a few secrets and credentials by running the Add-Secret cmdlet and they will be available in your shell immediately with the Get-Secret cmdlet.

You can go to your Credentials Manager and see the secrets you have stored.

My keys in PowerShell Secrets Manager:

```powershell
PS C:\> Get-SecretInfo -Vault BuiltInLocalVault

Name     Vault             TypeName
----     -----             --------
Creds    BuiltInLocalVault PSCredential
Testcred BuiltInLocalVault PSCredential
TestKey  BuiltInLocalVault String
```

And the same keys in Credentials Manager:

![CredMan]({{ site.url }}/images/credman.png)

As the picture shows, all secrets are prefixed with __PS_

## Extensions

With the local local in place, it is time to add all the other vaults one tends to collect over the years. The PowerShell Secrets Management framework let's you add your own extensions to any key vault you can access from PowerShell in a homogenous and secure fashion.

The framework is described in detail here: [Pauls Blog](hhttps://devblogs.microsoft.com/powershell/secrets-management-module-vault-extensions/)

The short version is, that you need to arrange your extension like a convensional module, burt with a little twist.

Your scaffolding should look like this:

```powershell
AxKeyVaultExtension
│   AxKeyVaultExtension.psd1
│
└───ImplementingModule
        ImplementingModule.psd1
        ImplementingModule.psm1
```

The module pds1 is pretty basic. It only needs to contain this:

```powershell
@{
    ModuleVersion = '1.0'
}
```

The ImplementingModule folder contains the real module. This structure has been chosen to hide the cmdlets from auto-discover. It contains 2 files, that are the actual module for the extension module. The names here are mandatory (until the extension module might be renamed to SecretsManagementExtension in an upcoming release.)

The ImplementingModule.psd1 is pretty straight forward. It only needs to contain this:

```powershell
@{
    ModuleVersion = '1.0'
    RootModule = '.\ImplementingModule.psm1'
    FunctionsToExport = @('Set-Secret','Get-Secret','Remove-Secret','Get-SecretInfo')
}
```

The ImplementingModule.psm1 file is the one that contains your integration to your key vault. This is where you have to do some work. The scaffolding of the file should be like this:

```powershell
function Set-Secret
{
    param (
        [string] $Name,
        [object] $Secret,
        [hashtable] $AdditionalParameters
    )
}

function Get-Secret
{
    [CmdletBinding()]
    param (
        [string] $Name,
        [hashtable] $AdditionalParameters
    )
}

function Remove-Secret
{
    param (
        [string] $Name,
        [hashtable] $AdditionalParameters
    )
}

function Get-SecretInfo
{
    param (
        [string] $Filter,
        [hashtable] $AdditionalParameters
    )
}

```

You can (and should) add add other functions to the module file to make it handle your vault. Get-Secret and Get-SecretInfo are the only mandatory functions according to the current documentation, but as long as you use the basic scaffolding, the extension will run just fine, even though it doesn't really do anything.

Once you start adding code to your extension, you quite soon figure out, that you need to store some secrets to access the vault. For this purpose, Register-SecretsVault has a VaultParameters. This parameter takes a hashtable that you can reference in your extension module by calling $AdditionalParameters from the scaffolding.

## Azure Key Vault

As an added bonus to the development release, Paul Higinbotham has released a Azure Key Vault extension that you just need to compile according to the description above. This gives you a wonderful integration where you only need to register your extension module with VaultParameters for your subscription and your key vault name.

I have really been looking forward to this framework, because I have so many key vaults scattered across different tenants and different subscriptions. In my work routine I use multiple Azure Context, hence I have made an Azure Key Vault extension that can maintain any Azure Key Vault without having to sign in or switching accounts based on the context autosave feature.

The extension is available at the PowerShell gallery:

```powershell
Install-Module AxKeyVaultExtension
```

Now you need to find your saved Azure Context:

```powershell
Get-AzContext -ListAvailable | Select-Object  Name
```

This gives you a list of the saved Contexts. Just copy the context that grants access to the subscription, where your Key Vault is located. Even though you rename the subscription, the connection will work, but if you delete the context, you will have to re-register the vault.

This is how the vault is registered:

```powershell
Register-SecretsVault -Name AxKeys -ModuleName AxKeyVaultExtension -VaultParameters @{ContextName = 'SubName (SubscriptionIDaGUID) - AccountThatHasAuthenticated'; VaultName = 'MyKeyVaultName'}
```

Now all the keys in the Key Vault can be retrieved or updated by running the PowerShell Secret Management cmdlets even if you change the Az context.

The extension encrypts the string, if you just supply a clear text string:

```powershell
PS C:\> Add-Secret -Name SecretTest -Secret 'JustAString' -Vault AxKeys
PS C:\> Get-Secret SecretTest
System.Security.SecureString
PS C:\> Get-Secret SecretTest -AsPlainText
JustAString
```

Keeping secrets secret has never been easier!