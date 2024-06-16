<#
.SYNOPSIS
    Software Installer GUI using PowerShell and Chocolatey.
.DESCRIPTION
    This script creates a Windows Form-based GUI for selecting and installing software using Chocolatey.
.PARAMETER None
.EXAMPLE
    Run the script to open the software installer GUI.
.NOTES
    Date: 2024-06-16
#>


# Import the necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
 
# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Software Installer"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"
 
# Create a list box for software selection
$listBox = New-Object System.Windows.Forms.CheckedListBox
$listBox.Location = New-Object System.Drawing.Point(20, 20)
$listBox.Size = New-Object System.Drawing.Size(340, 150)
$listBox.Items.AddRange(@("googlechrome", "git", "vscode"))
$form.Controls.Add($listBox)
 
# Create a button to install selected software
$installButton = New-Object System.Windows.Forms.Button
$installButton.Location = New-Object System.Drawing.Point(20, 180)
$installButton.Size = New-Object System.Drawing.Size(100, 30)
$installButton.Text = "Install"
$form.Controls.Add($installButton)
 
# Create a text box to show the output
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(20, 220)
$outputBox.Size = New-Object System.Drawing.Size(340, 20)
$outputBox.ReadOnly = $true
$form.Controls.Add($outputBox)
 
# Function to install Chocolatey
function Install-Chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        $outputBox.AppendText("Chocolatey is not installed. Installing Chocolatey...`n")
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        $outputBox.AppendText("Chocolatey installed successfully.`n")
    } else {
        $outputBox.AppendText("Chocolatey is already installed.`n")
    }
}
 
# Function to check if software is installed
function Is-SoftwareInstalled {
    param(
        [string]$SoftwareName
    )
    try {
        $installedPackages = choco list --local-only
        return $installedPackages -match $SoftwareName
    } catch {
        $outputBox.AppendText("Error checking if $SoftwareName is installed: $_`n")
        return $false
    }
}
 
# Function to install software
function Install-Software {
    param(
        [string]$SoftwareName
    )
    try {
        if (Is-SoftwareInstalled -SoftwareName $SoftwareName) {
            $outputBox.AppendText("$SoftwareName is already installed.`n")
        } else {
            $outputBox.AppendText("Installing $SoftwareName...`n")
            choco install $SoftwareName -y
            $outputBox.AppendText("$SoftwareName installed successfully.`n")
        }
    } catch {
        $outputBox.AppendText("Failed to install $SoftwareName: $_`n")
    }
}
 
# Button click event handler
$installButton.Add_Click({
    Install-Chocolatey
    foreach ($itemChecked in $listBox.CheckedItems) {
        Install-Software -SoftwareName $itemChecked
    }
    $outputBox.AppendText("Software installation completed successfully.`n")
})
 
# Show the form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
