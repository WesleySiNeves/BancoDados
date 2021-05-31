
#Variaveis de definição

$resourceGroupName ='?'
$sqlServerName ='?'
$nameTagSqlPolicy ='sql-backup-policy'

$tags_setedias  = @{"sql-backup-policy"="7dias"}
$tags_6meses  = @{"sql-backup-policy"="6meses"}
$tags_umano  = @{"sql-backup-policy"="1ano"}

$databasesInServer = Get-AzSqlDatabase -ResourceGroupName $resourceGroupName  -ServerName $sqlServerName 

  foreach($database in $databasesInServer)
  {
        $tags = $database.Tags
        
        if(-not $tags)
        {
            $tags = @{}
        }
        
        if($tags.ContainsKey($nameTagSqlPolicy) -eq $false)
        {
            $resource = Get-AzResource -Name $database.DatabaseName -ResourceGroup $resourceGroupName

            if($database.DatabaseName -like "*implanta.net.br*")
            {
                if($database.DatabaseName -notlike "*old*" -and $database.DatabaseName -notlike "*copy*" -and $database.DatabaseName -notlike "*202*" -and $database.DatabaseName -notlike "*ESPELHO*" `
                -and $database.DatabaseName -notlike "*treinamento*" -and $database.DatabaseName -notlike "*test*" -and $database.DatabaseName -notlike "*apresentacao*" -and  $database.DatabaseName -notlike '*_*')
                {
                    if($database.DatabaseName -notmatch [String]::Join('|','cra-sp.implanta.net.br|cra-rs.implanta.net.br|cra-sc.implanta.net.br|oab-ba.implanta.net.br|cro-sp.implanta.net.br'))
                    {
                        $tags += $tags_6meses
                    }
                    else 
                    {
                        $tags += $tags_umano
                    }
                }
                else {
                    
                    $tags += $tags_setedias
                }
            }
            else 
            {
                $tags += $tags_setedias
            }

            Set-AzResource -ResourceId $resource.Id `
                -Tag $tags `
                -Force
            
            write-host -Foregroundcolor Green $database.DatabaseName $tags.Values
        }
    }

      
