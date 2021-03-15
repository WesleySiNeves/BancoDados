


$resourceGroupName ='?'
$serverName ='?'
$databaseName ='?'
$elasticPoolName ='?'



New-AzSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $serverName -DatabaseName $databaseName -ElasticPoolName $elasticPoolName
