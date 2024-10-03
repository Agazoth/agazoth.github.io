---
layout: post
title: "PSParquet Exporting Complex Event Logs"
date:   2024-10-03 06:00:28 +0000
categories: blogpost
---

When dealing with complex data types in PowerShell, converting and exporting them to efficient storage formats such as Parquet can be a challenging task. This guide, inspired by an in-depth GitHub issue discussion, will walk you through the process of exporting `EventLogRecord` data obtained via `Get-WinEvent` into Parquet format, addressing various obstacles and solutions along the way.

## Understanding the Problem

The original issue from the PSParquet repo highlighted a typical PowerShell error when attempting to export complex objects using the `Export-Parquet` cmdlet:
```
Operation failed: Object reference not set to an instance of an object.
WARNING: InputObjects contains unsupported values. Transform the data prior to running Export-Parquet.
```
The error occurs due to unsupported data types in the `EventLogRecord` object, which need to be transformed into simpler types suitable for Parquet format.

## Follow These Steps to Resolve the Issue

### Step 1: Install the PSParquet Module

Ensure you have the PSParquet module installed and updated:

```powershell
Install-Module -Name PSParquet -Repository PSGallery -Force
```

### Step 2: Examine EventLogRecord Properties

Review the properties of the `EventLogRecord` object to understand what needs transformation:

```powershell
$WinEvents = Get-WinEvent -LogName 'Windows PowerShell' -MaxEvents 1
$WinEvents | Get-Member
```

### Step 3: Select Relevant Properties and Transform Complex Types

Construct a custom selection of properties, transforming complex types to JSON strings or omitting irrelevant properties. Here's a tailored example from @Agazoth:

```powershell
# Define necessary transformations for complex properties
$WinEvents = Get-WinEvent -LogName 'Windows PowerShell'
$SelectedEvents = $WinEvents | Select-Object * -ExcludeProperty Bookmark, UserId, ActivityId, Properties, RelatedActivityId, ProviderId, KeywordsDisplayNames, MatchedQueryIds,
@{Name="Bookmark"; Expression={($_.Bookmark | ConvertTo-Json)}},
@{Name="UserId"; Expression={($_.UserId | ConvertTo-Json)}},
@{Name="ActivityId"; Expression={($_.ActivityId | ConvertTo-Json)}},
@{Name="Properties"; Expression={($_.Properties | ConvertTo-Json)}},
@{Name="RelatedActivityId"; Expression={($_.RelatedActivityId | ConvertTo-Json)}},
@{Name="ProviderId"; Expression={($_.ProviderId | ConvertTo-Json)}},
@{Name="KeywordsDisplayNames"; Expression={($_.KeywordsDisplayNames | ConvertTo-Json)}},
@{Name="MatchedQueryIds"; Expression={($_.MatchedQueryIds | ConvertTo-Json)}}
```

### Step 4: Export to Parquet Format

Execute the `Export-Parquet` cmdlet to export the transformed data:

```powershell
$SelectedEvents | Export-Parquet -FilePath 'C:\Temp\WinEvents.parquet' -Force
```

### Step 5: Verify the Exported Data

Import the Parquet file to verify the data types and contents:

```powershell
$ImportedData = Import-Parquet -FilePath 'C:\Temp\WinEvents.parquet'
$ImportedData | Get-Member
```

## Additional Tips

### Handling XML Data

For properties like `Bookmark` which contain XML data, converting them to JSON ensures they are stored in a structured format:
```powershell
$SelectedEvents | Select-Object *, @{Name="BookmarkXml"; Expression={($_.Bookmark | ConvertTo-Json)}}
```

### Filtering and Curating Data

Assess which properties are essential for your use case and adjust your selections and transformations accordingly. This reduces the complexity and size of the dataset.

## Conclusion

Converting and exporting complex `EventLogRecord` data to Parquet format in PowerShell requires careful handling of data types and structures. By selectively transforming properties into simpler types, such as JSON strings, you can efficiently store and manage complex event log data in a Parquet file. With these steps, you'll be able to streamline the process and ensure data integrity throughout your data engineering tasks. Happy scripting!
