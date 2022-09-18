# PowershellScripts
Powershell Scripts to Automate everday Tasks


#UserCreation.ps

TYPE OF ENVIRONMENT : HYBRED 

- Creates Users directly from a CSV File ( if user exists it skips to next in row)
- Adds new created Users to the same Groups as (Default Location User)
- Adds O365 Licence Group 
- Enables Mailbox
- Starts Migration to Exchange Online
- Logs User,Date of Creation and Migration Status in a File

Cronjob is set to execute 1x Daily
