
$ResourceGroup ='rg-dev-bancodados'
$Servername = '?'
$databaseName ='AdventureWorks'
$location ='East US'
$UserAdmim = '?'
$Password ='?'

$targetResuceGroup ='rg-dev-bancodados'
$targetServerName ='rgdev-sqlserver-01'
$targetdatabaseName ='AdventureWorks'

New-AzSqlDatabaseCopy -ResourceGroupName $ResourceGroup -ServerName $Servername -DatabaseName $databaseName `
    -CopyResourceGroupName $targetResuceGroup -CopyServerName $targetServerName -CopyDatabaseName $targetdatabaseName