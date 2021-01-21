

$ResourceGroup ='rg-bootcamp-igti'
$Servername = 'serverdatabasenexxus-dev'
$databaseName =''
$location ='East US'
$UserAdmim = 'Wesley'
$Password ='W&$L&1N&V&$_96086512'

$targetResuceGroup =''
$targetServerName =''
$targetdatabaseName =''





New-AzSqlDatabaseCopy -ResourceGroupName $ResourceGroup -ServerName$Servername -DatabaseName $databaseName
    -CopyResourceGroupName $targetResuceGroup -CopyServerName $targetServerName -CopyDatabaseName "CopyOfMySampleDatabase"