# This Script should be run automatically once a day (cronjob) #
#
# Function : Automation of User Creation
#
#
# Steps: 
#
#  1. Connect to Exchange Server 
#  2. Read in CSV 
#  3. Create AD-User from CSV-Object
#  4. Copy UserGroup from Standard LocationUser to ADUser
#  5. Add AD-User to O365 User Group
#  5. Enable Mailbox & Start Migration
#  6. Log into TXT file
 
# Set-ExecutionPolicy Unrestricted

Set-ExecutionPolicy Unrestricted

# install Module to current powershell 

Import-Module ActiveDirectory

# ConnectToOnPremExchange

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;

# Read CSV to get new User Info

$NewUserCsv = Import-Csv C:\Temp\NewUser_Mailbox.csv -Header 'Fullname', 'FirstName', 'LastName','Kuerzel','Location','Email' -Delimiter ';' |Select-Object -Skip 1| ForEach-Object {
    
    $Kuerzel = $_.Kuerzel
    $FLname = $_.Fullname
    $Fname = $_.FirstName
    $Lname = $_.LastName
    $Kuerzel = $_.Kuerzel
    $OU = $_.Location
    $Location = "steiner.local/CH/" + $_.Location
    $Email = $_.Email

    if( @(Get-ADUser -Filter ('SamAccountName -eq $Kuerzel')).Count -eq 0) 
    {
        Write-Host $FLname $Fname $Lname $Kuerzel $OU $Location $Email   
        
        #Copy StandartUser from Location

        $standartuser = ""
        $path = ""

        switch($OU){

            zh{
                $standartuser = "SZH"
                $path = "OU=ZH , OU=CH, DC=steiner, DC=local"
                    }
            be{
                $standartuser = "SBE"
                $path = "OU=BE , OU=CH, DC=steiner, DC=local"
                   }
            bl{
                $standartuser = "SBL"
                $path = "OU=BL , OU=CH, DC=steiner, DC=local"
                   }
            ge{
    
                $standartuser = "SGE"
                $path = "OU=GE , OU=CH, DC=steiner, DC=local"
                   }
            la{
                $standartuser = "SLA"
                $path = "OU=LA , OU=CH, DC=steiner, DC=local"
                   }
            lu{
                $standartuser = "SLU"
                $path = "OU=LU , OU=CH, DC=steiner, DC=local"
       
            }
            sif{
                $standartuser = "SSIF"
                $path = "OU=SIF , OU=CH, DC=steiner, DC=local"
                      
            }
    
            default { Write-Host "Choose a valid Location"}
           }

            #Create AD User
             New-ADUser -Name $Flname -Accountpassword (Read-Host -AsSecureString "Steiner2022") -FirstName $Fname -LastName $Lname -Alias $Kuerzel -SamAccountName $Kuerzel -Path $path -Enabled $true

            #Copy AD-Groups from StandardUser to NewUser:

            $usertoaddtogroup = Get-ADUser -Identity $Kuerzel

            $getusergroups = Get-ADUser –Identity $standartuser -Properties memberof | Select-Object -ExpandProperty memberof
            $getusergroups | Add-ADGroupMember -Members $usertoaddtogroup -verbose

            
            #Connect Mailbox to new User 
             Enable-Mailbox -Identity $Kuerzel -Database "MXDB001"
            
            #Add User to O365-LicGroup
             Add-ADGroupMember -Identity LIC-Office-365-E3-EAS -Members $Kuerzel
                       
             Write-Host "----------- $FLname HAS BEEN SUCCESFULLY CREATED AND ADDED TO THE GROUPS--------------"
            
            #Log file 

            $Logfile = "C:\Temps\log_" + (Get-Date -Format HH:mm:ss) + ".txt"
            $Migrationlog = "C:\Temps\MigrationLog_" + (Get-Date -Format HH:mm) + ".txt"
            $CurrentTime = Get-Date -Format "dddd MM/dd/yyyy HH:mm K"

            Write-Host " $FLname : $Kuerzel : $OU : $Location : $Email : $CurrentTime" | Out-File -FilePath $Logfile -Append


            #Connect to Exchange Online
            Connect-ExchangeOnline

            #Migrate User to Exchange Online
            New-MoveRequest -Identity $Email -Remote -RemoteHostName "webmail.steiner.ch" -TargetDeliveryDomain "steiner.ch" -RemoteCredential (Get-Credential steiner\karm)

            #Move Request Status
            Get-MoveRequest -Identity $Email | Get-MoveRequestStatistics > $Migrationlog -Append
                                 
    }else{

            Write-Host "USER ALREADY EXiSTS SKIP TO NEXT IN ROW..."
    }
    
} 



