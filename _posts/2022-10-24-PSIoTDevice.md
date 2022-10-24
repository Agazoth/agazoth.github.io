---
layout: post
title: "PSIoTDevice"
date:   2022-10-24 08:00:28 +0200
categories: blogpost
---

# Introduction

I have been playing around with IoT Devices on a large scale recently. I use Azure IoT Hub for managing devices and output, but I wanted a way to let customers create their own devices. Turns out there is another Azure service for that: [Azure IoT Device Provisioning Service](https://learn.microsoft.com/en-us/azure/iot-dps/).

When using DPS, you can let customers provision their own devices to your IoT Hub based on their own unique group master key, so you don't have to hand out the primary key of the IoT Hub. This makes it possible to reset a single customers master key without affecting other customers on the same IoT Hub.

# Pre-requisites

Of course IoT Hub + DPS (and Storage Account, Event Hub or other sink) should be provisioned by bicep, but for the sake of this blog entry, you may provision an IoT Hub, a DPS and a sink as you see fit from the portal.

# PSIoTDevice

For now PSIoTDevice only supports symmetric keys as described [here](https://learn.microsoft.com/en-us/azure/iot-dps/how-to-legacy-device-symm-key?tabs=windows&pivots=programming-language-csharp)

Once your environment is ready, you can use the PSIoTDevice module to create new devices straight from the PowerShell console.

```powershell
Install-Module PSIoTDevice

$params = @{
        DPSIdScope = '0ne666ECA63' # IdScope of the IoT Hub
        DPSGroupSymmetricKey = '8WTOWMMuavYVaJ666vwmMbt3S+YfVuPnC+8y6Q9Icz7pdTD2a29Y+FrAslOxk5rYankO44+GT0SYF0ti0X/LXw==' # Primary key for your enrollment group
        UniqueDeviceId = 'MyPSDevice' # Unique name of your device

$Device = New-DPSGroupDevice @params

```
The devise outputs a PSIoTDevice.DPSMqttSymmetricDevice object.

If you want to test the device, you can use the object in the variable like this:

```powershell
$Device.SendMessage("This message came from my PowerShell device")
```
If all goes well, the command returns:

Message send successfully: True

Now you can find your message in your sink.

# Finally

This module is available to everyone in the PowerShell Gallery and can save you the hassle of compiling the How To binaries in the guide linked in this post.

Please let me know, if you encounter any issues or have requests for further development.