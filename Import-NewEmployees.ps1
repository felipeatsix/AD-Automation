#Admin Credential
$username = "$env:userdomain\Administrator"
$key = (1..16)
$password = Get-Content -Path \\ITFDC01\AppCenter\EncryptPass\SecurePass.txt | ConvertTo-SecureString -Key $key
$cred = New-Object -TypeName pscredential -ArgumentList (($username), ($password))

#Check Status
$CheckStatus = Test-Path "\\ITFDC01\AppCenter" -ErrorAction SilentlyContinue
switch ($CheckStatus) {
    "$true" {
        $status = 'ONLINE'
        $color = 'green'
    } 
    "$false" {
        $status = 'OFFLINE'
        $color = 'red'
    }
}

#Load Required .NET Assemblies     
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore, PresentationFramework

#Check AppCenter Register Key
If (!(Test-Path HKLM:\SOFTWARE\AppCenter)) {
    New-Item -Path HKLM:\SOFTWARE -Name AppCenter -ItemType Directory 
}

#Import Software Versions Data Base
$VersionDB_Field = Import-Csv -Path \\itfdc01\AppCenter\VersionDB\VersionDB_Field.CSV

#Prompt Information / Body,Title,Buttons,Icon
$ConfirmTitle = "Confirmar instalacao"
$SuccessTitle = "Instalado!"
$ConfirmButtons = [System.Windows.MessageBoxButton]::YesNo
$SuccessButtons = [System.Windows.MessageBoxButton]::OK
$ConfirmIcon = [System.Windows.MessageBoxImage]::Question
$SuccessIcon = [System.Windows.MessageBoxImage]::Information
$ConfirmBody = @("Tem certeza que deseja instalar o software")
$DefaultBody = @("Tem certeza que deseja instalar o software")
$SuccessBody = @("A aplicacao $success foi instalada com exito!")

#Software Directories
$FilePath = '\\ITFDC01\AppCenter\Softwares\Field'
$Softwares = gci '\\ITFDC01\AppCenter\Softwares\Field' | select Basename

#Font
$FontStatus = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$FontApplications = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$FontButton = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$FontListBox = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Regular)

#BackImage
$BackImage = [system.drawing.image]::FromFile('\\ITFDC01\AppCenter\Images\backimage.jpg') 

#Icon
$icon = '\\ITFDC01\AppCenter\Images\icon.ico'

#ListBox
$listBox = New-Object System.Windows.Forms.ListBox  
$listBox.location = New-Object System.Drawing.Point(20, 160)
$listBox.Size = New-Object System.Drawing.Size(200, 180) 
$listBox.Font = $FontListBox
foreach ($Software in $Softwares) {    
    if (!(Test-Path -Path HKLM:\SOFTWARE\AppCenter\$($Software.BaseName))) {
        [void] $listBox.Items.Add($($Software.BaseName))
    }
        else {
            foreach ($DBVersion in $VersionDB_Field) {
                if ($DBVersion.Software -match $($Software.BaseName)) {
                    $AppVersion = $DBVersion.Version
                }
        $RegVersion = Get-ItemProperty -Path HKLM:\SOFTWARE\AppCenter\$($Software.BaseName)
            if ($AppVersion -notmatch $RegVersion.Version) {
                [void] $listBox.Items.Add($($Software.BaseName))
            }
        }
    }
}

#InstallButton
$InstallButton = New-Object System.Windows.Forms.Button
$InstallButton.Location = New-Object System.Drawing.Point(250, 170)
$InstallButton.Size = New-Object System.Drawing.Size(120, 40)
$InstallButton.Text = "Instalar"
$InstallButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$InstallButton.BackColor = 'white'
$InstallButton.Font = $FontButton

#CancelButton
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(250, 220)
$CancelButton.Size = New-Object System.Drawing.Size(120, 40)
$CancelButton.Text = "Cancelar"
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$CancelButton.BackColor = 'white'
$CancelButton.Font = $FontButton

