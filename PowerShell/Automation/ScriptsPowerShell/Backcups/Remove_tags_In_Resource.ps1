
$databases_a_consertar =  'apresentacao-siscaf.implanta.net.br',
'treinamento-siscaf.implanta.net.br',
'patrimonio-df.implanta.net.br',
'cra-sp.implanta.net.br-ESPELHO',
'cro-sp.implanta.net.br-ESPELHO',
'oab-ba.implanta.net.br-ESPELHO';

#Variaveis de definição

$resourceGroup ='RgPrd'
$serverName ='rgprd-sqlsrv-prd01'

  foreach($dbName in $databases_a_consertar)
  {

    $resource = Get-AzResource -Name $dbName -ResourceGroup $resourceGroup

    $tags = @{}

    Set-AzResource -ResourceId $resource.Id `
        -Tag $tags `
        -Force

    write-host -Foregroundcolor Green $dbName $tags.Values

  }