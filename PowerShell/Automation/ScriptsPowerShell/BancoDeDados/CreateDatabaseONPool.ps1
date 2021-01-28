


$resourceGroupName ='RgDev'
$serverName ='rgdev-sqlsrv-dev01'
$databaseName ='14-implanta'
$elasticPoolName ='rgdev-elspool-dev01'



New-AzSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $serverName -DatabaseName $databaseName -ElasticPoolName $elasticPoolName