#Label Status
$LabelStatus = New-Object Windows.Forms.Label
$LabelStatus.location = New-Object System.Drawing.Point(252, 140)
$LabelStatus.Font = $FontStatus
$LabelStatus.Text = "STATUS: $status"
$LabelStatus.AutoSize = $true
$LabelStatus.Forecolor = "$color"
$LabelStatus.BackgroundImageLayout = 'None'

#Label Applications
$LabelApplications = New-Object Windows.Forms.Label
$LabelApplications.Location = New-Object System.Drawing.Point(20, 140)
$LabelApplications.Text = "Escolha uma aplicação:"
$LabelApplications.Font = $fontApplications
$LabelApplications.AutoSize = $true

#Label Style
$LabelStyle = New-Object Windows.Forms.Label
$LabelStyle.Location = New-Object System.Drawing.Point(0, 0)
$LabelStyle.Size = New-Object System.Drawing.Size(410, 5)
$LabelStyle.BackColor = "lightgreen"

#Label Style 2
$LabelStyle2 = New-Object Windows.Forms.Label
$LabelStyle2.Location = New-Object System.Drawing.Point(0, 122)
$LabelStyle2.Size = New-Object System.Drawing.Size(410, 5)
$LabelStyle2.BackColor = "lightgreen"

#Label BackGround
$LabelBackGround = New-Object Windows.Forms.Label
$LabelBackGround.Size = New-Object System.Drawing.Size(410, 125)
$LabelBackGround.Location = New-Object System.Drawing.Point(0, 0)
$LabelBackGround.BackgroundImage = $BackImage
 
#Form
$form = New-Object Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(410, 400)
$form.StartPosition = "CenterScreen"
$form.CancelButton = $CancelButton
$form.AcceptButton = $InstallButton
$Form.MaximizeBox = $false
$Form.ShowInTaskbar = $True
$form.Icon = $icon
$form.BackgroundImageLayout = 'None'
$form.Text = "AppCenter by Felipe Santos."
$Form.SizeGripStyle = 'Hide'
$Form.FormBorderStyle = 'Fixed3D'
$Form.BackColor = 'white'

#Controls 
$form.Controls.Add($listbox)
$form.Controls.Add($CancelButton)
$form.Controls.Add($InstallButton)
$form.Controls.Add($LabelStatus)
$form.Controls.Add($LabelApplications)
$form.Controls.Add($LabelStyle)
$form.Controls.Add($LabelStyle2)
$form.Controls.Add($LabelBackGround)

#Process
do {        
    $result = $form.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {        
        $App = $listBox.SelectedItem            
        $ConfirmBody += "$($App)?"
        $ConfirmAction = [System.Windows.MessageBox]::Show($ConfirmBody, $ConfirmTitle, $ConfirmButtons, $ConfirmIcon)           
        if ($ConfirmAction -eq 'Yes') {
            foreach ($DBVersion in $VersionDB_Field) {
                if ($DBVersion.Software -match $App) {
                    $AppVersion = $DBVersion.Version
                }
            }
            $install = Start-Process -FilePath "$FilePath\$app.exe" -Credential $cred -Wait -PassThru
            if ($install.ExitCode -eq 0) {
                $app += $success
                $SuccessMessage = [System.Windows.MessageBox]::Show($SuccessBody, $SuccessTitle, $SuccessButtons, $SuccessIcon)
                New-Item -Path HKLM:\SOFTWARE\AppCenter -Name $App -ItemType Directory -Force
                New-ItemProperty -Path HKLM:\SOFTWARE\AppCenter\$App -Name Version -PropertyType String -Value $AppVersion -Force
                [void] $listBox.Items.Remove("$($software.BaseName)")
            }                          
        }
        else {$ConfirmBody = $DefaultBody}
    }
}Until($result -eq [System.Windows.Forms.DialogResult]::Cancel)
