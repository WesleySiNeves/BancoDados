$connectionName = "AzureRunAsConnection"
$servicePrincipalConnection = Get-AutomationConnection -Name $connectionName
$connectionResult =  Connect-AzAccount -Tenant $servicePrincipalConnection.TenantID `
                            -ApplicationId $servicePrincipalConnection.ApplicationID   `
                            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint `
                            -ServicePrincipal


Write-Output 'Processo iniciado'


$subscription = Get-AzSubscription -SubscriptionId '?'

Set-AzContext $subscription


$variaveis = Get-AzAutomationVariable  -ResourceGroupName 'RgPrd' -AutomationAccountName 'implanta-automationAzModule'

[string]$nameTagSqlOutDatabaseInPool ='out-database-pool'

$dateNow = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date), 'America/Sao_Paulo')


$resourceGroupDev =  $variaveis | Where-Object { $_.Name -eq 'DevResourceGroup'} 
$elasticPoolNameDev = $variaveis | Where-Object { $_.Name -eq 'DevElasticPoolName'} 



$sqlServersDev = Get-AzSqlServer -ResourceGroupName $resourceGroupDev.Value

$outsideDb

foreach($sqlserver in $sqlServersDev)
{
    
    $databases = Get-AzSqlDatabase -ResourceGroupName $resourceGroupDev.Value -ServerName $sqlserver.ServerName

    foreach($database in $databases | Where-Object { $_.CurrentServiceObjectiveName -notcontains 'ElasticPool'})
    {    
        
        if($database.DatabaseName -notmatch [String]::Join('|','master'))
        {    
            MoveDatabaseInElastcPoll -nameTagSqlOutDatabaseInPool $nameTagSqlOutDatabaseInPool -database $database -resourceGroup $resourceGroupDev.Value `
            -elasticPoolName $elasticPoolNameDev.Value -outsideDb $outsideDb
        }
    }
}

$outsideDb


$resourceGroupAtd =  $variaveis | Where-Object { $_.Name -eq 'AtdResourceGroup'} 
$elasticPoolNameAtd = $variaveis | Where-Object { $_.Name -eq 'AtdElasticPoolName'} 


$sqlServersAtd = Get-AzSqlServer -ResourceGroupName $resourceGroupAtd.Value


foreach($sqlserver in $sqlServersAtd)
{
    
    $databases = Get-AzSqlDatabase -ResourceGroupName $resourceGroupAtd.Value -ServerName $sqlserver

    foreach($database in $databases | Where-Object { $_.CurrentServiceObjectiveName -notcontains 'ElasticPool'})
    {    
        
        if($database.DatabaseName -notmatch [String]::Join('|','master'))
        {    
            MoveDatabaseInElastcPoll -nameTagSqlOutDatabaseInPool $nameTagSqlOutDatabaseInPool -database $database -resourceGroup $resourceGroupAtd.Value `
            -elasticPoolName $elasticPoolNameAtd.Value -outsideDb $outsideDb
        }
    }
}


$subscription = Get-AzSubscription -SubscriptionId '?'
Set-AzContext $subscription



$resourceGroupHml  =  $variaveis | Where-Object { $_.Name -eq 'HmlResourceGroup'} 
$elasticPoolNameHml = $variaveis | Where-Object { $_.Name -eq 'HmlElasticPoolName'} 


$SqlServersHml = Get-AzSqlServer -ResourceGroupName $resourceGroupHml.Value



foreach($sqlserver in $SqlServersHml)
{
    
    $databases = Get-AzSqlDatabase -ResourceGroupName $resourceGroupHml.Value -ServerName $sqlserver

    foreach($database in $databases | Where-Object { $_.CurrentServiceObjectiveName -notcontains 'ElasticPool'})
    {    
        
        if($database.DatabaseName -notmatch [String]::Join('|','master'))
        {    
            MoveDatabaseInElastcPoll -nameTagSqlOutDatabaseInPool $nameTagSqlOutDatabaseInPool -database $database -resourceGroup $resourceGroupHml.Value `
            -elasticPoolName $elasticPoolNameHml.Value -outsideDb $outsideDb
        }
    }
}




$subscription = Get-AzSubscription -SubscriptionId '?'
Set-AzContext $subscription





