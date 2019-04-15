---
layout: post
title: "CPUStressTest"
date:   2019-04-15 07:00:00 +0100
categories: blogpost
---
# CPUStressTest

If you ever wanted a way of running scripts at different CPU loads, you might want to utilize the CPUStressTest Powershell Module

This module makes it possible to add different load percentages on various combinations of CPUs.

Feel free to give it a spin.

```ps
Import-Module CPUStressTest
```

# Documentation

Just read the help on the Cmdlets

```ps
PS C:\> help CPUStressTest

Name                              Category  Module                    Synopsis
----                              --------  ------                    --------
Stop-CPUStressTest                Function  CPUStresstest             Stops a CPUStressTest
Start-CPUStressTest               Function  CPUStresstest             Start a CPU stress test

S C:\> help Start-CPUStressTest -Examples

NAME
    Start-CPUStressTest

SYNOPSIS
    Start a CPU stress test


    -------------------------- Example 1 --------------------------

    PS C:\> Start-CPUStressTest -loadPct 50 -CPUs 4

    Starts 4 Jobs that calculates $++ for ½ second and then sleeps for ½ second until the jobs are removed, usualy by Stop-CPUStressTest

```