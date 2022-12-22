# azure-signalr-node-react

---

| Page Type | Languages                                                  | Services                                                                                   | Tools                      |
| --------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------ | -------------------------- |
| Sample    | JavaScript (Node.js, React.js) <br> Python <br> PowerShell | Azure SignalR <br> Azure Functions <br> Azure Container Apps <br> Azure Container Registry | Docker <br> GitHub Actions |

---

# Real-time serverless Web Application with Azure SignalR, React.js, and Node.js backend proxy server

This sample codebase demonstrates how to use Azure SignalR to add real-time functionality to a serverless containerized web application hosted in Azure Container Apps written in [React.js](https://reactjs.org/) with a Node.js backend [proxy server](https://en.wikipedia.org/wiki/Proxy_server). This sample uses serverless Azure Functions for processing requests made by the application.
<br>
The motivation behind this guide is the observed lack of readily available open-source codebase examples using these technologies together.
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
-   [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=v4%2Cwindows%2Ccsharp%2Cportal%2Cbash) and [Azurite](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azurite?tabs=visual-studio) - for testing Functions locally
-   (Optional) [A GitHub Account](https://github.com/join) - for deploying code via GitHub Actions

## Running this sample

### _*Setting Up the Cloud Infrastructure*_

#### App Registration

-   [Register a new application](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)
-   [Create a new client secret](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app#add-a-client-secret) - you will use this if you choose to automate the deployment of the application using GitHub Actions

#### Web Application

-   Add the desired resource names in `devops/config/variables.json`
-   Either:
    -   Update the branch trigger in the `.github/workflows/web-infra.yml ` file to trigger the GitHub Action, or
    -   Run the script `devops/scripts/web/aca.ps1` locally.
-   This will create the Container App and all of the related services including a Container Registry, Container Instance, Managed Identity, Log Analytics Workspace, and Container App Environment.

#### Integration Services

-   Add the desired resource names in `devops/config/variables.json`
-   Either:
    -   Update the branch trigger in the `.github/workflows/integration-infra.yml ` file to trigger the GitHub Action, or
    -   Run the scripts `devops/scripts/integration/function.ps1` and `devops/scripts/integration/signalr.ps1` locally.
-   This will create the Function App and SignalR instances, in addition to all of the related services including a Storage Account, App Insights, and an App Service Plan.

#### GitHub Actions Secrets (for automated deployments)

-   `AZURE_SP_CREDENTIALS`:
    -   For Application (client) ID and Directory (tenant) ID: `az ad sp show --id <service principal ID>`
        -   Application (client) ID = `id` property
        -   Directory (tenant) ID = `appOwnerOrganizationId` property
    -   For Subscription ID: `az account show --query id --output tsv`
    -   For secret: This is the client secret created alongside the App Registration above
    -   Plug these GUIDs into object below:
    ```
    {
       "clientId": "<GUID>",
       "clientSecret": "<GUID>",
       "subscriptionId": "<GUID>",
       "tenantId": "<GUID>"
    }
    ```
-   `SIGNALR_CONNECTION_STRING`: In the SignalR service that was created above, go to 'Connection strings' blade.
-   `REGISTRY_USERNAME` and `REGISTRY_PASSWORD`: Run the command `az acr credential show --name <container registry name>`, and use the `username` and one of the password `values` returned.

### _*Deploying the Codebase*_

-   _Note: This section will discuss deployment of the codebase via GitHub Actions. If you choose not to deploy via GitHub Actions, you may opt to manually deploy the code by following the automated tasks by hand or with another CI/CD tool - the steps will be the same._

1.  Deploy the Negotiate and Broadcast functions first by updating the branch trigger in the `.github/workflows/integration-cicd.yml` file to trigger the GitHub Action.

    -   This will deploy two functions to the above deployed Function App. The functions in this codebase are written in Python, and are described in more detail in the below section.

2.  Then, deploy the web application by updating the branch trigger in the `.github/workflows/web-cicd.yml ` file to trigger the GitHub Action.

    -   This will build a Docker image, push it to the Container Registry, and update the Container App.

## How it works

![SignalR](/docs/diagram.png)
_A diagram visually describing the flow of code from local development to GitHub to Azure, and the way the components communicate in Azure._

1. To connect to SignalR, a valid access token is required. An HTTP-triggered "Negotiate" function is called by the client application to generate the required connection token. The negotiate function is described more [here](https://learn.microsoft.com/en-us/azure/azure-signalr/signalr-concept-serverless-development-config). When the web application is launched, the negotiate function is called immediately.
2. To send a message, a "Broadcast" function is required, which uses the connection information fetched in Step 1, and binds a trigger to SignalR (in this application an HTTP trigger is used, but the function can be set up to be triggered by any number of bindings - see all supported bindings [here](https://learn.microsoft.com/en-us/azure/azure-functions/functions-triggers-bindings?tabs=csharp)).
    - This is where logic/backend processing will take place. The broadcast function in this codebase takes a string as input, generates a [salt](https://en.wikipedia.org/wiki/Salt_(cryptography)) and uses it to create a cryptographic hash of the input string (this is a safeguarding technique used in authentication data stores).
3. Clients (e.g., the application in this repository) can connect and listen to SignalR for new messages. In real time, when SignalR receives a new message, the client will consume it over a [WebSocket](https://learn.microsoft.com/en-us/aspnet/signalr/overview/getting-started/introduction-to-signalr#signalr-and-websocket).

## Additional Resources

-   [SignalR and Serverless? It comes true - _blog_](https://www.nellysattari.com/serverless-signalr/)
-   [How to get started with SignalR on Azure with JavaScript - _blog_](https://www.freecodecamp.org/news/getting-started-with-signalr-in-azure-using-javascript/)
