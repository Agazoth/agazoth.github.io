---
layout: post
title: "Create a Custom Connector to a MCP Server with Entra ID Authorization"
date:   2025-09-01 06:00:28 +0000
categories: blogpost
---

MCP Servers can utilize Entra ID authorization. This guide is aimed at integrating such servers in M365 Copilot Studio so they can be made available for Microsoft Copilot and Microsoft Teams.

Requirements:

* A working MCP Server with Entra ID Authorization
* VS Code for running the MCP Server locally (for debugging)
* Azure Entra ID

## Initial setup

* Setup your MCP Server with Entra ID authorization to run locally. If you do not have one yet, find inspiration here: https://blog.mitchbarry.com/net-mcp-server-oauth-with-microsoft-entra-id/
* Ensure that your authorization flow runs as expected when using the VS Code mcp client: https://den.dev/blog/vscode-authorization-mcp
* Setup port forwarding and set the port to public: https://code.visualstudio.com/docs/debugtest/port-forwarding

## Create an App Registration

The Power Automate connector for MCP servers requires an App Registration. The App Registration needs to have access to the API exposed by your MCP Server and it's scope. You need to know the Application (Client) ID and the scope of the App Registration you use for your MCP Server. In this guide the following values will be used for the existing MCP Server App Registration:

__Application (Client) ID__: MyAppRegistrationsGUID

__Scope__: MyAppRegistrationsScope

Open Azure Portal and go to Entra ID -> App Registrations and create a New registration.

![alt text]({{ site.url }}/images/CCWEIDA-image.png)

Just add a name and click Register

Note the Application (client) ID of the new application from the overview.

![alt text]({{ site.url }}/images/CCWEIDA-image-1.png)

Select API Permissions. Here you need to add the API exposed by your MCP Server

![alt text]({{ site.url }}/images/CCWEIDA-image-2.png)

You can search for the MCP Server Application under API's my organization uses

![alt text]({{ site.url }}/images/CCWEIDA-image-3.png)

Select the scope exposed by your MCP Servers Application and click Add permission

![alt text]({{ site.url }}/images/CCWEIDA-image-4.png)

Go to the Certificates and secrets pane and add a new secret

![alt text]({{ site.url }}/images/CCWEIDA-image-5.png)

Save the value for later.

## Create the Power Automate Custom Connector

Ensure that your Power Environment has the the Get new features early attribute set to true.

Go to Custom Connectors in Power Automate and click New custom Connector -> Import from Github

![alt text]({{ site.url }}/images/CCWEIDA-image-6.png)

Select custom, find the dev branch and pick the MCP-StreamableHTTP Connector

![alt text]({{ site.url }}/images/CCWEIDA-image-11.png)

In the General tab add the forwarded address from your VS Code forwarding as the Host an click Security. Update name and description as desired.

![alt text]({{ site.url }}/images/CCWEIDA-image-7.png)

Fill out the form with the data you have collected so far.

![alt text]({{ site.url }}/images/CCWEIDA-image-8.png)

__Authentication type__: OAuth 2.0

__Identity Provider__: Azure Active Directory

__Client ID__: The Application (Clinet) ID of the new App Registration you have created.

__Client secret__: The secret you created for the application

__Tenant ID__: Your Tenant ID

__Resource URL__: api://MyAppRegistrationsGUID

__Enable on-behalf-of login__: true

__Scope__: MyAppRegistrationsScope

In my setup it looks like this:

![alt text]({{ site.url }}/images/CCWEIDA-image-9.png)

Click on Create connector to generate the Redirect URL

Copy the Redirect URL

![alt text]({{ site.url }}/images/CCWEIDA-image-10.png)

## Update the App Registration

Go to your App Registration in the Azure Portal and select Aauthentication -> Add a platform

![alt text]({{ site.url }}/images/CCWEIDA-image-12.png)

Select Web and paste the Redirect URI into the Redirect URIs text box, check the 2 boxes and click Configure.

![alt text]({{ site.url }}/images/CCWEIDA-image-13.png)

## Continue in Power Automate

Go to the Test tab and click Update connector. Your Test tab should look like this now

![alt text]({{ site.url }}/images/CCWEIDA-image-14.png)

Click New connection and authenticate

![alt text]({{ site.url }}/images/CCWEIDA-image-15.png)

Accept the requested access

![alt text]({{ site.url }}/images/CCWEIDA-image-16.png)

![alt text]({{ site.url }}/images/CCWEIDA-image-17.png)

If the connection is created, you are ready to test your Custom connector. Make your MCP Server is running in your debugger, so it can be reached from Power Automate via the dev tunnel

![alt text]({{ site.url }}/images/CCWEIDA-image-18.png)

If everything has been configured as described so far, the test will fail, but the schema validation will succeed.

![alt text]({{ site.url }}/images/CCWEIDA-image-21.png)

# Add the tool to an agent

Go to Copilot Studio. Create a new agent or update an existing agent.

Go to the Tools tab on the agent and click Add a tool

![alt text]({{ site.url }}/images/CCWEIDA-image-19.png)

Select Model Context Protocol and search for your new Custom Connection. It might take some time for the tool to show up - depending on how fast you created the Custom connection. Click on the tool:

![alt text]({{ site.url }}/images/CCWEIDA-image-20.png)

Click on Add and configure

![alt text]({{ site.url }}/images/CCWEIDA-image-22.png)

With a little luck, you should now see your MCP Server and the available tools in the menu.

![alt text]({{ site.url }}/images/CCWEIDA-image-23.png)

To test the implementation you need to punch in a prompt that inspires the Agent to run one of the tools in your MCP Server. It might look something like this

![alt text]({{ site.url }}/images/CCWEIDA-image-24.png)

You need to click Allow to grant the agent the right to use your credentials to contact the Custom connector. This will allow your agent to execute the Customen connector and get a response from your MCP Server

![alt text]({{ site.url }}/images/CCWEIDA-image-25.png)

## Final thoughts

Be patient - the different steps in connecting the Custom Connector to the Connector and making it available in Copilot Studio need to be allowed sufficient time to propagate to the different systems involved.

It might be possible to get the test in the Custom Connection to work, but for this demo I just needed to know, that the schema is valid. As far as I can see, most of it is related to some of the API Management bits used by Power Automate. This step was particularly difficult to get past, since it seemed to indicate, that something was wrong.

Once the tool is setup in an agent in  Copilot Studio, the agent can be published to your enterprise and accessed safely by your end users.