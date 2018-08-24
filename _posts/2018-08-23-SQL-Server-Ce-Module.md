---
layout: post
title:  "AxSQLServerCe Module"
date:   2018-08-23 20:52:28 +0200
categories: blogpost
---
Today our developers introduced a new (old) database type in one of their applications. So far the only skill required was a little SQL and SSMS, but this was a different beast.

SQL Server Compact shares a common API with the other Microsoft SQL Server editions. It is based on a single sdf file and is very lightweight. It is also depricated, but will remain in standard life cycle with support end in 2021.

You can install a free GUI to manipulate the database [here](https://sourceforge.net/projects/compactview/)

But that will not put the data in your pipeline!

I whipped up a module to start working with the new files. Please feel free to download or contribute [here](https://github.com/Agazoth/AxSQLServerCe.git) or just install it directly from the Powershell Gallery:
```Powershell
Install-Module AxSQLServerCe -Scope CurrentUser
```