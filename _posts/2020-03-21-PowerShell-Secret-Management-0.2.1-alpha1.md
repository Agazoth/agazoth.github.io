---
layout: post
title: "PowerShell Secret Management 0.2.1 alpha1"
date:   2020-3-21 08:00:28 +0200
categories: blogpost
---

## Introduction

After running the PowerShell SecretsManagement module for 1½ month, I'm already quire addicted. It has never been easier storing and retrieving your secret and credentials in PowerShell either locally or in Azure.

I am a heavy user of secrets stored in Azure and I run my Azure Key Vault extension all the time getting and setting keys in different subscriptions and different customer tenants.

Of course I needed to update to the newest release: PowerShell Secret Management 0.2.1-alpha1 and as promised, this version contains breaking changes. It took a little time to adjust the code in my extension to play nice with the new build and the following walkthrough hopefully makes it easier for other extension makers.

## Renaming 
 First off the name has changed from PowerShell Secret**s** Management to PowerShell Secret Management - the plural s is gone and proper naming convention is followed - jay :-)

To overcome this you have to rename the files and folders in the extension like this:

```powershell
MyExtension
│   MyExtension.psd1
│
└───SecretManagementExtension
        SecretManagementExtension.psd1
        SecretManagementExtension.psm1
```
Notice the plural s in Secret is gone.

## New Cmdlets
Most cmdlet names remain the same. If you ran an older version, you probably had Add-Secret. That was changed to Set-Secret in a previous release.

A new Cmdlet has joined the module: Test-SecretVault. Not Test-Vault as it still says in some guides.

I am not really sure, what the Test-SecretVault cmdlet should do, so mine just returns $true as the examples. But it is important to have the cmdlet in your SecretManagementExtension.psm1 and SecretManagementExtension.psd1 files.

## Changes to Cmdlets
In the previous release you had the following param block:
```powershell
    param (
        [string] $Name,
        [hashtable] $AdditionalParameters
    )
```
When you wanted to reference the Vault name, you could go for:
```powershell
$AdditionalParameters.Vault
```

In all the cmdlets this has been changed, so you have to add the $VaultName parameter in the param block like this:
```powershell
    param (
        [string] $Name,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )
```

In the Get-SecretInfo cmdlet a new object type has been implemented. If you do not adapt to this, you cannot use your extension. Before the change you could go like this, when you output your SecretInfo:

```powershell
Write-Output (
    [PSCustomObject]@{
        Name      = "MyName"
        Type      = "String"
        VaultName = "MyVault"
    }
```
Now you need to change that to:
```powershell
Write-Output (
    [Microsoft.PowerShell.SecretManagement.SecretInformation]::new(
        "MyName",
        "String",
        "MyVault")
)
```
With these minor adjustments to your extension, you should be able to install and run PowerShell Secret Management 0.2.1 alpha1 with your own extensions again.

## AxKeyVaultExtension
If you are a heavy user of Azure Key Vault, I'm sure you'll love my Azure Key Vault Extension. It has been updated to run with PowerShell Secret Management 0.2.1 alpha1. All you need to do to get cracking is this:

```powershell
Install-Module -Name Microsoft.PowerShell.SecretManagement -AllowPrerelease
Install-Module -Name AxKeyVaultExtension
```

Check out my post [here]({{ site.url }}/_posts/2020-02-09-PowerShell-Secrets-Management.md) on how to use it.

Finally a HUGE thanks to the team behind PowerShell Secret Management!