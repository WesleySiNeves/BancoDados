
#Variaveis de definição

$resourceGroup ='RgPrd'
$serverName ='rgprd-sqlsrv-prd01'

$tags_setedias  = @{"backup"="7dias"}
$tags_6meses  = @{"backup"="6meses"}
$tags_umano  = @{"backup"="1ano"}

$databasesInServer = Get-AzSqlDatabase -ResourceGroupName $resourceGroup  -ServerName $serverName 

  foreach($database in $databasesInServer)
  {

       $tags = $database.Tags
       $resource = Get-AzResource -Name $database.DatabaseName -ResourceGroup $resourceGroup
    
       if(-not $tags)
       {
         $tags = @{}
       }
       
        if($tags.ContainsKey('backup') -eq $false)
        {
            

            if($database.DatabaseName -like "*implanta.net.br*")
            {
                if($database.DatabaseName -notlike "*old*" -and $database.DatabaseName -notlike "*copy*" -and $database.DatabaseName -notlike "*202*" -and $database.DatabaseName -notlike "*ESPELHO*" `
                -and $database.DatabaseName -notlike "*treinamento*" -and $database.DatabaseName -notlike "*test*" -and $database.DatabaseName -notlike "*apresentacao*")
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

        if($database.DatabaseName -match [String]::Join('|','apresentacao-siscaf.implanta.net.br|patrimonio-df.implanta.net.br|DNE|cra-df.conversor_2'))
        {
            
            if($tags.ContainsKey('backup') -eq $true)
            {
        
                $retencion_LTR =  Get-AzSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $database.DatabaseName
                $retencion_PITR = Get-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $database.DatabaseName


                if($tags['backup'] -eq '7dias')
                {

                    if ($retencion_PITR.RetentionDays -ne '7') 
                    {
                        # set retencion onothers  databases for 07 days
                        Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $database.DatabaseName -RetentionDays 7
                        Set-AzSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $database.DatabaseName -WeeklyRetention P0M
                    }

                }

                if($tags['backup'] -eq '6meses' -or  $tags['backup'] -eq '1ano')
                {

                    if ($retencion_PITR.RetentionDays -ne '35') 
                    {
                        Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $database.DatabaseName -RetentionDays 35
                    }
                    # set retencion in all databases for LTR  Week for 3 months
                    if ($retencion_LTR.WeeklyRetention -ne 'P3M' -or $retencion_LTR.MonthlyRetention -ne 'P6M') 
                    {
                        Set-AzSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $database.DatabaseName -WeeklyRetention P3M -MonthlyRetention P6M
                    }
                    
                }
                if($tags['backup'] -eq '1ano')
                {

                    if ($retencion_LTR.YearlyRetention -ne 'P1Y') 
                    {
                        Set-AzSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $database.DatabaseName -WeeklyRetention P3M -MonthlyRetention P6M -YearlyRetention P1Y  -WeekOfYear 1
                    }
                }
            }

        }
  }
