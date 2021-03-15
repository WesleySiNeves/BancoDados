

$ResourceGroup ='rg-bootcamp-igti'
$Servername = '?'
$databaseName =''
$location ='East US'
$UserAdmim = '?'
$Password ='?'

$targetResuceGroup =''
$targetServerName =''
$targetdatabaseName =''





New-AzSqlDatabaseCopy -ResourceGroupName $ResourceGroup -ServerName$Servername -DatabaseName $databaseName
    -CopyResourceGroupName $targetResuceGroup -CopyServerName $targetServerName -CopyDatabaseName "CopyOfMySampleDatabase"