# DeployAppToCloud
This repository holds terraform resources to create infrastructure to host a Golang application. 

## configs 
- **backend.tfvars.json**: To hold backend configuration to be used to create and access terraform state.
- **infrastructure.tfvars.json**: To hold configurations in json format to be used by Terraform resources. 

## infrastructure
- Terraform configuration to deploy Azure Kubernetes Services (AKS) cluster infrastructure.
- Terraform module to deploy PostgreSQL server infrastructure.
- This cluster would host a Golang application 

## deployment
- This folder has Kubernetes manifests.
- Go through [INSTRUCTIONS](https://github.com/nehagargSeequent/DeployAppToCloud/blob/main/INSTRUCTIONS.md) to deploy your app to this infrastructure.

## .github/workflows/deploy_app.yml
- Github workflow need to create AKS cluster, PostgreSQL server and to deploy app to the cluster.

![image](https://user-images.githubusercontent.com/81267312/144766667-44c7ae04-1ac1-4c6e-8382-d14f788d248d.png)


## High-level Architecture Overview
- We have Azure Kubernetes Services (AKS cluster) deployed in a virtual network subnet. This cluster has got nodes enabled in multiple availability zones and scaling enabled. 
- The cluster has got monitoring enabled to be able to monitor metrices available via Container Insights.
- The cluster has got its own managed identities which would be used to contribute to network and VM scale set.
- There are two helm-charts installed on the cluster,
    - csi-secrets-store-provider-azure: Mount key vault secrets to the pods as volumes.
    - aad-pod-identity: Use User managed identity as an aad pod identity which would request token from AAD, use that token to fetch secrets from key vault and then get those secrets to the application to be able to connect to database server.
- The database server configuration are passed to the pods as environment variables. Username and password are fetched from the key vault. PGSQL server host name, port and database name are set using Kubernetes config maps.

- We have PostgreSQL server configured which can be accessed by AKS subnet. To make it highly available, there is a replica server which would act as a failover server.
- The username and password of the main server would be stored as secrets in a Key Vault.

- We have a kubernetes load balancer attached in front of the cluster nodes that has public IP configured which could be browsed to access the Servian Challenge application. 

![image](https://user-images.githubusercontent.com/81267312/144765760-feaea733-78ab-4665-8ebf-83bc8d085a95.png)


>**Note**: I was unable to create seed database in my Azure PostgreSQL server using _updatedb.go_. I have created an issue here, https://github.com/servian/TechChallengeApp/issues/89
