---
layout: post
title:  "Powershell Modules in Azure Functions"
date:   2018-07-22 08:34:28 +0200
categories: blogpost
---
# Setting up the environment

Until recently, adding modules to Azure Powershell based Functions has been a real drag.

You had to upload the module you wanted to a subfolder named "modules" under each function and if you needed a module in several functions, you had to have the same module in the module folder of each fuction.

You could also upload stuff with Kudu, FTP, Visual Studio or VSTS, but the beauty and simplicity of Install-Module has not been available.

## NuGet

First off make sure, that the NuGet package provider is installed. Microsoft has not installed it on the servers running Azure Functions. I usualy add this to by script:

``` Powershell
# Try to get the NuGet module - this will provide an error, that can be used for the catch
try {
    $NuGet = Get-PackageProvider -ListAvailable -Name NuGet -ErrorAction Stop
} Catch {
    # Logging to the console in Azure gives a warm and cosy feeling and provides documentation for your scripts
    Write-Output "Installing NuGet"
    Install-PackageProvider NuGet -Scope CurrentUser -Force
}

```

The next step is to make sure you can load the modules. Since you are not local administrator on the machine running Powershell, you are not allowed to install modules in the global scope, but you can stil install modules in the CurrentUser scope.

For installing modules in the CurrentUser scope, you need 2 things in place:

* Your private modules folder should exist
* Your private modules folder should be in the PSModulePath variable

## Your private modules folder

The Powershell environment variables on Azure Function servers are accessed in the same way as in any other Powershell console. Your private modules folder ahould be located exactly here: ```$($env:UserProfile)\Documents\WindowsPowershell\Modules```

For some reason, this folder is not created. This can be mended by putting this in your script:

```Powershell
# Create a variable holding the wanted path
$PSLocalModulePath = "$($env:UserProfile)\Documents\WindowsPowershell\Modules"
# Test the existance of the path, and create it, if it doesn't exist
if (!$(Test-Path $PSLocalModulePath)){
    Write-Output "Creating $PSLocalModulePath"
    New-Item -ItemType Directory -Path $PSLocalModulePath -Force | Out-Null
}
```

## The PSModulePath environment variable

The $env:PSModulePath holds all the paths where Powershell looks for installed modules.

There is a little twist on this variable in Azure Functions servers t. The paths in this variable in Azure Function servers are these:

``` Powershell
D:\Program Files\WindowsPowerShell\Modules
WindowsPowerShell\Modules
D:\Program Files (x86)\WindowsPowerShell\Modules
D:\Windows\system32\WindowsPowerShell\v1.0\Modules
D:\Program Files\WindowsPowerShell\Modules\
D:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ResourceManager\AzureResourceManager\
D:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\
D:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\Storage\
D:\Program Files\Microsoft Message Analyzer\PowerShell\
```

Clearly the path to tne CurrentUsers modules is missing and instead a useless "WindowsPowerShell\Modules" is in there.

To fix this, you could put something like this in your script:

``` Powershell
# Get an array with the module paths
[string[]]$ModulePaths = $env:PSModulePath -split ';'
# Find the broken path(s)
[string[]]$BrokenPaths = $ModulePaths | where {$_ -notmatch '^\w:'}
# Remove the broken paths and doublets and create a new array
[string[]]$GoodPaths = $ModulePaths| where {$BrokenPaths -notcontains $_} | Select-Object -Unique
# Only update the variable, if the local module path is missing
if ($GoodPaths -notcontains $PSLocalModulePath){
    Write-Output "Adding $PSLocalModulePath to PSModulePath"
    # Add the local module path first in the PSModulePath
    $NewModulePath = $PSLocalModulePath, $($GoodPaths -join ';') -join ';'
    $env:PSModulePath = $NewModulePath
}

```

Powershell looks for modules in the order in ```$env:PSModulePath``` when auto-loading modules. Hence placing newer versions of ex. AzureRM.Resources in your local modules folder, will load these prior to the once installed in other places, if you place your local module folder first in the environment variable.

## Installing the modules

You are all set and good to go. Now you can install any module available to you by running:

``` Powershell
$MyModule = "Replace with your module"
if (!$(Test-Path $(Join-Path $PSLocalModulePath $MyModule))){
    Write-Output "Installing $MyModule"
    Install-Module $MyModule -Scope CurrentUser -Force
}
```

# Conclusion

The beauty of this method is, that you don't have to hassle with FTP, Kudu, Visual Studio, VSTS or any of the other fine tools used for putting stuff to your Azure Function.

As an added bonus, all the modules you install via this method, are available from all the functions on the same App Plan.

Every time you restart your Function, all your modules loaded in this way are removed. This makes good sense, your workload is moved around. Hence it is a good idea to include the entire setup in the top of your scripts. Find the entire script here:

{% gist f057d5ef1f6eb9209e299096cd4aa8b0 %}