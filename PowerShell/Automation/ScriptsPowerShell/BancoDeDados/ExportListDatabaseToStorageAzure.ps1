

$databases_a_arquivar =
'cro-sp.conversor',
'cra-sc.Conversor',
'cra-sp.conversor',
'cra-es.conversor',
'cra-df.conversor',
'cra-mt.conversor',
'cra-al.conversor',
'cra-to.conversor',
'cra-pe.conversor',
'cra-am.conversor',
'cra-ma.conversor',
'cra-pb.conversor',
'cra-se.conversor',
'cra-ro.conversor',
'cra-rn.conversor',
'cra-pi.conversor',
'cra-go.conversor',
'cra-ba.conversor',
'cra-ms.conversor',
'cra-ap.conversor',
'cra-pa.conversor',
'cra-es.conversor-2',
'cra-es.conversor-3',
'cress-pr.conversor',
'cress-pe.conversor',
'cress-df.conversor',
'cress-pa.conversor',
'cress-ms.conversor',
'cress-rj.conversor',
'cress-sc.conversor',
'cress-mg.conversor',
'cress-rs.Conversor',
'cress-ce.conversor',
'cress-rr-Conversor',
'cress-sp.Conversor',
'cra-sp.conversor-incremental';


$Resource = '?'
$ServerName = '?'


$StorageKeytype = 'StorageAccessKey'
$StorageKey = '?'
$BacpacUrl_Base = '?/bases-conversao'


$User = '?'
$pass = '?'
$securePassword = ConvertTo-SecureString -String $pass -AsPlainText -Force
$waitDelay = 10



foreach ($database in $databases_a_arquivar) {
    $BacpacUri = $BacpacUrl_Base + '/' + $database + '.bacpac'
   
    # Get-AzSqlDatabase -ResourceGroupName $Resource -ServerName $ServerName  -DatabaseName $database

    $exportRequest = New-AzSqlDatabaseExport -ResourceGroupName $Resource -ServerName $ServerName -DatabaseName $database -StorageKeyType $StorageKeytype -StorageKey $StorageKey -StorageUri $BacpacUri  -AdministratorLogin $User -AdministratorLoginPassword $securePassword

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
   
  
}

Write-Output "Exportação dos bancos finalizado"
