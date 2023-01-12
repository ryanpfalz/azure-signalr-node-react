# azure-signalr-node-react

---

| Page Type | Languages                                                  | Key Services                                                                               | Tools                      |
| --------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------ | -------------------------- |
| Sample    | JavaScript (Node.js, React.js) <br> Python <br> PowerShell | Azure SignalR <br> Azure Functions <br> Azure Container Apps <br> Azure Container Registry | Docker <br> GitHub Actions |

---

# Real-time serverless Web Application with Azure SignalR, React.js, and Node.js backend proxy server

This sample codebase demonstrates how to use [Azure SignalR](https://learn.microsoft.com/en-us/azure/azure-signalr/signalr-overview) to add real-time functionality to a serverless containerized web application hosted in [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/overview) written in [React.js](https://reactjs.org/) with a Node.js backend [proxy server](https://en.wikipedia.org/wiki/Proxy_server). This sample uses serverless [Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-overview) for processing requests made by the application.
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
-   [Python](https://www.python.org/downloads/) - for Python development
-   [Node.js](https://nodejs.org/en/download/) - for Node.js development
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
-   This will create the Container App and all of the related components including a [Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-intro), [Container Instance](https://learn.microsoft.com/en-us/azure/container-instances/container-instances-overview), [Managed Identity](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview), [Log Analytics Workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview), and [Container App Environment](https://learn.microsoft.com/en-us/azure/container-apps/environment).

#### Integration Services

-   Add the desired resource names in `devops/config/variables.json`
-   Either:
    -   Update the branch trigger in the `.github/workflows/integration-infra.yml ` file to trigger the GitHub Action, or
    -   Run the scripts `devops/scripts/integration/function.ps1` and `devops/scripts/integration/signalr.ps1` locally.
-   This will create the Function App and SignalR instances, in addition to all of the related components including a [Storage Account](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview), [App Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview?tabs=net), and an [App Service Plan](https://learn.microsoft.com/en-us/azure/app-service/overview-hosting-plans).

#### GitHub Actions Secrets (for automated deployments)

-   To deploy to Azure using GitHub Actions, a handful of credentials are required for connection and configuration. In this example, they will be set as [Actions Secrets](https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28). For each of the below secrets, the secret name and steps on how to populate the secret is provided.

1.  `AZURE_SP_CREDENTIALS`:

    -   A JSON object that looks like the following will need to be populated with 4 values:

    ```
    {
       "clientId": "<GUID>",
       "clientSecret": "<STRING>",
       "subscriptionId": "<GUID>",
       "tenantId": "<GUID>"
    }
    ```

    -   You can find more details on creating this secret [here](https://github.com/marketplace/actions/azure-login#configure-a-service-principal-with-a-secret).
    -   For clientId, run: `az ad sp list --display-name <service principal name> --query '[].[appId][]' --out tsv`
    -   For tenantId, run: `az ad sp show --id <clientID> --query 'appOwnerOrganizationId' --out tsv`
    -   For subscriptionId, run: `az account show --query id --output tsv`
    -   For clientSecret: This is the client secret created alongside the App Registration above

2.  `SIGNALR_CONNECTION_STRING`: In the Azure Portal, navigate to the SignalR service that was created above, and go to 'Connection strings' blade.

### _*Deploying the Codebase*_

-   _Note: This section will discuss deployment of the codebase via GitHub Actions. If you choose not to deploy via GitHub Actions, you may opt to manually deploy the code by following the automated tasks or with another CI/CD tool - the steps will be the same._

1.  Deploy the Negotiate and Broadcast functions first by updating the branch trigger in the `.github/workflows/integration-cicd.yml` file to trigger the GitHub Action.

    -   This will deploy two functions to the above deployed Function App. The functions in this codebase are written in Python, and are described in more detail in the below section.

2.  Then, deploy the web application by updating the branch trigger in the `.github/workflows/web-cicd.yml ` file to trigger the GitHub Action.

    -   This will build a Docker image, push it to the Container Registry, and update the Container App.

## Architecture & Workflow

![SignalR](/docs/diagram.png)
_A diagram visually describing the flow of code from local development to GitHub to Azure, and the way the components communicate in Azure._

1. To connect to SignalR, a valid access token is required. An HTTP-triggered "Negotiate" function is called by the client application to generate the required connection token. The negotiate function is described more [here](https://learn.microsoft.com/en-us/azure/azure-signalr/signalr-concept-serverless-development-config). When the web application is launched, the negotiate function is called immediately.
2. To send a message, a "Broadcast" function is required, which uses the connection information fetched in Step 1, and binds a trigger to SignalR. The `@microsoft/signalr`
   [npm package](https://www.npmjs.com/package/@microsoft/signalr) is used to establish the connection.
    - This is where logic/backend processing will take place. The broadcast function in this codebase takes a string as input, generates a [salt](<https://en.wikipedia.org/wiki/Salt_(cryptography)>) and uses it to create a cryptographic hash of the input string (this is a safeguarding technique used in authentication data stores).
    - \* In this example the Broadcast Function uses an HTTP trigger, but the function can be set up to be triggered by any number of bindings - see all supported bindings [here](https://learn.microsoft.com/en-us/azure/azure-functions/functions-triggers-bindings?tabs=csharp). In a real-world application, using another type of binding to trigger an event may be more practical.
3. Clients (e.g., the application in this repository) can connect and listen to SignalR for new messages. In real time, when SignalR receives a new message, the client will consume it over a [WebSocket](https://learn.microsoft.com/en-us/aspnet/signalr/overview/getting-started/introduction-to-signalr#signalr-and-websocket).

## Potential Use Cases

-   There are many practical use cases for enabling real-time functionality to a webpage, some of which include instant messaging, real-time dashboards, gaming, and sports.

## Additional Resources

-   [SignalR and Serverless? It comes true - _blog_](https://www.nellysattari.com/serverless-signalr/)
-   [How to get started with SignalR on Azure with JavaScript - _blog_](https://www.freecodecamp.org/news/getting-started-with-signalr-in-azure-using-javascript/)
