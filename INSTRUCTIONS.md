## Pre-requisites
Install AZ CLI; https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

## Steps

1. #### Create backend storage
- create storage account and container using script below;
  ```
  cd infrastructure/scripts
  bash tf_storage.sh "<subscription_id>"
  ```

2. #### Add Subscription Information
- Add subscription_id and tenant_id to .github/workflows/deploy_app.yml - Line 14,15
- Add subscription_id and tenant_id to deployment/secretproviderclass.yaml - Line 20, 21

3. #### Provision Service Principal 
- Create a Service Principal and provide it Owner permissions to the subscription using script below;
  ```
  cd infrastructure/scripts
  bash service_principal.sh "<subscription_id>" "<service_principal_name>"
  ```

>***Note**: Store service principal output, you would need it later. It needs Owner permissions to be able to create and manage Azure resources and to be able to assign permissions to the cluster managed identities.*

4. #### Create github repository secrets.
- Store below as github repository secrets (Go to repo -> Settings -> Secrets -> New repository secret)
    - **SVC_KUBE_CLIENTID**: app id of service principal
    - **SVC_KUBE_CLIENTSECRET**: password/key of service principal

5. #### Run github action workflow .github/workflows/deploy_app.yml via Github portal
- Go to repository home page -> click Actions -> click deploy_app -> Run Workflow


    
