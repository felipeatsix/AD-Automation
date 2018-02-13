function NewADUser {
 
#Dynamic Parameters----------------------------------------------------------------------------------------------- 

    [cmdletbinding()]param
(     
    [parameter(Mandatory = $true)]
    $FirstName,  
    [parameter(Mandatory = $true)]
    $MiddleName,  
    [parameter(Mandatory = $true)]
    $SecondMiddleName,
    [parameter(Mandatory = $true)]
    $LastName,
    [parameter(Mandatory = $true)]
    $Title,   
    [parameter(Mandatory = $true)]
    $Group
)

$MiddleName = $($MiddleName.Substring(0, 1))
$SecondMiddleName = $($SecondMiddleName.Substring(0, 1))

#Constant Parameters----------------------------------------------------------------------------------------------

$FirstName = $($FirstName.ToLower())
$MiddleName = $($MiddleName.ToLower())
$SecondMiddleName = $($SecondMiddleName.ToLower())
$LastName = $($LastName.ToLower())

$DomainDn = (Get-ADDomain).DistinguishedName
$Location = 'OU=Domain Users,OU=ITFLEE'
$DefaultPassword = 'p@ssw0rd'
$DefaultGroup = 'ITFLEE Users'


#Test username availability---------------------------------------------------------------------------------------

$username = "$FirstName.$LastName"

try {
    if (Get-ADUser $username) {    
        $username = "$FirstName$MiddleName$SecondMiddleName$($Lastname.Substring(0,1))"
       
        if(Get-ADUser $username) {
            $username = "$FirstName.$MiddleName$SecondMiddleName$LastName"                                       
          
           if(Get-ADUser $username) {
              Write-Warning "No acceptable username schema could be created!"
              exit
           }
        }
    }
}
catch {}        

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
    'Initials'              = $MiddleInitial
    'Path'                  = "$location,$DomainDn"
    'ChangePassWordAtLogon' = $true
}

New-ADUser @NewUserParams 

#Add new user to default group and specific group------------------------------------------------------------------

Add-ADGroupMember -Identity $DefaultGroup -Members $username
Add-ADGroupMember -Identity $Group -Members $username

#Show Results------------------------------------------------------------------------------------------------------

Write-Host "
A new Active Directory user account has been created:`n
Username = $username
Default Group = $DefaultGroup
Specific Group = $Group
Location = $Location,$DomainDn" -ForegroundColor Cyan 

}#end function----------------------------------------------------------------------------------------------------

#Run function-----------------------------------------------------------------------------------------------------
NewADUser
