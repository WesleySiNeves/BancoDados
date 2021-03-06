

$Resource ='?'
$ServerName ='rgprd-sqlsrv-prd01'
$DatabaseName ='?'

$StorageKeytype ='StorageAccessKey'

$StorageKey ='?'
$BacpacUri ='?/export/'+$DatabaseName +'_Export.bacpac'


$User = '?'
$pass = '?'
$securePassword = ConvertTo-SecureString -String $pass -AsPlainText -Force

$exportRequest = New-AzSqlDatabaseExport -ResourceGroupName $Resource -ServerName $ServerName -DatabaseName $DatabaseName -StorageKeyType $StorageKeytype -StorageKey $StorageKey -StorageUri $BacpacUri  -AdministratorLogin $User -AdministratorLoginPassword $securePassword

$waitDelay =5
$exportStatus = Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink    

    while ($exportStatus.Status -eq "InProgress")
    {
        $exportStatus = Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink
        Start-Sleep -s $waitDelay 
    }

    $Status= $exportStatus.Status

    if($Status -eq "Succeeded")
    {
        Write-Output "Azure SQL DB Export $Status for "$database""
    }
    else
    {
        Write-Output "Azure SQL DB Export Failed for "$database""
    } 

    Write-Output "Finalizado"