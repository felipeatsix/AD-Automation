function NewADUser {
<#
  .SYNOPSIS
       This function is part of the Active Directory Account Management Automator Tool. It is used to perform all routine
       tasks that must be done when onboarding a new employee user account.
        
  .EXAMPLE
      PS> NewADUser -firstname 'Felipe' -MiddleName 'Souza' -LastName 'Santos' -Title 'Powershell Scripter' -Group 'Powershell Guys'

      This example creates an AD username based on company standards into a company-standard OU and adds the user
      into the company-standard main user group.      
      
      Notes: 
        -MiddleName and -Group parameters are not mandatory.
         Use the -Group parameter only to add the user to a specific domain group. 
  
  .PARAMETER FirstName
       Set the user's First Name.
  
  .PARAMETER MiddleName
       Set the user's Middle Name.
  
  .PARAMETER LastName
       Set the user's Last Name.
  
  .PARAMETER Title
       Set the user's Title.
  
  .PARAMETER Group 
       Adds the user to a specific domain group.            
#> 

#Parameters------------------------------------------------------------------------------------------------------- 

    [cmdletbinding()]
    param
(     
    [parameter(Mandatory = $true)]
    $FirstName,  
    [parameter(Mandatory = $false)]
    $MiddleName,
    [parameter(Mandatory = $true)]
    $LastName,     
    [parameter(Mandatory = $true)]
    $Title,   
    [parameter(Mandatory = $false)]
    $Group   
)

process {

#Constant Parameters----------------------------------------------------------------------------------------------

if($MiddleName){
   $MiddleInitial = ".$($MiddleName.Substring(0, 1).Tolower())"
}
$FirstName = $($FirstName.ToLower())
$LastName = $($LastName.ToLower())
  
$DomainDn = (Get-ADDomain).DistinguishedName
$Location = 'OU=Domain Users,OU=ITFLEE'
$DefaultPassword = 'p@ssw0rd'
$DefaultGroup = 'ITFLEE Users'


#Test username availability---------------------------------------------------------------------------------------

$username = "$firstName.$lastName"

try {
      if (Get-ADUser -filter * | ? {$_.name -eq $username}){
      $username = "$($FirstName.substring(0,1))$MiddleInitial$LastName"
    
        if (Get-ADUser -filter * | ? {$_.name -eq $username}){
        Write-Warning "No acceptable username schema could be created!"
        return     
        }  
      }
    }  
       catch {
         Write-Error "$($_.Execption.Message) - Line Number : $($_.InvocationInfo.ScriptLineNumber)"
       }        

#Set new user parameters and create it----------------------------------------------------------------------------

$NewUserParams = @{

    'UserPrincipalName'     = $username
    'Name'                  = $username
    'GivenName'             = $FirstName
    'Surname'               = $LastName
    'Title'                 = $Title
    'SamAccountName'        = $username
    'AccountPassword'       = (ConvertTo-SecureString $DefaultPassword -AsPlainText -force)
    'Enabled'               = $true
    'Path'                  = "$location,$DomainDn"
    'ChangePassWordAtLogon' = $true  
}

#If user has a middle name, then add the middle initial name to the parameter 'Initials'.

    if($MiddleInitial){
     $NewUserParams += @{'Initials' = $MiddleInitial}
    }

New-ADUser @NewUserParams 

#Add new user to default group and specific group-----------------------------------------------------------------

Add-ADGroupMember -Identity $DefaultGroup -Members $username

  if($group -ne $null){
    try{
      Add-ADGroupMember -Identity $Group -Members $username 
    }
      catch{
      Write-Error "The group $group does not exist."
      }
  }
    
#Show Results-----------------------------------------------------------------------------------------------------

Write-Host "
A new Active Directory user account has been created:`n
Username = $username
Name = $FirstName
Middle Name = $MiddleName
Last Name = $LastName
Title = $Title
Default Group = $DefaultGroup
Specific Group = $Group
Location = $Location,$DomainDn" -ForegroundColor Cyan 
$username  
 }
}

function newADComputer {
<#
   .SYNOPSIS
       This function is part of the Active Directory Account Management Automator Tool. It is used to perform all routine
       tasks that must be done when onboarding a new employee user account.

   .Example
       newADComputer -Computername [computername]
#>

   [cmdletbinding()]
   param
(
   [parameter(Mandatory=$true)]
   $Computername,   
   $Location = 'OU=Domain Computers,OU=ITFLEE'
)  

process {
$DomainDn = (Get-ADDomain).DistinguishedName
$DefaultOuPath = "$Location,$DomainDn"

#Test hostname availability--------------------------------------------------------------------

try{
     if(Get-ADComputer $Computername){    
       Write-Error "The computer name '$Computername' already exists"    
       exit
  }
} 
catch{}

#Create new AD computer------------------------------------------------------------------------

New-ADComputer -Name $Computername -Path "$DefaultOuPath"

#Show Results----------------------------------------------------------------------------------

Write-host "
A new Active Directory computer has been created:`n
Hostname: $Computername
Location: $Location,$DomainDn
" -ForegroundColor Cyan
 }
}

function Set-MyADcomputer {

<#
   .SYNOPSIS
       This function is part of the Active Directory Account Management Automator Tool. It is used to perform all routine
       tasks that must be done when onboarding a new employee user account.

   .Example 
      cd [script location]
      Set-MyADcomputer -computername [ComputerName] -Attributes @{key = 'value'; key = 'value'}

      NOTE: The 'keys' are the Set-ADComputer cmdlet parameters, you can use intellisense to discover all parameters of this cmdlet.   

   .Example2:            
     Set-MyADcomputer -computername VM01 -Attributes @{description = 'Lab - Virtual Machine'; displayname = 'VM01'}
#>
  [cmdletbinding()]
  param(
  [string]$computername,
  [hashtable]$Attributes
  )
process {
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
 }
}

function Set-MyAdUser {
<# 
   .SYNOPSIS
   This function is part of the Active Directory Account Management Automator Tool. It is used to perform all routine
   tasks that must be done when onboarding a new employee user account.

   .Example    
      Set-MyAdUser -username [username] -attributes @{key = 'key value'}  
      
      NOTE: The 'keys' are the Set-ADUser cmdlet parameters, you can use intellisense to discover all parameters of this cmdlet. 

   Example2:
      Set-MyAdUser -username [username] -attributes @{GivenName = 'Tony'; Surname = 'Stark'; Initials = 'TS'}
#>    
    
    [cmdletbinding()]
    param(
    [string]$username,
    [hashtable]$attributes
    )
  process {
# Attempt to find the username
  Try{
    $useraccount = Get-ADUser $username
     if(!$useraccount){
       Write-Error "The username '$username' does not exist"
       return
     }
  } catch{}

# The $attributes parameter will contain only the parameters for the Set-AdUser cmdlet other than
# Password. If this is in $attributes it needs to be threated differentely. 

  if($attributes.ContainsKey('Password')){
    $Useraccount | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $attributes.Password -Force)
    # Remove the password key because we'll be passing this hashtable to Set-AdUser later.  
    $attributes.Remove('Password')
  }
    $useraccount | Set-ADUser @attributes
 }
}