$resourceGroupPrd =  $variaveis | Where-Object { $_.Name -eq 'PRDResourceGroup'} 
$elasticPoolNamePrd  = $variaveis | Where-Object { $_.Name -eq 'PrdElasticPoolName_01'} 




$SqlServersPrd = Get-AzSqlServer -ResourceGroupName $resourceGroupPrd

foreach($sqlserver in $SqlServersPrd)
{
    
    $databases = Get-AzSqlDatabase -ResourceGroupName $resourceGroupPrd -ServerName $sqlserver

 

    foreach($database in $databases | Where-Object { $_.CurrentServiceObjectiveName -notcontains 'ElasticPool'})
    {    
        
        if($database.DatabaseName -notmatch [String]::Join('|','master|cro-sp.implanta.net.br|cra-sp.implanta.net.br|oab-ba.implanta.net.br'))        
        {    

            MoveDatabaseInElastcPoll -nameTagSqlOutDatabaseInPool $nameTagSqlOutDatabaseInPool -database $database -resourceGroup $resourceGroupPrd.Value `
            -elasticPoolName $elasticPoolNamePrd.Value -outsideDb $outsideDb
        }
    }
}

Write-Output 'Processo concluido'



function MoveDatabaseInElastcPoll 
{
    param (
        [Parameter(Position=0)]
        [string]$nameTagSqlOutDatabaseInPool,
        [Parameter(Position=1)]
        [Object] $database,
        [Parameter(Position=2)]
        [string] $resourceGroup,
        [Parameter(Position=3)]
        [string] $elasticPoolName,
        [Parameter(Position=4)]
        [string] $outsideDb
    )

    $tags = $database.Tags

    if(-not $tags)
    {
        $tags = @{}
    }

    if($tags.ContainsKey($nameTagSqlOutDatabaseInPool) -eq $false)
    {
      
        Write-Output $database.DatabaseName
        $outsideDb += $database.DatabaseName + ' - '
        Set-AzSqlDatabase -ResourceGroupName $resourceGroup -ServerName $database.ServerName  -DatabaseName $database.DatabaseName -ElasticPoolName $elasticPoolName
        return;
    }
    else 
    { 

        [datetime]$dataLimite = New-Object DateTime

        $valores = $tags.Get_Item($nameTagSqlOutDatabaseInPool);

        $timeRangeComponents = $valores -split "->" | foreach {$_.Trim()}

        $startHour , $endHour, $endDate ,$daysInPool = $null

        if($timeRangeComponents.Count -ge 3)
        {
            $startHour =$timeRangeComponents[0]
            $endHour = $timeRangeComponents[1]
            $endDate  =$timeRangeComponents[2]
        }

        if($timeRangeComponents.Count -ge 4 )
        {
            $daysInPool = $timeRangeComponents[3]

        }


        if([DateTime]::TryParseExact($endDate, "dd/MM/yyyy",
                            [System.Globalization.CultureInfo]::InvariantCulture,
                            [System.Globalization.DateTimeStyles]::None,
                            [ref]$dataLimite))
        {

            if($dateNow -ge $dataLimite.Date)
            {

                Write-Output $database.DatabaseName
                $outsideDb += $database.DatabaseName + ' - '
                Set-AzSqlDatabase -ResourceGroupName $resourceGroup -ServerName $database.ServerName  -DatabaseName $database.DatabaseName -ElasticPoolName $elasticPoolName
                return;

            }
        }
        if($dateNow.Hour -ge  (Get-Date -date $endHour).Hour -and $dateNow.Date -le $dataLimite.Date)
        {

                Write-Output $database.DatabaseName
                $outsideDb += $database.DatabaseName + ' - '
                Set-AzSqlDatabase -ResourceGroupName $resourceGroup -ServerName $database.ServerName  -DatabaseName $database.DatabaseName -ElasticPoolName $elasticPoolName
                return;
        }

        if($daysInPool -and $daysInPool -match $dateNow.dayofweek -and $dateNow.Date -le $dataLimite.Date)
        {
            Write-Output $database.DatabaseName
             $outsideDb += $database.DatabaseName + ' - '
             Set-AzSqlDatabase -ResourceGroupName $resourceGroup -ServerName $database.ServerName  -DatabaseName $database.DatabaseName -ElasticPoolName $elasticPoolName
        }
    }
}





