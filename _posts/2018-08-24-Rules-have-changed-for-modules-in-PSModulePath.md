---
layout: post
title: "Rules have changed for modules in $env:PSModulePath"
date:   2018-08-25 09:00:28 +0200
categories: blogpost
---
# Exported Commands
Yesterday I uploaded a new module to the Powershell Gallery. I use the non-monolithic style, where the different functions in the module are dot-sourced in the psm1 and finally run Export-ModuleMember on functions and cmdlets in the module. My psm1 file looks a bit like this:
```Powershell
$Public  = Get-ChildItem $PSScriptRoot\*.ps1 -ErrorAction SilentlyContinue

 Foreach($import in @($Public)){
    . $import.fullname
}
    
Export-ModuleMember -Function $($Public | Select-Object -ExpandProperty BaseName)
```

This method has been working just fine, but after uploading my working module and installing it again from the gallery, I realized, that no ExportedCommands were available.

I decided to look at all modules, that had no Exported Commands, and found this:
```Powershell
ModuleType Version Name              ExportedCommands
---------- ------- ----              ----------------
Script     1.0.0   AxSQLServerCe
Script     1.0.0   AxCosmosDB
Script     1.0.5   AxCredentialVault
Script     0.6.0   AzurePSDrive
Script     5.7.0   AzureRM
Binary     0.8.0   SHiPS
```

After a bit of debugging it turns out, that I had to update the module manifest from * to the specific function names to get them to show up as ExportedCommands and after an update to PSGallery, i got:
```Powershell
ModuleType Version Name          ExportedCommands
---------- ------- ----          ----------------
Script     1.0.2   AxSQLServerCe {Connect-SdfFile, Invoke-SdfCmd, New-SdfFile}
```

Rules seems to have changed and now I need to update my other modules.

