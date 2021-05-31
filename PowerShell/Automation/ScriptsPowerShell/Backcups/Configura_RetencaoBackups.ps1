

$resourceGroupName ='RgPrd'
$sqlServerName  ='?'
$nameTagSqlPolicy ='sql-backup-policy'

$tags_setedias  = @{"sql-backup-policy"="7dias"}
$tags_6meses  = @{"sql-backup-policy"="6meses"}
$tags_umano  = @{"sql-backup-policy"="1ano"}

# param 
# ( 
#     # Target Azure Resource Group 
#     [parameter(Mandatory=$true)]  
#     [string] $resourceGroupName, 

#     # Name of the Azure SQL Database server 
#     [parameter(Mandatory=$true)]  
#     [string] $sqlServerName, 

#     # Name of the Azure tag of policy backup 
#     [parameter(Mandatory=$true)]  
#     [string] $nameTagSqlPolicy,

#     [parameter(Mandatory=$true)]  
#     [string] $subscriptionId 

# )


$connectionName = "AzureRunAsConnection"
$servicePrincipalConnection = Get-AutomationConnection -Name $connectionName
$connectionResult =  Connect-AzAccount -Tenant $servicePrincipalConnection.TenantID `
                            -ApplicationId $servicePrincipalConnection.ApplicationID   `
                            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint `
                            -ServicePrincipal

$subscription = Get-AzSubscription -SubscriptionId $subscriptionId 
Set-AzContext $subscription


$tags_setedias  = @{"sql-backup-policy"="7dias"}
$tags_6meses  = @{"sql-backup-policy"="6meses"}
$tags_umano  = @{"sql-backup-policy"="1ano"}

$IgnoreDB = @('master', '')




$databasesInServer = Get-AzSqlDatabase -ResourceGroupName $resourceGroupName  -ServerName $sqlServerName | Where-Object { $_.DatabaseName -notin $IgnoreDB }

$ListltrPolicies = $databasesInServer | Get-AzSqlDatabaseLongTermRetentionPolicy

$ListPITRPolicies = $databasesInServer | Get-AzSqlDatabaseBackupShortTermRetentionPolicy

foreach($database in $databasesInServer)
{
    $tags.Clear()

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
                     $tags += $tags_6meses
                }
                else
                {
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

    }

    if($tags.ContainsKey($nameTagSqlPolicy) -eq $true)
    {
        if($database.DatabaseName -match [String]::Join('|','apresentacao-siscaf.implanta.net.br|oab-ba.implanta.net.br-ESPELHO'))
        {

            $retencion_LTR =  $ListltrPolicies | Where-Object { $_.DatabaseName -match $database.DatabaseName }

            #   Get-AzSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -DatabaseName $database.DatabaseName
            $retencion_PITR =  $ListPITRPolicies | Where-Object { $_.DatabaseName -match $database.DatabaseName }
            #Get-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -DatabaseName $database.DatabaseName


            if($tags[$nameTagSqlPolicy] -eq '7dias')
            {

                if ($retencion_PITR.RetentionDays -ne '7') 
                {
                    # set retencion onothers  databases for 07 days
                   
                    Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -DatabaseName $database.DatabaseName -RetentionDays 7
                    
                }
                if($retencion_LTR.WeeklyRetention -ne 'PT0S' -or $retencion_LTR.MonthlyRetention -ne 'PT0S' -or $retencion_LTR.YearlyRetention -ne 'PT0S')
                {
                    Set-AzSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -DatabaseName $database.DatabaseName -WeeklyRetention P0M -MonthlyRetention P0M  -YearlyRetention P0Y -WeekOfYear 1
                }

            }

            if($tags[$nameTagSqlPolicy] -eq '6meses')
            {
                if ($retencion_PITR.RetentionDays -ne '35') 
                {
                    Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -DatabaseName $database.DatabaseName -RetentionDays 35
                }

                if ($retencion_LTR.WeeklyRetention -ne 'P3M' -or $retencion_LTR.MonthlyRetention -ne 'P6M' -or $retencion_LTR.YearlyRetention -ne 'P0Y') 
                {
                    Set-AzSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -DatabaseName $database.DatabaseName -WeeklyRetention P3M -MonthlyRetention P6M -YearlyRetention P0Y -WeekOfYear 1
                }

            }
            if($tags[$nameTagSqlPolicy] -eq '1ano')
            {

                if ($retencion_PITR.RetentionDays -ne '35') 
                {
                    Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -DatabaseName $database.DatabaseName -RetentionDays 35
                }

                if ($retencion_LTR.YearlyRetention -ne 'P1Y' -or $retencion_LTR.WeeklyRetention -ne 'P3M' -or $retencion_LTR.MonthlyRetention -ne 'P6M') 
                {
                    Set-AzSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -DatabaseName $database.DatabaseName -WeeklyRetention P3M -MonthlyRetention P6M -YearlyRetention P1Y  -WeekOfYear 1
                }
            }
        }
    }
}
