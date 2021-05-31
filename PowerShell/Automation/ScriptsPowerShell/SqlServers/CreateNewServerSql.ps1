
$ResourceGroup ='rg-bootcamp-igti'
$Servername = '?'
$location ='East US'
$UserAdmim = '?'
$Password ='?'

New-AzSqlServer -ResourceGroupName $ResourceGroup -ServerName $Servername -Location $location -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserAdmim, $(ConvertTo-SecureString -String $Password -AsPlainText -Force))
