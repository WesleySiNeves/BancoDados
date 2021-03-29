

$Resource ='RgPrd'
$ServerName ='rgprd-sqlsrv-prd01'
$DatabaseName ='cau-sp.implanta.net.br'

$database = Get-AzSqlDatabase -ResourceGroupName $Resource  -ServerName $ServerName  -DatabaseName $DatabaseName



$StorageKeytype ='StorageAccessKey'
$StorageKey ='6XDERJnF6V34xAKomrppUbbOXhQRwkkb6Yz9KBrQvjvzVf+Ob+Pgi+kV9s0zE9FY8E4Wvwg7QEfDiT3JQmD1aw=='
$BacpacUri ='https://imdevblob02.blob.core.windows.net/export/'+$DatabaseName +'_Export.bacpac'


$User = 'wesley.neves@implantainformatica.com.br'
$pass = 'karina_96086512'
$securePassword = ConvertTo-SecureString -String $pass -AsPlainText -Force

$exportRequest = New-AzSqlDatabaseExport -ResourceGroupName $Resource -ServerName $ServerName-DatabaseName $DatabaseName -StorageKeyType $StorageKeytype -StorageKey $StorageKey -StorageUri $BacpacUri  -AdministratorLogin $User -AdministratorLoginPassword $securePassword


$exportStatus = Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink    

    while ($exportStatus.Status -eq "InProgress")
    {
        $exportStatus = Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink
        Start-Sleep -s $waitDelay 
    }

    $Status= $exportStatus.Status

    if($Status -eq "Succeeded")
    {
        Write-Output "Azure SQL DB Export $Status for $database"
    }
    else
    {
        Write-Output "Azure SQL DB Export Failed for $database"
    } 

    Write-Output "Finalizado"