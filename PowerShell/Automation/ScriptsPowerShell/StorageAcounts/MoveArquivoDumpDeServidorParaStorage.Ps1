cls

$origem = 'C:\Users\Wesley.Neves\Desktop\Arquivo\2001-jan-01.DMP'
$destino ='https://imdevblob02.blob.core.windows.net/dumps/2001-jan-01-2.DMP?sv=2019-12-12&se=2021-02-18T19%3A14%3A28Z&sr=c&sp=rwl&sig=csnJh7%2FhjbjF85ZkMhb%2FaFmq7AF7YV%2BxWMxG1QKs1Og%3D'

$env:AZCOPY_CRED_TYPE = "Anonymous";
azcopy.exe copy $origem $destino
$env:AZCOPY_CRED_TYPE = "";