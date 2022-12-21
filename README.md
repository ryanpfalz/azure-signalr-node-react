# azure-signalr-node-react

---

| Page Type | Languages                                                  | Services                                                                                   | Tools                      |
| --------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------ | -------------------------- |
| Sample    | JavaScript (Node.js, React.js) <br> Python <br> PowerShell | Azure SignalR <br> Azure Functions <br> Azure Container Apps <br> Azure Container Registry | Docker <br> GitHub Actions |

---

# Simple real-time Web Application with Azure SignalR, React.js, and Node.js backend proxy server

This sample codebase demonstrates how to use Azure SignalR to add real-time functionality to a containerized web application hosted in Azure Container Apps written in [React.js](https://reactjs.org/) with a Node.js backend [proxy server](https://en.wikipedia.org/wiki/Proxy_server). This sample uses serverless Azure Functions for processing requests made by the application.
<br>
The motivation behind this guide is the observed lack of readily available open-source codebase examples using these technologies.
<br>
This sample builds on top of existing approaches documented by Microsoft, namely:

-   [Serverless development and configuration with Azure SignalR](https://learn.microsoft.com/en-us/azure/azure-signalr/signalr-concept-serverless-development-config)
-   [SignalR quickstart for JavaScript](https://learn.microsoft.com/en-us/azure/azure-signalr/signalr-quickstart-azure-functions-javascript)
-   [ASP.NET Core SignalR JavaScript client](https://learn.microsoft.com/en-us/aspnet/core/signalr/javascript-client?view=aspnetcore-7.0&tabs=visual-studio)

SignalR is a solution that introduces real-time functionality to a webpage, addressing scenarios such as a user needing to refresh a webpage to fetch new data, or an application performing long-polling for data to become available.
<br>
Although the scenario presented in this codebase is simple and contrived, it should be viewed as a foundation for modification and expansion into more complex applications.

## Prerequisites

-   [An Azure Subscription](https://azure.microsoft.com/en-us/free/) - for hosting cloud infrastructure
-   [Az CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) - for deploying Azure infrastructure as code
-   [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=v4%2Cwindows%2Ccsharp%2Cportal%2Cbash) - for testing Functions locally
-   (Optional) [A GitHub Account](https://github.com/join) - for deploying code via GitHub Actions

## Running this sample

### _*Setting Up the Cloud Infrastructure*_

#### Service Principal

-   Set up SP and secret

#### Web Application

-   Run aca.ps1

#### Integration Services

-   Run function.ps1 and signalr.ps1

#### GitHub Actions Secrets (for automated deployments)

-   Set up:
-   AZURE_SP_CREDENTIALS:
    -   For Application (client) ID and Directory (tenant) ID: `az ad sp show --id $spId`
        -   Application (client) ID = `id` property
        -   Directory (tenant) ID = `appOwnerOrganizationId` property
    -   For Subscription ID: `az account show --query id --output tsv`
    -   For secret: Get from Service Principal setup step above
    -   Plug into object below:
    ```
    {
       "clientId": "<GUID>",
       "clientSecret": "<GUID>",
       "subscriptionId": "<GUID>",
       "tenantId": "<GUID>"
    }
    ```
-   SIGNALR_CONNECTION_STRING: In SignalR service, go to 'Connection strings' blade
-   For REGISTRY_USERNAME and REGISTRY_PASSWORD: `az acr credential show --name`

### _*Deploying the Codebase*_

-   TODO - deploy via IaC

## Additional Resources

-   [SignalR and Serverless? It comes true - _blog_](https://www.nellysattari.com/serverless-signalr/)
-   [How to get started with SignalR on Azure with JavaScript - _blog_](https://www.freecodecamp.org/news/getting-started-with-signalr-in-azure-using-javascript/)
