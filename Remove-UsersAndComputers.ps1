$Employees = Import-CSV -Path 'C:\users\Administrator\Documents\Powershell Scripts\remove_employees.csv'

  foreach($Employee in $Employees){
      $UserParam = @{
           'Identity' = $Employee.Username
      }
      $ComputerParam = @{
           'Identity' = $Employee.ComputerName
      }  
       
      try{    
        if(!(Get-ADUser $Employee.UserName)){
             Write-Error "Username $($Employee.UserName) does not exist"         
        }
        else
        {Write-Warning "Username $($Employee.Username) will be removed!"}
        
        $computer = Get-ADComputer $($Employee.ComputerName) -Properties description        
          if($computer.description -match $Employee.UserName){
           Write-Warning "The computer $($Employee.ComputerName) matches with $($Employee.Username) and will be removed!`n"
          }
           else
           {Write-Error "The computer $($Employee.ComputerName) does not exist!`n"}
        
      } catch{}
  
     Remove-ADUser @UserParam  
     Remove-ADComputer @ComputerParam        
}
