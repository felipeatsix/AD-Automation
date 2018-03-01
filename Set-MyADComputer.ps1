param(
  [string]$computername,
  [hashtable]$Attributes
)

# Attempt to find the computername
try{
# If the computername ins't found thow an error and exit
  $computer = Get-ADComputer -Identity $computername
    if(!$computer){
      Write-Error "The computername '$computername' does not exist"
      return
    }
} catch{}

# The $attributes parameter will contain only the parameters for the Set-AdComputer cmdlet

$computer | Set-ADComputer @Attributes

<# 
   Example of use: 

   cd [script location]
   .\Set-MyADcomputer.ps1 -computername [ComputerName] -Attributes @{key = 'value'; key = 'value'}

   Tip:
   The 'keys' are the Set-ADComputer cmdlet parameters, you can use intellisense to discover all parameters of this cmdlet.

   Example 2:
   Modidying description and displayname of an AD Computer
   
   cd [script location]
   .\Set-MyADcomputer.ps1 -computername VM01 -Attributes @{description = 'Lab - Virtual Machine'; displayname = 'VM01'}
#>
