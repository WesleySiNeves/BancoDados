

$resourceGroup ='RgPrd'
$serverName ='rgprd-sqlsrv-prd01'

$list_databases = Get-AzSqlDatabase -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName 'apresentacao-siscaf.implanta.net.br'


foreach($database in $list_databases)
{
    $retencion_LTR =  Get-AzSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $database.DatabaseName
    $retencion_PITR = Get-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $database.DatabaseName

   if($database.DatabaseName -like "*implanta.net.br*")
   {
    
    
    if($database.Tags.ContainsKey('backup'))
    {

        # set retencion in all databases for 35 days
        if ($retencion_PITR.RetentionDays -ne '35') 
        {
            Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $database.DatabaseName -RetentionDays 35
        }

        # set retencion in all databases for LTR  Week for 3 months
        if ($retencion_LTR.WeeklyRetention -ne 'P3M') 
        {
            Set-AzSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName resourcegroup01 -ServerName server01 -DatabaseName $database.DatabaseName -WeeklyRetention P3M
        }

        # set retencion in all databases for LTR  Month for 6 months
        if ($retencion_LTR.MonthlyRetention -ne 'P6M') 
        {
            Set-AzSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName resourcegroup01 -ServerName server01 -DatabaseName $database.DatabaseName -MonthlyRetention P6M
        }

        if($database.Tags.backup -eq 'standard')
        {
            if ($retencion_LTR.YearlyRetention -ne 'P1M') 
            {
                Set-AzSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName resourcegroup01 -ServerName server01 -DatabaseName $database.DatabaseName -YearlyRetention P1M  -WeekOfYear 1
            }
        }
    }
    else
    {
         # set retencion onothers  databases for 07 days
         Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $database.DatabaseName -RetentionDays 7
     }
    }
    else
    {
         # set retencion onothers  databases for 07 days
         Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $resourceGroup -ServerName $serverName -DatabaseName $database.DatabaseName -RetentionDays 7
     }

    

}