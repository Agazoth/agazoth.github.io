---
layout: post
title: "Rules have changed for modules in Powershell Gallery"
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
