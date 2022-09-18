##Declaration of External variables

$Accountpassword = "Steiner2022"

$Database = "MXDB001"
$O365Lic = "LIC-Office-365-E3-EAS"

$LogFile = "C:\Temps\log_" + (Get-Date -Format HH:mm:ss) + ".txt"
$MigrationLog = "C:\Temps\MigrationLog_" + (Get-Date -Format HH:mm) + ".txt"
$CurrentTime = Get-Date -Format "dddd MM/dd/yyyy HH:mm K"     

$RemoteHostName = "webmail.steiner.ch"   
$TargetDeliveryDomain = "steiner.ch"              