
$databases_a_migrar = 
'apresentacao-siscaf.implanta.net.br',
'patrimonio-df.implanta.net.br',
'cra-df.conversor_2',
'DNE';

#Variaveis de definição

$ServerName = 'rgprd-sqlsrv-prd01'


$resourceGroupName = 'RgPrd'



  foreach($dbName in $databases_a_migrar)
  {
       

       $database = Get-AzSqlDatabase -ResourceGroupName $resourceGroupName  -ServerName $ServerName -DatabaseName $dbName

       if($database)
       {

          if($database.ElasticPoolName -ne $TargetElasticPoolName)
          {
               write-host -Foregroundcolor Yellow $database.DatabaseName, $database.ElasticPoolName;
               Set-AzSqlDatabase -ResourceGroupName $resourceGroupName `
               -ServerName $serverName `
               -DatabaseName $dbName `
               -ElasticPoolName $TargetElasticPoolName

          }
          else {
               write-host -Foregroundcolor Green $dbName   
          }

       }
       else {
        write-host -Foregroundcolor Red $dbName     
       }

  }