
$resourceGroupName= 'RgPrd'
$serverName= '?'
$DatabaseName ='?'   #cro-pb.implanta.net.br_2020-11-20T12-00Z

$firstPoolName = "?"
$targetPoolName= "?"

# Move the database to the second pool
$firstDatabase = Set-AzSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $serverName -DatabaseName $DatabaseName -ElasticPoolName $targetPoolName


### Mover um banco de dados de produção pra o pool de atd

$resourceGroupName= '?'
$serverName= '?'
$DatabaseName ='?'   #cro-pb.implanta.net.br_2020-11-20T12-00Z

$targetPoolName= "?"

# Move the database to the second pool
$firstDatabase = Set-AzSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $serverName -DatabaseName $DatabaseName -ElasticPoolName $targetPoolName

