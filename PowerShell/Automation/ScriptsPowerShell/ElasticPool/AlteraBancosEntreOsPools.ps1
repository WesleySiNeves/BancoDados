
$databases_a_migrar = 'apresentacao-siscaf.implanta.net.br',
'cro-mt.implanta.net.br',
'cro-pa.implanta.net.br',
'cro-pb.implanta.net.br',
'cro-pe.implanta.net.br',
'cro-pi.implanta.net.br',
'cro-es.implanta.net.br',
'cro-go.implanta.net.br',
'cro-ma.implanta.net.br',
'cro-ac.implanta.net.br',
'cro-al.implanta.net.br',
'cro-am.implanta.net.br',
'cro-ap.implanta.net.br',
'cro-ba.implanta.net.br',
'cro-ce.implanta.net.br',
'cro-df.implanta.net.br',
'cro-rj.implanta.net.br',
'cro-rn.implanta.net.br',
'cro-ro.implanta.net.br',
'cro-rr.implanta.net.br',
'cro-rs.implanta.net.br',
'cro-sc.implanta.net.br',
'cro-se.implanta.net.br',
'cro-to.implanta.net.br',
'cra-rj.implanta.net.br',
'cra-mg.implanta.net.br',
'cra-ms.implanta.net.br',
'cra-es.implanta.net.br',
'cra-ap.implanta.net.br',
'cra-ac.implanta.net.br',
'cra-rr.implanta.net.br',
'cress-to.implanta.net.br',
'cress-ac.implanta.net.br',
'cress-se.implanta.net.br',
'cress-rn.implanta.net.br',
'cress-pi.implanta.net.br',
'cress-ms.implanta.net.br',
'cress-mt.implanta.net.br',
'cress-pa.implanta.net.br',
'cress-pb.implanta.net.br',
'cress-df.implanta.net.br',
'cress-es.implanta.net.br',
'cress-go.implanta.net.br',
'cress-ma.implanta.net.br',
'cress-ba.implanta.net.br';

#Variaveis de definição

$ServerName = 'rgprd-sqlsrv-prd01'
$TargetElasticPoolName ='?'


$resourceGroupName = '?'



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