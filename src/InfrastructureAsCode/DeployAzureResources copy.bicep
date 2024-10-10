@description('Location of the resources')
param location string = resourceGroup().location

@description('Password for the SQL Server admin user. PLEASE CHANGE THIS BEFORE DEPLOYMENT!')
param sqlAdminPassword string = 'TechExcelP1!@'

@description('Model deployments for OpenAI')
param deployments array = [
  {
    name: 'gpt-4o'
    capacity: 40
    version: '2024-05-13'
  }
  {
    name: 'text-embedding-ada-002'
    capacity: 120
    version: '2'
  }
]

@description('Restore the service instead of creating a new instance. This is useful if you previously soft-deleted the service and want to restore it. If you are restoring a service, set this to true. Otherwise, leave this as false.')
param restore bool = false

@description('The email address of the owner of the service')
@minLength(1)
param apimPublisherEmail string = 'support@contososuites.com'

var apiManagementServiceName = 'apim-${uniqueString(resourceGroup().id)}'
var apimSku = 'Basicv2'
var apimSkuCount = 1
var apimPublisherName = 'Contoso Suites'

var cosmosDbName = '${uniqueString(resourceGroup().id)}-cosmosdb'
var cosmosDbDatabaseName = 'ContosoSuites'
var storageAccountName = '${uniqueString(resourceGroup().id)}sa'
var searchServiceName = '${uniqueString(resourceGroup().id)}-search'
var openAIName = '${uniqueString(resourceGroup().id)}-openai'
var speechServiceName = '${uniqueString(resourceGroup().id)}-speech'
var languageServiceName = '${uniqueString(resourceGroup().id)}-lang'
var webAppNameApi = '${uniqueString(resourceGroup().id)}-api'
var webAppNameDash = '${uniqueString(resourceGroup().id)}-dash'
var appServicePlanName = '${uniqueString(resourceGroup().id)}-cosu-asp'
var functionAppName = '${uniqueString(resourceGroup().id)}-cosu-fn'
var functionAppServicePlanName = '${uniqueString(resourceGroup().id)}-cosu-fn-asp'
var logAnalyticsName = '${uniqueString(resourceGroup().id)}-cosu-la'
var appInsightsName = '${uniqueString(resourceGroup().id)}-cosu-ai'
var webAppSku = 'S1'
var registryName = '${uniqueString(resourceGroup().id)}cosureg'
var registrySku = 'Standard'
var sqlServerName = '${uniqueString(resourceGroup().id)}-sqlserver'
var sqlDatabaseName = 'ContosoSuitesBookings'
var sqlAdminUsername = 'contosoadmin'

var locations = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]


@description('Creates an Azure Cosmos DB NoSQL account.')
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosDbName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    databaseAccountOfferType: 'Standard'
    locations: locations
    disableLocalAuth: false
  }
}

@description('Creates an Azure Cosmos DB NoSQL API database.')
resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: cosmosDbAccount
  name: cosmosDbDatabaseName
  properties: {
    resource: {
      id: cosmosDbDatabaseName
    }
  }
}

@description('Creates an Azure SQL Server.')
resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
  }
}


@description('Creates an Azure SQL Database.')
resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
  sku: {
    name: 'S2'
    tier: 'Standard'
    capacity: 50
  }
}


resource apiManagementService 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: apiManagementServiceName
  location: location
  sku: {
    name: apimSku
    capacity: apimSkuCount
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
    restore: restore
  }
}

output apiManagementServiceName string = apiManagementService.name
