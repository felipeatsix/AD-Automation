# Import CSV file data to $Employess
$Employees = Import-CSV -Path 'C:\users\Administrator\Documents\Powershell Scripts\remove_employees.csv'

# For each loop, pass the attributes of each employee to $UserParam and $ComputerParam 
  foreach($Employee in $Employees){
      
      $UserParam = @{
           'Identity' = $Employee.Username
      }
      $ComputerParam = @{
           'Identity' = $Employee.ComputerName
      }  

# Try to find the username, if it does not exist throw the error message, instead, warn that username will be removed.
      try{    
        if(!(Get-ADUser -Filter * | ? {$_.name -eq "$Employee.UserName"})){
             Write-Error "Username $($Employee.UserName) does not exist"
             return         
        }
        else{
          Write-Warning "Username $($Employee.Username) will be removed!"
        }        

# Get the computer's description (which must be configured with the name of the username) and compare it with the username.
# if it does not match, throw error message, it it does, warn that computer account will be removed.
   
$computer = Get-ADComputer $($Employee.ComputerName) -Properties description             
  
  if($computer.description -match $Employee.UserName){
     Write-Warning "The computer $($Employee.ComputerName) matches with $($Employee.Username) and will be removed!`n"
  }
     else{
       Write-Error "ATTENTION: The description of $($Employee.ComputerName) does not match with username $($Employee.UserName)!`n"
       return
     }     
 } 
   # Catch errors and throw the script line which the error has occurred. 
   catch{
     Write-Error "$($_.Exception.Message) : - Line Number : $($_.InvocationInfo.ScriptLineNumber)"
   }             

# If everything went fine, remove the user and the computer account, a warn message will prompt to confirm the action.
# You might want to bypass this warning, if so, just add the [-confirm] parameter.     
     
   Remove-ADUser @UserParam  # -confirm
   Remove-ADComputer @ComputerParam # -confirm    
}
