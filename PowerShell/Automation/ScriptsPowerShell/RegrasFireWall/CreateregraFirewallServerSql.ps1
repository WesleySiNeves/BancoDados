

$AdicionarMyIp =  1
$myIp = (Invoke-WebRequest ifconfig.me/ip).Content
$IpAAdicionar =''

$ResouceGroup = 'rg-bootcamp-igti'
$ServerName ='?'
 


 if($AdicionarMyIp -eq 1){

    New-AzSqlServerFirewallRule -ResourceGroupName $ResouceGroup
    -ServerName $ServerName
    -FirewallRuleName "AllowedIPs" -StartIpAddress $myIp -EndIpAddress $myIp

 }

