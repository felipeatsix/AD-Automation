param(
[string]$username,
[hashtable]$attributes
)

# Attempt to find the username
Try{
  $Useraccount = Get-ADUser -Identity $username
   if(!$Useraccount){
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

  $Useraccount | Set-ADUser @attributes

  # Example of use: 

  # cd [script location]
  # .\Set-MyAdUser.ps1 -username [username] -attributes @{key = 'key value'}
  
  # Tip:
  # The 'keys' are the Set-ADUser cmdlet parameters, you can use intellisense to discover all parameters of this cmdlet. 
  
  # Example 2: Modifying first name, last name and initials 
  
  # cd [script location]
  # .\Set-MyAdUser.ps1 -username [username] -attributes @{GivanName = 'Tony'; Surname = 'Stark'; Initials = 'TS'}
