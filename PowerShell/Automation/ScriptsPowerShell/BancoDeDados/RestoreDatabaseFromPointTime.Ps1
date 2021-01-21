



#Clear-AzContext
$tenantId ='5d512ad1-5a13-466d-ac3e-8b4368dbc1b6' #Assinatura do Visual Studio Enterprise – MPN-2
$resourceGroup ='rg-bootcamp-igti'
$serverName ='serverdatabasenexxus'
$ElasticPoolName ='prod-elastic'
$databaseName ='AdventureWorks'
$dataRestore = (Get-Date).AddDays(-2)

$subscriptionId ='09933a9f-419b-4dfa-bf3f-049d79e3883f' #Assinatura do Visual Studio Enterprise – MPN-2


$Database = Get-AzSqlDatabase -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $databaseName

Restore-AzSqlDatabase -FromPointInTimeBackup -PointInTime $dataRestore -ResourceGroupName $Database.ResourceGroupName -ServerName $Database.ServerName  -TargetDatabaseName "AdventureWorksRestore"  -ResourceId $Database.ResourceID  -Edition "Standard"  -ServiceObjectiveName "S2"
