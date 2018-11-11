---
layout: post
title: "Increment Build and Version in PSake"
date:   2018-09-12 19:30:28 +0200
categories: blogpost
---
# The task

I have been having a lot of fun playing around with [PSake](https://www.google.dk/search?q=psake&oq=psake&aqs=chrome..69i57j69i60l2j69i59l3.831j0j4&sourceid=chrome&ie=UTF-8) for a few weeks now, and I am pretty close to having automated my entire workflow for building Powershell Modules.

Yesterday I wanted to update a module on the [Powershell Gallery](https://www.powershellgallery.com/), but the publish command failed, because I hadn't updated the version number in my module manifest. This was not the first time that happend.

After a quick browse in the documentation, I found no built-in way to do this, so I set out to build auto-incrementation of Build, Minor and Major versions.

# The solution

Thanks to the great work of the team behind PSakes and especially [Brandon Olin](https://twitter.com/devblackops), the strict syntax and logical structure of PSake allowed me to do just that in very few lines of code.

I find that using the properties scriptblock in the top of my PSake file holding the variables I use throughout my tasks, is the easiest way to handle the many variables.  For the purpose of updating the build number I only need to know the path to the psd1 file, so I have this:

```powershell
properties {
    # This needs to be updated to fit your build
    $psd1 = $ModuleRootFolder\MyModule.psd1
}
```

Variables in the properties block are in the script scope and available to all tasks.

I then added the following task to my PSAke task:

```powershell
Task IncrementVersion {
    # Get the current Version object of the module
    $CurrentVersion = Test-ModuleManifest $Script:psd1 | Select-Object -ExpandProperty Version
    # Unfortunately there is no way of incrementing a Version object,so you have to:
    # Get the Build, Minor and Major version,
    $Build = $ModuleManifestVersion.Build
    $Minor = $ModuleManifestVersion.Minor
    $Major = $ModuleManifestVersion.Major
    # increment it
    $Build++
    # create a new Version object
    $NewVersion = [System.Version]$("{0}.{1}.{2}" -f $Major,$Minor,$Build)
    # and finally update the module mainfest with the new Version
    Update-ModuleManifest -Path $psm1 -ModuleVersion $NewVersion
}
```

Easy-peasy, but I also wanted to be able to update minor and major versions on demand, without having to write a new task for that. Another dive in the documentation revealed, that PSake has a parameter switch, that takes a hashtable and turns them into variables in the task.

I added a little more logic to the task, and ended up with this:

{% gist c4021672eec42af83080b0f4163c8963 %}

Now I run my daily builds with the IncrementVersion in the dependencies of my Build task like this:

```Powershell
Invoke-PSake -buildFile .\MyModule.psake.ps1 Build
```

And if I want to update the major version I just need to add the parameter for IncrementMajorVersion like this:

```Powershell
Invoke-PSake -buildFile .\MyModule.psake.ps1 Build  -parameters @{"IncrementMajorVersion" = $true}
```

Now my builds are always updated and ready for the Powershell Gallery.