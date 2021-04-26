
#Variaveis de definição

$resourceGroup ='RgPrd'
$serverName ='rgprd-sqlsrv-prd01'


$databasesInServer = Get-AzSqlDatabase -ResourceGroupName $resourceGroup  -ServerName $serverName 

  foreach($dbName in $databasesInServer)
  {

    $resource = Get-AzResource -Name $dbName.DatabaseName -ResourceGroup $resourceGroup

    $tags = @{}

    Set-AzResource -ResourceId $resource.Id `
        -Tag $tags `
        -Force

    write-host -Foregroundcolor Green $dbName $tags.Values

  }