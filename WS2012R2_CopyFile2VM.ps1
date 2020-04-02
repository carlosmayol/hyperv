# Rel  0.1 Composed by Carlos Mayol (reusing code) :-)

#GOAL: Script que permita seleccionar un fichero y una VM al que se copia el fichero seleccionado

#Requisitos: Host Windows 8.1 o superior. VM con los ICs Actualizados y con el "Guest Service" habilitado en los Integration Services.

#Resources:

# http://vniklas.djungeln.se/2013/08/07/exploring-the-hyper-v-2012-r2-and-copy-vmfile-powershell-cmdlet/

#Usage: Lanzarlo con permisos elevados en la PS session /Hyper-V PS Module rules :-/ copiará en C:\


Set-StrictMode -version Latest

Clear-host


# Filling DropDown Values

$ICFilter = Get-VM | Get-VMIntegrationService -Name "Guest Service Interface" | where Enabled -eq $true | %{$_.Vmname}

[array]$DropDownArray = get-vm $ICFilter | where-object {($_.State -eq "Running")} | %{$_.Name}

# This Function Returns the Selected Value and Closes the Form

function Return-DropDown {

	$Choice = $DropDown.SelectedItem.ToString()
	$Form.Close()
	#Write-Host $Choice

}

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
#endregion

# START-SCRIPT

# Select file Section

$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.DefaultExt = '.ps1'
$dialog.Filter = 'All Files|*.*'
$dialog.FilterIndex = 0
$dialog.InitialDirectory = $env:COMPUTERNAME
$dialog.Multiselect = $false
$dialog.RestoreDirectory = $true
$dialog.Title = "Select a file"
$dialog.ValidateNames = $true
$dialog.ShowDialog()
$dialog.FileName

$SelectedFile = $dialog.FileName.ToString()
#write-host "FileName is" $selectedFile


#Select VM Section

$Form = New-Object System.Windows.Forms.Form

$Form.width = 300
$Form.height = 150
$Form.Text = ”Select your VM to Copy”

$DropDown = new-object System.Windows.Forms.ComboBox
$DropDown.Location = new-object System.Drawing.Size(100,10)
$DropDown.Size = new-object System.Drawing.Size(130,30)

ForEach ($Item in $DropDownArray) {
	$DropDown.Items.Add($Item)
}

$Form.Controls.Add($DropDown)

$DropDownLabel = new-object System.Windows.Forms.Label
$DropDownLabel.Location = new-object System.Drawing.Size(10,10) 
$DropDownLabel.size = new-object System.Drawing.Size(100,20) 
$DropDownLabel.Text = "Items"
$Form.Controls.Add($DropDownLabel)

$Button = new-object System.Windows.Forms.Button
$Button.Location = new-object System.Drawing.Size(100,50)
$Button.Size = new-object System.Drawing.Size(100,20)
$Button.Text = "Select an Item"
$Button.Add_Click({Return-DropDown})
$form.Controls.Add($Button)

$Form.Add_Shown({$Form.Activate()})
$Form.ShowDialog()

$SelectedVM = $DropDown.SelectedItem.ToString()



write-host ""
write-host ""
write-host "Selected VM is $SelectedVM and the file is $SelectedFile" -ForegroundColor Green



#Copy the Selected file to the selected VM

$CopytoVM = get-vm -Name $SelectedVM

Copy-VMFile -VM $CopytoVM -SourcePath "$selectedFile" -DestinationPath "C:\" -FileSource Host -CreateFullPath
