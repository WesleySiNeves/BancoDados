  
  



$ExternalClientName ='cro-ac' 

$StorageAccountName ='?'

$StorageAccountKey ='?'

$subscriptionId = '?'

$sqlServerName = '?'

$resourceGroupName = 'RgPrd'


$storageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

$storagecontainer = Get-AzStorageContainer -Name "databasebackup" -Context $storageContext -ErrorAction SilentlyContinue

Get-AzStorageBlob -Container $storagecontainer.Name -Prefix 'cro-ac'

Get-AzStorageBlob -Context  $storageContext.Context -Container "databasebackup" -Prefix $ExternalClientName | Remove-AzStorageBlob

