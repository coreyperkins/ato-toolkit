# Confluence

**Estimated Time:**

* Smart Hands Preparation Time: 15 mins
* Deployment Time: 30 mins

## Prerequisites

* These instructions assume running in windows
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) - included in install bits
* Latest version of [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7) - included in install bits
* [Porter](https://porter.sh) - included in install bits
* Access to a functional Openshift 3.11 cluster

## Deployment (testing) Instructions

Running the deployment will connect to Azure using the cli, deploy the needed resources, prepare the virtual machines for deployment, and deploy an OCP 3.11.

1. Open `./deploy/deployment.vars.ps1` in a text editor. We're going to change a few variable values before starting the deployment.
2. In the `AZ CLI Configuration` section, update the following values:

    ```powershell
        [string] $DepArgs.SubscriptionId = ""

        [string] $DepArgs.TenantId = ""
    ```

3. Update the AppUrl to use the same DNS that was setup in the OCP deployment. The ip address that this should resolve to is the RouterPrivateClusterIp from the OCP deployment. Below is the default value.

    ```powershell
        [string] $DepArgs.AppUrl = ""
    ```

4. You will need to find the ip for the ContainerRegistry from the OCP deployment. Then vm names ends in SYDR-001v.

    ```powershell
    [string] $DepArgs.ContainerRegistry = "10.3.103.4:5000"
    ```

    > [!TIP] You can run the following command to get the ip address of the container registry for OCP. If you changed the naming of the OCP cluster, you will need to account for that.
    >
    > `az vm show -g AZS-DEP-OCP-RG94 -n BETA-EAST-SYDR-001v -d --query privateIps -o tsv`

5. The SshKey is the default setup from the OCP deployment. If a new key was generated, then the value much be updated here and the key must be placed in the /certs/ folder.

    ```powershell
    [string] $DepArgs.SshKey = "cfs-gPfAo"
    ```

6. To begin the deployment:
    1. Open `pwsh.lnk`
    1. Navigate to the `deploy` folder beside these instructions
    1. Run the following command to execute install file and start the deployment

    ```powershell
    ./install.ps1 -VariableFile deployment.vars.ps1
    ```

## Post Deployment Steps (success criteria)

When the deployment is finished, the Confluence setup page will be found at **https://[AppUrl]/setup/startup.action**. From there you will be able to input the license key to complete the setup of Confluence. The Postgres database that is also deployed should then be connected to Confluence, allowing for the initial space to be created for document collaboration.

## Troubleshooting Guide (error mitigation plan)

All installation logs are output to the `./deploy/output/` folder. Look there first for any issues.

1. If you see an error regarding a namespace conflict you may have to adjust the value of $DepArgs.AppName in deployment.vars.ps1. The value of $DepArgs.AppName must be unique from any other namespace in the OCP cluster.

1. Part of the installation is to stand up and connect to the Postgresql database. The installer will check for a connection to the database if possible. If this does not occur, verify your machine can connect to the cluster and reattempt the installation.

1. If at any point the installation fails, navigate to the folder called `confluence` on the Openshift Bastion server and execute `porter uninstall -c ./credentials.json confluence -p ./params.json` to uninstall the resources generated by the installer. Errors or warnings may be displayed if particular resources were not created during the failed installation, but the uninstall action will allow the operator to restart the installation from a clean state.
