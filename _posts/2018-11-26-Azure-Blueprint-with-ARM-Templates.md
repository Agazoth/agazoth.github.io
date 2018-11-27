---
layout: post
title: "Azure Blueprint with ARM Templates"
date:   2018-11-26 21:00:00 +0100
categories: blogpost
---
# Azure Blueprint with ARM Templates

If you have been implementing Azure environments with ARM Templates, you probably have your own library with polished and shiny templates with lots of fine tuned parameters.

These ARM Templates can now be imported directly into an Azure Blueprint with the Import-AzureBlueprintArtifact cmdlet and then pushed directly to any given Management Group by using my AxAzureBlueprint Module [Azure Blueprint - the easy way](/../../2018-11-11-Azure-Blueprint.md) or simply run:

```powershell
Install-Module AxAzureBlueprint
```

## Adding an ARM Template

Start out by creating an empty folder - the folder name will become the name of your Blueprint.

```powershell
PS C:\Dev> New-Item -ItemType Directory -Name NewARMBlueprint


    Directory: C:\Dev


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----        11/26/2018  9:43 PM                NewARMBlueprint
```

Find one of your favorite ARM templates (or be lazy and download one from GitHub). This one will do for this example:

```powershell
Invoke-RestMethod -Uri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-batchaccount-with-storage/azuredeploy.json | convertto-json -Depth 99 | out-file C:\Temp\batchwithstorage.json
```

Now create a new Blueprint and artifact in the newly created foder by running this command:

```powershell
Import-AzureBlueprintArtifact -ARMTemplateJson C:\Temp\batchwithstorage.json -TargetDirectory C:\Dev\NewARMBlueprint -ResourceGroup MyBatch -ArtifactName BatchAndStorage
```

Now you should have 2 new files in your Blueprint folder:

```powershell
PS C:\Dev> Get-ChildItem C:\Dev\NewARMBlueprint\


    Directory: C:\Dev\NewARMBlueprint


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        11/26/2018  9:54 PM           2454 BatchAndStorage.json
-a----        11/26/2018  9:54 PM           1066 blueprint.json
```

If you like, you can add additional ARM templates with the Import-AzzureBlueprintArtifact.

Now you should run Connect-AzureRMAccount and connect to your Management Group - I have one called AxTest - and set your new Blueprint:

```powershell
Connect-AzureBlueprint -ManagementGroupName AxTest
Set-AzureBlueprint -BlueprintFolder C:\Dev\NewARMBlueprint\
```

You can now find your new Blueprint draft in the Azure Portal:

![ARM Blueprint]({{ site.url }}/images/armblueprint.png)

Publish the Blueprint and enjoy your fine parameters from your original ARM Template when assigning the Blueprint:

![ARM Blueprint]({{ site.url }}/images/batchdetails.png)

## Conclusion

I believe this makes Azure Blueprints very accessible and usefull. Please give it a spin and let me know, if you encounter any bugs or have any feature requests.