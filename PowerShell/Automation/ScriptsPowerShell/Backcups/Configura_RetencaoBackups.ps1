

$resourceGroup ='RgPrd'
$serverName ='rgprd-sqlsrv-prd01'

$tags_setedias  = @{"backup"="7dias"}
$tags_6meses  = @{"backup"="6meses"}
$tags_umano  = @{"backup"="1ano"}

$database = Get-AzSqlDatabase -ResourceGroupName $resourceGroup  -ServerName $serverName  -DatabaseName 'patrimonio-df.implanta.net.br'

if($database.DatabaseName -match [String]::Join('|','apresentacao-siscaf.implanta.net.br|patrimonio-df.implanta.net.br|DNE|cra-df.conversor_2'))
{

    $tags = $database.Tags

    if(-not $tags)
    {
        $tags = @{}
    }

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
            if ($retencion_LTR.WeeklyRetention -eq 'PT0S' -or $retencion_LTR.MonthlyRetention -eq 'PT0S') 
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