# The plot thickens
After discussing this issue with [Chris Gardner](https://twitter.com/HalbaradKenafin), a brilliant PS nerd, it became clear, that this behavior is not caused by the gallery - hence the title for this blog post has changed.

I have now testet the builtin "Load everything in $env:PSModulePath" functionality on 3 different machines. 2 of them behave the same (see Computer 2), hence only 2 examples are given here.

## AxSQLServerCe
The AxSQLServerCe module has the exported commands in the psd1 file:
```Powershell
  FunctionsToExport = @('Connect-SdfFile'
						'Invoke-SdfCmd'
						'New-SdfFile')
```

## AxCosmosDB
The AxSQLServerCe module has the exported commands in the psd1 file:
```Powershell
  FunctionsToExport = "*"
```

## Both machines
```Powershell
PS C:\> $ExecutionContext.SessionState.LanguageMode
FullLanguage
PS C:\> Get-ExecutionPolicy
Unrestricted
```


## Computer 1
```Powershell
PS C:> $host


Name             : ConsoleHost
Version          : 5.1.17746.1000
InstanceId       : 41d58e22-8241-453b-9cbb-5267e4e2012a
UI               : System.Management.Automation.Internal.Host.InternalHostUserInterface
CurrentCulture   : da-DK
CurrentUICulture : en-US
PrivateData      : Microsoft.PowerShell.ConsoleHost+ConsoleColorProxy
DebuggerEnabled  : True
IsRunspacePushed : False
Runspace         : System.Management.Automation.Runspaces.LocalRunspace



PS C:\> Get-Module -ListAvailable -name Ax* -Verbose
VERBOSE: Populating RepositorySourceLocation property for module AxCosmosDB.
VERBOSE: Loading module from path
'C:\Users\axel\OneDrive\Dokumenter\WindowsPowerShell\Modules\AxCosmosDB\1.0.0\AxCosmosDB.psm1'.
VERBOSE: Populating RepositorySourceLocation property for module AxSQLServerCe.
VERBOSE: Loading module from path
'C:\Users\axel\OneDrive\Dokumenter\WindowsPowerShell\Modules\AxSQLServerCe\1.0.2\AxSQLServerCe.psm1'.
VERBOSE: Loading module from path 'C:\Users\axel\OneDrive\Dokumenter\WindowsPowerShell\Modules\AxTest\AxTest.psm1'.


    Directory: C:\Users\axel\OneDrive\Dokumenter\WindowsPowerShell\Modules


ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     1.0.0      AxCosmosDB                          {Remove-CosmosDocument, Test-CosmosDBVariable, Get-CosmosD...
Script     1.0.2      AxSQLServerCe                       {Connect-SdfFile, Invoke-SdfCmd, New-SdfFile}
Script     0.0.1      AxTest                              {Test-SampleCmdlet, Get-Goodbye}
```

## Computer 2
```Powershell
PS C:\> $host


Name             : ConsoleHost
Version          : 5.1.17134.165
InstanceId       : 8c62dc9f-464e-4658-a64c-980b89736129
UI               : System.Management.Automation.Internal.Host.InternalHostUserInterface
CurrentCulture   : da-DK
CurrentUICulture : da-DK
PrivateData      : Microsoft.PowerShell.ConsoleHost+ConsoleColorProxy
DebuggerEnabled  : True
IsRunspacePushed : False
Runspace         : System.Management.Automation.Runspaces.LocalRunspace



PS C:\> Get-Module -ListAvailable -Name Ax* -verbose
VERBOSE: Populating RepositorySourceLocation property for module AxCosmosDB.
VERBOSE: Loading module from path
'C:\Users\RikkeBødskov\Documents\WindowsPowerShell\Modules\AxCosmosDB\1.0.0\AxCosmosDB.psm1'.
VERBOSE: Populating RepositorySourceLocation property for module AxSQLServerCe.
VERBOSE: Loading module from path
'C:\Users\RikkeBødskov\Documents\WindowsPowerShell\Modules\AxSQLServerCe\1.0.2\AxSQLServerCe.psm1'.


    Directory: C:\Users\RikkeBødskov\Documents\WindowsPowerShell\Modules


ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     1.0.0      AxCosmosDB
Script     1.0.2      AxSQLServerCe                       {Connect-SdfFile, Invoke-SdfCmd, New-SdfFile}


PS C:\> Get-Command -Module AxCosmosDB -Verbose

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Connect-CosmosDB                                   1.0.0      AxCosmosDB
Function        Get-CosmosCollection                               1.0.0      AxCosmosDB
Function        Get-CosmosDatabase                                 1.0.0      AxCosmosDB
Function        Get-CosmosDocument                                 1.0.0      AxCosmosDB
Function        New-CosmosCollection                               1.0.0      AxCosmosDB
Function        New-CosmosDatabase                                 1.0.0      AxCosmosDB
Function        New-CosmosDBHeader                                 1.0.0      AxCosmosDB
Function        New-CosmosDocument                                 1.0.0      AxCosmosDB
Function        New-CosmosDocumentQuery                            1.0.0      AxCosmosDB
Function        Remove-CosmosCollection                            1.0.0      AxCosmosDB
Function        Remove-CosmosDatabase                              1.0.0      AxCosmosDB
Function        Remove-CosmosDocument                              1.0.0      AxCosmosDB
Function        Test-CosmosDBVariable                              1.0.0      AxCosmosDB
Function        Update-CosmosDocument                              1.0.0      AxCosmosDB


PS C:\> Get-Module -ListAvailable -Name Ax* -verbose
VERBOSE: Populating RepositorySourceLocation property for module AxCosmosDB.
VERBOSE: Loading module from path
'C:\Users\RikkeBødskov\Documents\WindowsPowerShell\Modules\AxCosmosDB\1.0.0\AxCosmosDB.psm1'.
VERBOSE: Populating RepositorySourceLocation property for module AxSQLServerCe.
VERBOSE: Loading module from path
'C:\Users\RikkeBødskov\Documents\WindowsPowerShell\Modules\AxSQLServerCe\1.0.2\AxSQLServerCe.psm1'.


    Directory: C:\Users\RikkeBødskov\Documents\WindowsPowerShell\Modules


ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     1.0.0      AxCosmosDB                          {New-CosmosDocument, New-CosmosDBHeader, Remove-CosmosColl...
Script     1.0.2      AxSQLServerCe                       {Connect-SdfFile, Invoke-SdfCmd, New-SdfFile}
```

## Thoughts
Strangely enough Computer 1 behaved like Computer 2 the first time I checked it, but after running the Get-Command -Module AxCosmosDB on Computer 1, module autoload started working, even when loading a new console or rebooting the machine.

Computer 2 on the other hand refuses to autoload the module until the Get-Command or Import-Module command is issued. Every time a new console is loaded, I have to run Get-Command -Module AxCosmosDB or Import-Module AxCosmosDB

I tend to believe, that the issue is caused by the different PS versions.

The questions remains:
* Should WPS autoload module commands that are . sourcing ps1 files in the psm1 file and have * in the FunctionsToExport?
* Has this behavior been changed in the different versions of WPS?


Of course best practice is to specify the FunctionsToExport by name and I will be changing by build process as soon as I have a few hours to update the process, but this is still kind of a breaking change, if it is in fact caused by different WPS versions.

# The solution
After yet another test, it turns out, that the autoload of modules starts working if Import-Module is run after Install-Module. That will also make the CmdLets available in new consoles, even after reboot.

Furthermore it seems like Windows Updates (Computer 1 is on fast) resets the imported modules that have * in FunctionsToExport, making a new Import-Module required before the module autoloads correctly.

In short:
For Autoload to work:
Copy modulefolder to $env:PSModulePath/Install from PSGallery
Import-Module ONCE
The module gets loaded every time you start a new console

It would be cool, if Install-Module ran Import-Module after installing the module :-)