
$databases_a_migrar = 
'cro-mg.conversor',
'oab-ba.conversor',
'cro-rs.conversor',
'cro-ba.conversor',
'cro-go.conversor',
'cro-sc.conversor',
'cro-pe.conversor',
'cro-df.conversor',
'cro-ce.conversor',
'cro-es.conversor',
'cro-pb.conversor',
'cro-pa.conversor',
'cro-mt.conversor',
'cro-rn.conversor',
'cro-ms.conversor',
'cro-am.conversor',
'cra-ba.conversor',
'cro-ma.conversor',
'cro-al.conversor',
'cro-pi.conversor',
'cro-se.conversor',
'cro-to.conversor',
'cro-ro.conversor',
'cro-ce.conversor_2',
'cress-sp.Conversor',
'cra-pr.conversor2',
'cref-rs.conversor',
'crtr-sp.conversor',
'cress-go.conversor',
'cress-ma.conversor',
'cress-rn.conversor',
'cress-pi.conversor',
'cro-ac.conversor',
'cro-ap.conversor',
'cress-pe.conversor',
'cro-rr.conversor',
'cra-mt.conversor',
'cro-pr.conversor_2',
'cro-pr.conversor2',
'cra-df.conversor_2';

#Variaveis de definição

$ServerName = 'rgprd-sqlsrv-prd01'
$TargetElasticPoolName ='rgprd-elspool-prd01'


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