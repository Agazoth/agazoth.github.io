---
layout: post
title: "Azure Blueprint"
date:   2018-11-11 08:00:28 +0100
categories: blogpost
---
# Azure Blueprint - the easy way

At Ignite 2018 Microsoft presented Azure Blueprint for the first time. Azure Blueprint is a uniform way to deliver your ARM templates, Policies and Role Assignments to your Enterprise Subscriptions via CI/CD and source control.

Furthermore Azure Blueprint enables you to update security and other features on all deployments of the Blueprint, making it easy to maintain policies and security in a large Enterprise environment with many subscriptions in different environments.

To get started, you need to organize your subscriptions in Management Groups. That is easily done, if you follow the documentation provided [here](https://docs.microsoft.com/en-us/azure/governance/management-groups/create)

Once your Root Management Group is set up, you are ready to start using Azure Blueprints.

## Azure Blueprint by GUI

Of cource there is a nice GUI in the portal:

![Blueprint Portal]({{ site.url }}/images/blueprintwelcome.png)

![The Blueprints]({{ site.url }}/images/blueprints.png)

And of course you can create a new Blueprint in the portal:

![New Blueprint Definition]({{ site.url }}/images/newblueprintdef.png)

And assign some artifacts to it:

![Artifacts]({{ site.url }}/images/artifacts.png)

Quickly add a resource group and a template - for a quick test [this one](https://github.com/Azure/azure-quickstart-templates/blob/master/101-storage-account-create/azuredeploy.json) will do just fine.

![ResourcegroupsAndTemplates]({{ site.url }}/images/rgandtemplate.png)

Give your Blueprint a version number and publish it:
![Publish]({{ site.url }}/images/publish.png)

Now you're ready to assign your Blueprint to any subscription(s) you like.

But where is the fun in that? And, even more important, where is the CI/CD and source control in in this approach?

## Azure Blueprint by Powershell

There are a few pre-requisites. You should have the latest version of AzureRM.Resources installed (I'm running version 6.5.0 at the moment), and you should have set up Management Groups with the proper access.

If we are to automate Azure Blueprint we have to be able to mainpulate the blueprints form the commandline. An easy way to get started with this is to use Powershell and the AxAzureBlueprint module.

If you areinterested in the sourcecode for this project, it can be found [here](https://github.com/Agazoth/AzureBlueprint)

The module can be installed form the Powershell Gallery, by running:

```powershell
PS C:\>Import-Module AxAzureBlueprint
```

At the moment, the module contains the following cmdlets

```powershell
PS C:\>Get-Command -Module AxAzureBlueprint

CommandType Name                       Version Source
----------- ----                       ------- ------
Function    Connect-AzureBlueprint     0.1.1   AxAzureBlueprint
Function    Get-AzureBlueprint         0.1.1   AxAzureBlueprint
Function    Get-AzureBlueprintArtifact 0.1.1   AxAzureBlueprint
Function    Remove-AzureBlueprint      0.1.1   AxAzureBlueprint
Function    Set-AzureBlueprint         0.1.1   AxAzureBlueprint
```

The cmdlets are pretty self-explanatory and if in doubt, you can always run help on them.

Before you can use the cmdlets in the module, you need to connect to your Azure Tenant. run this cmdlet:

``` powershell
PS C:\>Connect-AzureRMAccount
```

### Create a new Blueprint

First off you need to connect to the Management Group you want to add your new Blueprint to. If you have an existing Management Group containing one or more subscriptions, you need the name of that Management Group. If you want to create a brand new Management Group for your Blueprint, just use the -Force switch when running the Connect-AzureBlueprint cmdlet.

Now you are ready to deploy your first Azure Blueprint from the commandline, but first you need to write the json-templates for the Blueprint.

You should start by creating a folder. The folder name will become the name of your Azure Blueprint.

Open your favorite json template editor. I prefer VS Code and I like to open my Blueprint folder, so I only see the Blueprint I am working on:

![code]({{ site.url }}/images/code.png)

If you want to test how easy it is to create a new Azure Blueprint, just go ahead and add the code below to your Blueprint folder:

{% gist 667fe6b9f457c16a2db5bc12abac8d7f %}

Run the following cmdlet:

```powershell
Set-AzureBlueprint -BlueprintFolder C:\Dev\Vanilla
```

Now you can head over to your Azure Portal and find your Blueprint draft named Vanilla with one artifact called artifact:

![VanillaDraft]({{ site.url }}/images/vanilladraft.png)

And if you edit the Vanilla Draft, you will se, that the artifact has the json template you just published:

![VanillaEdit]({{ site.url }}/images/editvanilla.png)

But what you can't see in the GUI, is the additional information in the original json templates. This information, however, will be revealed, if you retrieve the templates with the apropriate cmdlets in Powershell:

```powershell
PS C:\> Get-AzureBlueprint -Blueprint Vanilla
{
  "properties": {
    "parameters": {
      "storageAccountType": {
        "type": "string"
      },
      "tagName": {
        "type": "string"
      },
      "tagValue": {
        "type": "string"
      },
      "contributors": {
        "type": "array"
      },
      "owners": {
        "type": "array"
      }
    },
    "resourceGroups": {
      "storageRG": {
        "name": "StorageAccount",
        "location": "eastus2",
        "dependsOn": []
      }
    },
    "targetScope": "subscription",
    "status": {
      "timeCreated": "2018-11-10T07:14:36+00:00",
      "lastModified": "2018-11-10T15:29:46+00:00"
    }
  },
  "id": "/providers/Microsoft.Management/managementGroups/AutomatedSubscriptionMaintenance/providers/Microsoft.Blueprint/blueprints/Vanilla",
  "type": "Microsoft.Blueprint/blueprints",
  "name": "Vanilla"
}

PS C:\> Get-AzureBlueprintArtifact -Blueprint Vanilla -Artifact artifact
{
  "properties": {
    "template": {
      "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {
        "storageAccountTypeFromBP": {
          "type": "string",
          "defaultValue": "Standard_LRS",
          "allowedValues": [
            "Standard_LRS",
            "Standard_GRS",
            "Standard_ZRS",
            "Premium_LRS"
          ],
          "metadata": {
            "description": "Storage Account type"
          }
        },
        "tagNameFromBP": {
          "type": "string",
          "defaultValue": "NotSet",
          "metadata": {
            "description": "Tag name from blueprint"
          }
        },
        "tagValueFromBP": {
          "type": "string",
          "defaultValue": "NotSet",
          "metadata": {
            "description": "Tag value from blueprint"
          }
        }
      },
      "variables": {
        "storageAccountName": "[concat(uniquestring(resourceGroup().id), 'standardsa')]"
      },
      "resources": [
        {
          "type": "Microsoft.Storage/storageAccounts",
          "name": "[variables('storageAccountName')]",
          "apiVersion": "2016-01-01",
          "tags": {
            "[parameters('tagNameFromBP')]": "[parameters('tagValueFromBP')]"
          },
          "location": "[resourceGroup().location]",
          "sku": {
            "name": "[parameters('storageAccountTypeFromBP')]"
          },
          "kind": "Storage",
          "properties": {}
        }
      ],
      "outputs": {
        "storageAccountSku": {
          "type": "string",
          "value": "[variables('storageAccountName')]"
        }
      }
    },
    "resourceGroup": "storageRG",
    "parameters": {
      "storageAccountTypeFromBP": {
        "value": "[parameters('storageAccountType')]"
      },
      "tagNameFromBP": {
        "value": "[parameters('tagName')]"
      },
      "tagValueFromBP": {
        "value": "[parameters('tagValue')]"
      }
    },
    "dependsOn": []
  },
  "kind": "template",
  "id": "/providers/Microsoft.Management/managementGroups/AutomatedSubscriptionMaintenance/providers/Microsoft.Blueprint/blueprints/Vanilla/artifacts/artifact",
  "type": "Microsoft.Blueprint/blueprints/artifacts",
  "name": "artifact"
}
```

As you see the properties id, type and name are added to the template.

### Conclusion

Creating and updating Azure Blueprints is incredibly easy. Once you have created a Blueprint, you just update it by changing the existing json templates or adding new artifacts and then setting the entire thing again.

With the AxBlueprintModule you do not need to update the template with the Azure added parameters. The module finds the existing Blueprint and Artifacts and updates them.

The hard part is writing proper templates, but more on that in the following blog post.