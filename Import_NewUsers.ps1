# . 'path\to\New_Employee.ps1' 
# $Employees = Import-CSV -Path 'path\to\csv_file.csv'

# Don't forget to erase the '#' in the lines above after editing the paths.

foreach($Employee in $Employees){
    try {
    # Create the AD user accounts
    $NewUserParams = @{
        'FirstName' = $Employee.FirstName
        'MiddleName' = $Employee.MiddleName        
        'LastName' = $Employee.LastName
        'Title' = $Employee.Title
        'Group' = $Employee.Group
    }
    if($Employee.Location){
       $NewUserParams.Location = $Employee.Location
    }
    # Grab the username created to use for Set-MyAdUser
    $username = NewADUser @NewUserParams

    # Create the employee's AD computer account
    NewADcomputer -computername $Employee.ComputerName
    
    # Set The description for the employee's computer account
    Set-MyADcomputer -computername $Employee.ComputerName -Attributes @{
    'Description' = "$($Employee.FirstName) $($Employee.Lastname)'s computer"
    }
    
    #Set the department the employee is in
    Set-MyAdUser -username $username -attributes @{
    'Department' = $Employee.Department
    }
         
 } catch{
      Write-Error "$($_.Execption.Message) - Line Number : $($_.InvocationInfo.ScriptLineNumber)"
      }
} 
