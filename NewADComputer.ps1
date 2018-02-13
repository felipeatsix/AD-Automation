function newADComputer {

#Parameters------------------------------------------------------------------------------------

   [cmdletbinding()]param
(
   [parameter(Mandatory=$true)]
   $Computername,   
   $Location = 'OU=Domain Computers,OU=ITFLEE'
)  

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

#Show Results---------------------------------------------------------------------------------------

Write-host "
A new Active Directory computer has been created:`n
Hostname: $Computername"

}#end function

#Run fcuntion
newADComputer
