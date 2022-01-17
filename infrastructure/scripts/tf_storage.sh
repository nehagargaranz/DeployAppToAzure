#!/bin/bash

SUBSCRIPTION_ID=$1
STORE_RG_NAME=golang-infra-store
STORAGE_ACCOUNT_NAME=golangstorage
CONTAINER_NAME=terraform-state
LOCATION=australiaeast

echo "Logging in to Azure-.."
az login
az account set -s $SUBSCRIPTION_ID
az account show

echo "Creating the resource group..."
az group create --location $LOCATION --name $STORE_RG_NAME

echo "Creating the storage account..."
az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $STORE_RG_NAME \
--location $LOCATION \
--location $LOCATION \
--kind StorageV2 \
--sku Standard_GRS

ACCOUNT_KEY=$(az storage account keys list --resource-group $STORE_RG_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)
echo "Creating the container..."
az storage container create --name $CONTAINER_NAME \
--account-name $STORAGE_ACCOUNT_NAME \
--account-key $ACCOUNT_KEY