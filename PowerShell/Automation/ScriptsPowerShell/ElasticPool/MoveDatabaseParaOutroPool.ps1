
$resourceGroupName= 'RgPrd'
$serverName= 'rgprd-sqlsrv-prd01'
$DatabaseName ='cro-se.implanta.net.br_2020-11-24T12-00Z'   #cro-pb.implanta.net.br_2020-11-20T12-00Z

$firstPoolName = "rgprd-elspool-prd01"
$targetPoolName= "rgprd-elspool-prd02"

# Move the database to the second pool
$firstDatabase = Set-AzSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $serverName -DatabaseName $DatabaseName -ElasticPoolName $targetPoolName


### Mover um banco de dados de produção pra o pool de atd

$resourceGroupName= 'RgAtd'
$serverName= 'rgatd-sqlsrv-atd01'
$DatabaseName ='cro-se.implanta.net.br_2020-11-24T12-00Z'   #cro-pb.implanta.net.br_2020-11-20T12-00Z

$targetPoolName= "rgatd-elspool-atd01"

# Move the database to the second pool
$firstDatabase = Set-AzSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $serverName -DatabaseName $DatabaseName -ElasticPoolName $targetPoolName

