
$ResourceGroup ='rg-bootcamp-igti'
$Servername = 'serverdatabasenexxus-dev'
$location ='East US'
$UserAdmim = 'Wesley'
$Password ='W&$L&1N&V&$_96086512'

New-AzSqlServer -ResourceGroupName $ResourceGroup -ServerName $Servername -Location $location -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserAdmim, $(ConvertTo-SecureString -String $Password -AsPlainText -Force))
