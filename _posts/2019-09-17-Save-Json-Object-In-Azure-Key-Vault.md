---
layout: post
title: "Save JSON Object in Azure Key VAult"
date:   2019-9-17 17:00:28 +0200
categories: blogpost
---

## Introduction

Sometimes you just want to save a bunch of keys in a secure place in an easy way. This can be configuration stuff, Device infos and other stuff with sensitive information. In such cases, you can combine a JSON object and Azure Key Vault.

## Requirements

* Some kind of JSON, or just an object that can be converted to JSON, that you want to store in a safe place
* An Azure subscription
* An Azure Key Vault with write access to secrets

## How-To

For this demo, I'll use a dummy JSON object.

```powershell
$JSON = @"
{
"DeviceID" : "cba3f2c3-af89-4902-ab4a-756de1d864b5",
"Description": "ThisCanBeStored",
"FirstPublicSecret": "FirstPublicButSecret",
"SecondPublicSecret": "SecondPublicButSecret",
"PrivateSecret": "ThisShouldNotGoInTheVault-ItsSecret!"
}
"@
```

Now only the values that should be stored needs to be extracted. I like converting the JSON to an object, extract the parameters I want and then convert the object back to JSON.

```powershell
$JSONForStorage = $JSON | ConvertFrom-Json | Select-Object DeviceID, Description, FirstPublicSecret, SecondPublicSecret | ConvertTo-Json

# Which leaves this in the new variable:

$JSONForStorage                                                     {
  "DeviceID": "cba3f2c3-af89-4902-ab4a-756de1d864b5",
  "Description": "ThisCanBeStored",
  "FirstPublicSecret": "FirstPublicButSecret",
  "SecondPublicSecret": "SecondPublicButSecret"
}
```

Now I need to connect to my Tenant and select the proper Subscription

```powershell
Connect-AzAccount
# Fill out the GUI or open a browser and authenticate, depending on your PS version

# when connected, select the proper subscription.
$MySubscription = 'MySubscription'
Select-AzSubscription -SubscriptionName $MySubscription
```

Now to the fun stuff - putting the JSON string in the Key Vault. The clear-text string needs to be converted to a secure string prior to uploading it to Azure Key Vault. Azure CLI does this on the fly.

```powershell
$MyKeyVault = 'MyKeyVault'
Set-AzKeyVaultSecret -VaultName $MyKeyVault -Name MySecretJson -SecretValue ($JSONForStorage | ConvertTo-SecureString -AsPlainText -Force)
```

And that's it. Just to prove, that the value is actually set, I'll retrieve it again and display the SecretValueText.

```powershell
Get-AzKeyVaultSecret -VaultName $MyKeyVault -Name MySecretJson | Select-Object -ExpandProperty SecretValueText
{
  "DeviceID": "cba3f2c3-af89-4902-ab4a-756de1d864b5",
  "Description": "ThisCanBeStored",
  "FirstPublicSecret": "FirstPublicButSecret",
  "SecondPublicSecret": "SecondPublicButSecret"
}
```

Have fun!

## Caveats

Make sure to keep the JSON string length under 25601. Anything bigger seems to produce bad requests for now.
