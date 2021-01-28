

$Resource ='rg-bootcamp-igti'
$ServerName ='serverdatabasenexxus'
$DatabaseName ='AdventureWorks_Compress'
$date = '22-01-2021'
$StorageKeytype ='StorageAccessKey'
$StorageKey ='eejU1XJc4EN4mtRUr8Kz9cfL6iLCGvW7oAQrQKafMJ3giZeUsuTC0+aFNJec5SHKF83wKTp7g2xuLH0R/on14Q=='
$BacpacUri ='https://clientesantigos.blob.core.windows.net/backups/'+$DatabaseName +'_'+$date+'.bacpac'


$User = 'wesley.neves@implantainformatica.com.br'
$pass = 'karina_96086512'

New-AzSqlDatabaseExport -ResourceGroupName $Resource -ServerName $ServerName-DatabaseName $DatabaseName -StorageKeyType $StorageKeytype -StorageKey $StorageKey -StorageUri $BacpacUri  -AdministratorLogin $User -AdministratorLoginPassword $pass
