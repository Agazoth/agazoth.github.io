---
layout: post
title: "PowerShell SecretManagement Preview 3"
date:   2020-9-19 08:00:28 +0200
categories: blogpost
---

# Mind your secrets!

After waiting what seems for ages, we finally got an update on PowerShell Secret Management from the awesome PowerShell team! If you are worried about keeping your passwords safe and easily available in your PowerShell command line, you need to install this module now!

[Here](https://devblogs.microsoft.com/powershell/secretmanagement-preview-3/) you find the release notes of SecretManagement Preview 3. It is really easy to install and even easier to enable a local, password protected SecretStore. Just paste the first 3 lines in the code box right at the top of the page.

Everything is documented neatly and should cover your security concerns.

# Azure DevOps Secrets

As a DevOps engineer, I have a lot of different key vaults scattered over lost of tenants and subscriptions. I find it a tedious task to switch between tenants and subscriptions in the command line, just to retrieve a secret from a specific key vault.

In order to provide easy access to these key vaults, I developed my own extension for PowerShell SecretManagement. The extension allows me to use the built-in cmdlets in PowerShell SecretManagement and best of all I do not have to switch tenant and subscription manually to retrieve my secrets.

If you want to try how easy it is to retrieve cross tenant, cross subscription secrets (and credentials) directly from your PowerShell command line follow these instructions.

# Prereqs

Install the modules from Sydneys [blog](https://devblogs.microsoft.com/powershell/secretmanagement-preview-3/)

The first 2 lines of the first code blog gives you all you need.

```powershell
Install-Module Microsoft.PowerShell.SecretManagement -AllowPrerelease
Install-Module Microsoft.PowerShell.SecretStore -AllowPrerelease
```

## Install AxKeyVault

Then you need to install my extension. It's in the PowerShell gallery, so that's done just as easy.

```powershell
Install-Module AxKeyVault
```

The extension requires you to have AzContext Autosave enabled. You can enable it by running:

```powershell
Enable-AzContextAutosave
```

This command enables that your authentications to a given tenant and a given subscription are saved locally in your profile. The authentication lasts for up to 3 months. When they expire, you need to login again and the information is saved for 3 more months.

If you need reassurance regarding this procedure, please read more [here](https://docs.microsoft.com/en-us/powershell/azure/context-persistence)

If you want to see, if you already have this enabled, run:

```powershell
Get-AzContext -ListAvailable
```

# Connect to Azure

If you did not have Autosave enabled before, you will need to connect to your tenant and subscription. In PowerShell 7.0 you just go:

```powershell
Connect-AzAccount
```

You will get a url and an code for logging in. This procedure is pretty basic and you probably already tried this dozens of times. If not, refer to [this](https://docs.microsoft.com/en-us/powershell/module/az.accounts/connect-azaccount) manual.

To be sure to get the correct subscription and the correct tenant, these values can be added to the command, so you get something like:

```powershell
$TeanatId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
$SubscriptionId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
Connect-AzAccount -TenantId $TeanatId -SubscriptionId $SubscriptionId
```

# Taming your Context

When you log on to Azure in PowerShell, the Name of your context is usually a combination of Subscription name, Subscription Id and the account you log on with. In short, a very long string!

In order to make your saved context more accessible, you will want to rename them. That is easily done by the following command:

```powershell
$SourceName = 'Whatever long name your AzContet has'
$TargetName = 'NiceShortName'
Rename-AzContext -SourceName $SourceName -TargetName $TargetName
```

# The Azure Key Vault
If you have an existing key vault with sufficient policy access, you may skip this step and continue [here](#Extension-Setup). If you do and encounter errors, return and read.

Be sure to update your Az modules. Some of the older ones create wierd key vaults that cannot be accessed by what follows here. Currently I am on 2.1.0 of Az.KeyVault.

This will update your Az modules:

```powershell
Install-Module Az -force
```

Connect to your account to create a new Key Vault. ```$TargetName``` hold the correct name of the desired tenant and subscription context, if you did the steps above.

```powershelll
Select-AzContext -Name $TargetName 
```

Create a resource group and a key vault.

```powershell
$Location = 'West Europe'
$ResourceGroupName = 'MyResourceGroup'
$KeyVaultName = 'MyKeyVaultName'

New-AReaourceGroup -Name $ResourceGroupName -Location $Location

New-AzKeyVault -Name $KeyVaultName -ResourceGroupName $ResourceGroupName -Location $Location
```

Then Make sure your desired account has access to the secrets. The account you just used for creating the key vault already has an Access Policy entry, but you might want to add another user. In PowerShell you can do:

```powershell
$EmailAddress = 'YourUPN@YourDomain.com'

Set-AzKeyVaultAccessPolicy -VaultName $KeyVaultName -EmailAddress $EmailAddress -PermissionsToSecrets list, get, set, delete
```

# <a id="Extension-Setup"></a> AxKeyVault Extension setup

With everything in place it is time to set up the PowerShell SecretManagement Extension. All you need to do is this:

```powershell
$SecretVaultName = 'MySecretVault' # should be globally unique
$KeyVaultName = 'MyKeyVaultName' # A key vault the context account has access to
$TargetName = 'NiceShortName' # Name of the context with access to your key vault

$VaultParameters = @{
    ContextName = $TargetName
    VaultName   = $KeyVaultName
}

Register-SecretVault -Name $SecretVaultname -ModuleName AxKeyVault -VaultParameters $VaultParameters
```

That's it. Now your secrets can be accessed in the key vault.

# Adding secrets

If you do not have any secrets in there yet, you can just add some like this

```powershell
Set-Secret -Name 'MyFirstSecret' -Secret 'VerySecretString' -Vault $SecretVaultName
```

Check to see your newly added secret

```powershell
Get-SecretInfo -Vault $SecretVaultName

Name                  Type VaultName
----                  ---- ---------
MyFirstSecret SecureString MySecretVault
```

# Adding credentials

I very often need to add credentials to commands. AxKeyVault supports PSCredentialObjects. If you want to store credentials, you do like this

```powershell
$Credential = Get-Credential
# Type your username and password

Set-Secret -Name 'MyFirstCredential' -Secret $Credential  -Vault $SecretVaultName
```

And now your credential set is in the Key Vault

```powershell
Get-SecretInfo -Vault $SecretVaultName

Name                      Type VaultName
----                      ---- ---------
MyFirstCredential PSCredential MySecretVault
MyFirstSecret     SecureString MySecretVault
```

And when you need your credential set again, you get it by running the Get-Secret command.

```powershell
$SavedCredential = Get-Secret 'MyFirstCredential' -Vault $SecretVaultName

$SavedCredential | Get-Member


   TypeName: System.Management.Automation.PSCredential

Name                 MemberType Definition
----                 ---------- ----------
Equals               Method     bool Equals(System.Object obj)
GetHashCode          Method     int GetHashCode()
GetNetworkCredential Method     System.Net.NetworkCredential GetNetworkCredential()
GetObjectData        Method     void GetObjectData(System.Runtime.Serialization.SerializationInfo info, System.Runtime…
GetType              Method     type GetType()
ToString             Method     string ToString()
Password             Property   securestring Password {get;}
UserName             Property   string UserName {get;}
```

# Caveats

Storing and retrieving secrets in Azure is easy! You can use this method to access you secrets and credentials from the command line secured by your logon token. The same secrets are available in Azure and can be used by Service Accounts, Web Apps and other fine Cloud products. You can set this up on any machine and access your secrets from anywhere.

There are a few quirks though:

* You will have to update your credentials every now and then (every 3 months)
* The PSKeyVaultSecret output type will be changing. AxKeyVault uses the output and thus will be deprecated in version 3.0.0. AxKeyVAult will be updated as soon as more information is available.
* Some key vaults do not work with this method. I only encountered this on key vaults created with very old versions of Ax.KeyVault.