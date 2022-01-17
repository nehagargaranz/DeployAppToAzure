#!/bin/bash

SUBSCRIPTION_ID=$1
SERVICE_PRINCIPAL_NAME=$2

echo "Logging in to Azure.."
az login
az account set -s $SUBSCRIPTION_ID
az account show

echo "Creating Service Principal..."
az ad sp create-for-rbac --name "$SERVICE_PRINCIPAL_NAME" --skip-assignment
if [ $? -eq 0 ]; then
    echo "The service principal '$SERVICE_PRINCIPAL_NAME' has been created."
    echo "You will want to make a note of the above credentials to store in LastPass."
    echo "NB: do NOT include them in your code or check into source control"  
fi
servicePrincipalObjId=$(az ad sp list --display-name "$SERVICE_PRINCIPAL_NAME" -o tsv --query '[].objectId')

echo "Assigning roles to Service Principal..."
az role assignment create --assignee-object-id "$servicePrincipalObjId" \
--role "Owner" --scope "/subscriptions/$SUBSCRIPTION_ID"