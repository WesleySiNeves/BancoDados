
$resourceGroupName= 'RgPrd'
$serverName= '?'
$DatabaseName ='daf-02.implantadev.net.br'   #cro-pb.implanta.net.br_2020-11-20T12-00Z


$targetPoolName= "?"
$target_resourGroup='rghml'

 $database = Get-AzSqlDatabase -ResourceGroupName $resourceGroupName  -ServerName $ServerName -DatabaseName $DatabaseName

$db_resource = Get-AzResource -ResourceId $database.ResourceId

Move-AzResource -ResourceId $db_resource.ResourceId -DestinationResourceGroupName $target_resourGroup


