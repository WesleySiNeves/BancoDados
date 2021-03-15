

$Resource ='RgPrd'
$ServerName ='rgprd-sqlsrv-prd01'
$DatabaseName ='cress-ac.implanta.net.br'
$date = '09-02-2021'
$StorageKeytype ='StorageAccessKey'
$StorageKey ='6XDERJnF6V34xAKomrppUbbOXhQRwkkb6Yz9KBrQvjvzVf+Ob+Pgi+kV9s0zE9FY8E4Wvwg7QEfDiT3JQmD1aw=='
$BacpacUri ='https://imdevblob02.blob.core.windows.net/bases/'+$DatabaseName +'_Antes_Migracao.bacpac'


$User = 'wesley.neves@implantainformatica.com.br'
$pass = 'karina_96086512'
$securePassword = ConvertTo-SecureString -String $pass -AsPlainText -Force

New-AzSqlDatabaseExport -ResourceGroupName $Resource -ServerName $ServerName-DatabaseName $DatabaseName -StorageKeyType $StorageKeytype -StorageKey $StorageKey -StorageUri $BacpacUri  -AdministratorLogin $User -AdministratorLoginPassword $securePassword