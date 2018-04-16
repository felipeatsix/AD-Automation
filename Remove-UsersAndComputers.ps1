function Remove-UsersAndComputers {
  <#
  .SYNOPSIS
        Delete domain users and computers listed in a CSV file.
  .PARAMETER CsvFile
        Select a csv file by specifying it's path.        
  .EXAMPLE
        Remove-UsersAndComputers -CsvFile .\FELIPETHEPOSHGUY\RemoveEmployees.csv 
  .Notes
        The script will expect that CSV file contains domain usernames (not the employees names) and domain computer names.
        Also, the script will expect that domain computers descriptions contains the name of the username, then validate it before removing it. 
  #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $CsvFile
    )

  #Import CSV file data to $Employess        
  $Employees = Import-CSV -Path $CsvFile

  #For each line of CSV content, pass it's attributes to $UserParam and $ComputerParam hashtables.
    foreach($Employee in $Employees){      
        $UserParam = @{
            'Identity' = $Employee.Username
        }
        $ComputerParam = @{
            'Identity' = $Employee.ComputerName
        }  

      #Try to find the username, if it doesn't exist throw the error message, instead, warn that username will be removed.
        try{    
            if(!(Get-ADUser -Filter "SamAccountName -eq '$($Employee.UserName)'")){
                Write-Error "Username $($Employee.UserName) doesn't exist."
                return         
            }
            else{
                Write-Warning "Username $($Employee.Username) will be removed!"
            }        
 
        #Catch errors and throw the script line which the error has occurred. 
        } 
        catch{
            Write-Error "$($_.Exception.Message) : - Line Number : $($_.InvocationInfo.ScriptLineNumber)"
        }             

        #If everything went fine, remove the user and the computer account, a warn message will prompt to confirm the action.
        #You might want to bypass this warning, if so, just add the [-confirm] parameter.     
     
        Remove-ADUser @UserParam -confirm
        Remove-ADComputer @ComputerParam -confirm
    }
}       
