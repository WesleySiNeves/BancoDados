





#Clear-AzContext
$tenantId ='?' #Implanta Informatica
$resourceGroup ='?'
$serverName ='?'
$elasticPoolName ='?'
$databaseName ='?'
$dataRestore = (Get-Date).AddDays(-3)

$subscriptionId ='?'  #Implanta Informatica

$Database = Get-AzSqlDatabase -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $databaseName

Restore-AzSqlDatabase -FromPointInTimeBackup -PointInTime (Get-Date).AddDays(-3) -ResourceGroupName $Database.ResourceGroupName -ServerName $Database.ServerName -TargetDatabaseName "?" -ResourceId $Database.ResourceID -ElasticPoolName $elasticPoolName
