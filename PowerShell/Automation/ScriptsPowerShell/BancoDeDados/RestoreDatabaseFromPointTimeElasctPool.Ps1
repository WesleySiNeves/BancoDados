





#Clear-AzContext
$tenantId ='5627b2ec-37e2-42df-bac4-43add425101c' #Implanta Informatica
$resourceGroup ='RgPrd'
$serverName ='rgprd-sqlsrv-prd01'
$elasticPoolName ='rgprd-elspool-prd01'
$databaseName ='cro-pr.implanta.net.br'
$dataRestore = (Get-Date).AddDays(-3)

$subscriptionId ='b98b628c-0499-4165-bdb4-34c81b728ca4'  #Implanta Informatica

$Database = Get-AzSqlDatabase -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $databaseName

Restore-AzSqlDatabase -FromPointInTimeBackup -PointInTime (Get-Date).AddDays(-3) -ResourceGroupName $Database.ResourceGroupName -ServerName $Database.ServerName -TargetDatabaseName "cro-pr.implanta.net.br-teste" -ResourceId $Database.ResourceID -ElasticPoolName $elasticPoolName
