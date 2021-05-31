
$resourceGroupName ='RgPrd'
$sqlServerName  ='?'

$dbName ='patrimonio-df.implanta.net.br'


$resourceGroupName ='RgPrd'
$sqlServerName  ='?'

$dbName ='patrimonio-df.implanta.net.br'


$IgnoreDB = @('master', '')

$prince_tier ='Elastic Standard'

$size__100MB = 100MB
$size_500MB = 500MB
$size_1GB = 1GB
$size_2GB = 2GB
$size_5GB = 5GB
$size_10GB = 10GB
$size_20GB = 20GB
$size_30GB = 30GB
$size_40GB = 40GB
$size_50GB = 50GB
$size_50GB = 50GB
$size_100GB = 100GB
$size_150GB = 150GB
$size_200GB = 200GB
$size_250GB = 250GB
$size_300GB = 300GB
$size_400GB = 400GB



$IgnoreDB = @('master', '')

$database = Get-AzSqlDatabase -ResourceGroupName $resourceGroupName  -ServerName $sqlServerName  -DatabaseName $dbName

$db_resource = Get-AzResource -ResourceId $database.ResourceId

$db_MaximumStorageSize = $database.MaxSizeBytes / 1GB

$db_metric_storage = $db_resource | Get-AzMetric -MetricName 'storage'

$db_UsedSpace = $db_metric_storage.Data.Maximum | Select-Object -Last 1

$db_UsedSpace = [math]::Round($db_UsedSpace / 1GB, 2)

# Database used space procentage
$db_metric_storage_percent = $db_resource | Get-AzMetric -MetricName 'storage_percent'
$db_UsedSpacePercentage = $db_metric_storage_percent.Data.Maximum | Select-Object -Last 1