
$databases_a_deletar =
'cau-sp.implanta.net.br_Copy',
'cau-sp.implanta.net.br_CopyBackup',
'cra-es.implanta.net.br_2021-01-10T10-09Z',
'cra-es.implanta.net.br_2021-02-10T08-00Z',
'cra-es.implanta.net.br_2021-02-22T08-15Z',
'cra-pi.implanta.net.br_2021-01-15T14-02Z',
'cra-rs.implanta.net.br_2020-09-01T02-04Z',
'cress-mg.implanta.net.br_2021-02-17T08-30Z',
'cress-rs.implanta.net.br_2021-02-04T08-23Z',
'crmv-rs.implanta.net.br_Copy',
'cro-df.implanta.net.br_2021-01-17T13-25Z',
'cro-mg.implanta.net.br_COPY',
'cro-pi.implanta.net.br_2021-02-22T08-30Z',
'cro-pr.implanta.net.br_2021-01-18T20-18Z',
'cro-rs.implanta.net.br_2021-02-16T08-31Z',
'crtr-sp.implanta.net.br_COPY',
'oab-ba.implanta.net.br_2021-02-12T10-30Z',
'oab-ba.implanta.net.br_2021-02-12T18-04Z',
'oab-rs.implanta.net.br_2021-02-16T13-03Z';

#Variaveis de definição

$ServerName = '?'
$resourceGroupName = '?'

$User = '?'
$pass = '?'
$securePassword = ConvertTo-SecureString -String $pass -AsPlainText -Force
$waitDelay = 10


  foreach($dbName in $databases_a_deletar)
  {
     

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