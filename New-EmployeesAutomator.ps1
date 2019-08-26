function New-ADUser {
<#
    .SYNOPSIS
        This function is part of the Active Directory Account Management Automator Tool. It is used to perform all routine
        tasks that must be done when onboarding a new employee user account.        
    .EXAMPLE
        PS> NewADUser -firstname 'Felipe' -MiddleName 'Souza' -LastName 'Santos' -Title 'Powershell Scripter' -Group 'Powershell Guys'

        This example creates an AD Username based on company standards into a company-standard OU and adds the user
        into the company-standard main user group.            
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
    [cmdletbinding()]
    Param(     
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
    Process {
        if ($MiddleName) {
            $MiddleInitial = ".$($MiddleName.Substring(0, 1).Tolower())"
        }
        $FirstName = $($FirstName.ToLower())
        $LastName = $($LastName.ToLower())  
        $DomainDn = (Get-ADDomain).DistinguishedName
        $Location = 'OU=Domain Users,OU=ITFLEE'
        $DefaultPassword = 'p@ssw0rd'
        $DefaultGroup = 'ITFLEE Users'
        $Username = "$firstName.$lastName"

        try {
            if (Get-ADUser -filter * | Where-Object {$_.name -eq $Username}) {
                $Username = "$($FirstName.substring(0,1))$MiddleInitial$LastName"    
                if (Get-ADUser -filter * | Where-Object {$_.name -eq $Username}) {
                    Write-Warning "No acceptable Username schema could be created!"
                    return     
                }  
            }
        }  
        catch { Write-Error "$($_.Execption.Message) - Line Number : $($_.InvocationInfo.ScriptLineNumber)" }        

        $NewUserParams = @{
            'UserPrincipalName'     = $Username
            'Name'                  = $Username
            'GivenName'             = $FirstName
            'Surname'               = $LastName
            'Title'                 = $Title
            'SamAccountName'        = $Username
            'AccountPassword'       = (ConvertTo-SecureString $DefaultPassword -AsPlainText -force)
            'Enabled'               = $true
            'Path'                  = "$location,$DomainDn"
            'ChangePassWordAtLogon' = $true  
        }
        # If user has a middle name, then add the middle initial name to the parameter 'Initials'.
        if ($MiddleInitial) { $NewUserParams += @{'Initials' = $MiddleInitial} } ; New-ADUser @NewUserParams 
        
        #Add new user to default group and specific group
        Add-ADGroupMember -Identity $DefaultGroup -Members $Username
        
        if ($null -ne $group) {            
            try { Add-ADGroupMember -Identity $Group -Members $Username }
            catch { Write-Error "The group $group does not exist." }
        }

        #Show Results

        Write-Host "A new Active Directory user account has been created:" -ForegroundColor Cyan
        $Obj = @{
            'Username' = $Username
            'Name' = $FirstName
            'Middle Name' = $MiddleName
            'Last Name' = $LastName
            'Title' = $Title
            'Default Group' = $DefaultGroup
            'Specific Group' = $Group
            'Location' = @($Location,$DomainDn)                         
        }
        Write-Output $Obj  
    }
}
function New-ADComputer {
    <#
        .SYNOPSIS
        This function is part of the Active Directory Account Management Automator Tool. It is used to perform all routine
        tasks that must be done when onboarding a new employee user account.
        .Example
        newADComputer -Computername [computername]
    #>
    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true)]
        $Computername,   
        $Location = 'OU=Domain Computers,OU=ITFLEE'
    )  
    Process {

        $DomainDn = (Get-ADDomain).DistinguishedName
        $DefaultOuPath = "$Location,$DomainDn"        
        
        Try {
            if (Get-ADComputer $Computername) {    
                Write-Error "The computer name '$Computername' already exists"    
                exit
            }
        } 
        Catch { Write-Error "$($_.Execption.Message) - Line Number : $($_.InvocationInfo.ScriptLineNumber)" }

        New-ADComputer -Name $Computername -Path "$DefaultOuPath"
        Write-host "A new Active Directory computer has been created:" -ForegroundColor Cyan        
        $Obj = @{
            Hostname =  $Computername
            Location = @($Location,$DomainDn)
        }
        Write-Output $Obj        
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
        .Example2:            
        Set-MyADcomputer -computername VM01 -Attributes @{description = 'Lab - Virtual Machine'; displayname = 'VM01'}
    #>
    [cmdletbinding()]
    Param(
        [string]$Computername,
        [hashtable]$Attributes
    )
    Try { 
        If (!($Computer = Get-ADComputer -Identity $computername)) { Throw } 
    }       
    Catch { 
        Write-Warning "The computer $computername could not be found!"
        Break; 
    }
    $Computer | Set-ADComputer @Attributes   
}

function Set-MyAdUser {
    <# 
        .SYNOPSIS
        This function is part of the Active Directory Account Management Automator Tool. It is used to perform all routine
        tasks that must be done when onboarding a new employee user account.
        .Example    
        Set-MyAdUser -Username [Username] -attributes @{key = 'key value'}  
        NOTE: The 'keys' are the Set-ADUser cmdlet parameters, you can use intellisense to discover all parameters of this cmdlet. 
        Example2:
        Set-MyAdUser -Username [Username] -attributes @{GivenName = 'Tony'; Surname = 'Stark'; Initials = 'TS'}
    #>        
    [cmdletbinding()]
    Param(
        [string]$Username,
        [hashtable]$Attributes
    )    
    Process { 
        Try {
            If (!($UserAccount = Get-ADUser $Username)) { Throw }
        } 
        catch {
            Write-Error "The Username $Username does not exist"
            Break;
        }
        If ($attributes.ContainsKey('Password')) {
            $Useraccount | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $attributes.Password -Force)            
            $Attributes.Remove('Password')
        }
        $Useraccount | Set-ADUser @attributes
    }
}