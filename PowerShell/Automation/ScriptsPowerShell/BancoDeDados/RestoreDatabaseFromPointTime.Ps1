



#Clear-AzContext
$tenantId ='?' #Assinatura do Visual Studio Enterprise – MPN-2
$resourceGroup ='?'
$serverName ='?'
$ElasticPoolName ='prod-elastic'
$databaseName ='AdventureWorks'
$dataRestore = (Get-Date).AddDays(-2)

$subscriptionId ='?' #Assinatura do Visual Studio Enterprise – MPN-2


$Database = Get-AzSqlDatabase -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $databaseName

Restore-AzSqlDatabase -FromPointInTimeBackup -PointInTime $dataRestore -ResourceGroupName $Database.ResourceGroupName -ServerName $Database.ServerName  -TargetDatabaseName "AdventureWorksRestore"  -ResourceId $Database.ResourceID  -Edition "Standard"  -ServiceObjectiveName "S2"
