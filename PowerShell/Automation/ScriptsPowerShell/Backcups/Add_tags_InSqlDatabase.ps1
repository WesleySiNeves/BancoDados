$resourceGroup ='RgPrd'
$serverName ='rgprd-sqlsrv-prd01'

$list_databases = Get-AzSqlDatabase -ResourceGroupName $resourceGroup -ServerName $serverName 




$tags_default  = @{"backup"="6meses"}
$tags_standard  = @{"backup"="1ano"}


foreach($database in $list_databases)
{

    if($database.DatabaseName -like "*implanta.net.br*")
    {

        if($Database.DatabaseName -match [String]::Join('|','apresentacao-siscaf.implanta.net.br|patrimonio-df.implanta.net.br'))
        {
    
            if($database.Tags.ContainsKey('backup') -eq 'False')
            {
                $resource = Get-AzResource -Name $database.DatabaseName -ResourceGroup $resourceGroup
    
                New-AzTag -ResourceId $resource.id -Tag $tags_default
    
            }
           
        }
        else {
    
            $tags_standard  = @{"backup"="1ano"}
            # $resource = Get-AzResource -Name $database.DatabaseName -ResourceGroup $resourceGroup
    
            # New-AzTag -ResourceId $resource.id -Tag $tags
        }
    }

    

    

}