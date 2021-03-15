
$databases_a_arquivar =
'cro-sp.conversor',
'cra-sc.Conversor',
'cra-sp.conversor',
'cra-es.conversor',
'cra-df.conversor',
'cra-mt.conversor',
'cra-al.conversor',
'cra-to.conversor',
'cra-pe.conversor',
'cra-am.conversor',
'cra-ma.conversor',
'cra-pb.conversor',
'cra-se.conversor',
'cra-ro.conversor',
'cra-rn.conversor',
'cra-pi.conversor',
'cra-go.conversor',
'cra-ba.conversor',
'cra-ms.conversor',
'cra-ap.conversor',
'cra-pa.conversor',
'cra-es.conversor-2',
'cra-es.conversor-3',
'cress-pr.conversor',
'cress-pe.conversor',
'cress-df.conversor',
'cress-pa.conversor',
'cress-ms.conversor',
'cress-rj.conversor',
'cress-sc.conversor',
'cress-mg.conversor',
'cress-rs.Conversor',
'cress-ce.conversor',
'cress-rr-Conversor',
'cress-sp.Conversor',
'cra-sp.conversor-incremental';

#Variaveis de definição

$ServerName = '?'

$StorageKeytype = '?'
$StorageKey = '?'

$resourceGroupName = '?'
$storageAccName = '?'
$containerName ='?'



$User = '?'
$pass = '?'
$securePassword = ConvertTo-SecureString -String $pass -AsPlainText -Force
$waitDelay = 10


$LisBackupsExportados = New-Object -TypeName "System.Collections.ArrayList"


$storageAcc=Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccName 


## Get the storage account context  
$ctx=$storageAcc.Context  

 ## Get all the containers  
 $containers=Get-AzStorageContainer  -Context $ctx 


 ## Get all the blobs  
 $blobs=Get-AzStorageBlob -Container $containerName  -Context $ctx  

  ## Loop through all the blobs  
  foreach($blob in $blobs)  
  {  
      write-host -Foregroundcolor Yellow $blob.Name  
      $LisBackupsExportados.Add($blob.Name)
  }  


  foreach($blob in $LisBackupsExportados)
  {
        $dbName = $blob.Replace(".bacpac","")

       $database = Get-AzSqlDatabase -ResourceGroupName $resourceGroupName  -ServerName $ServerName -DatabaseName $dbName

       if($database)
       {
        write-host -Foregroundcolor Yellow $database.DatabaseName
        Remove-AzSqlDatabase  -ResourceGroupName $resourceGroupName -ServerName $ServerName  -DatabaseName $dbName

       }
       else {
        write-host -Foregroundcolor Red $dbName     
       }

  }