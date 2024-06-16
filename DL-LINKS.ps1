<# 
.SYNOPSIS
    Script to install Google Chrome, PuTTY, and Microsoft Visual Studio Code on a Windows machine.
 
.DESCRIPTION
    This script downloads and installs Google Chrome, PuTTY, and Microsoft Visual Studio Code using their respective download links. It validates the URLs before downloading, checks the installation status of each application, and skips installation if the application is already installed. All installations are performed silently without any UI interaction.
 
.PARAMETER None
    No parameters are required for this script.
 
.NOTES
    Date: 2024-06-15
 
#>
 
# Enable Strict Mode
Set-StrictMode -Version Latest
 
# Define the download URLs
$downloads = @{
    "GoogleChrome" = "https://dl.google.com/chrome/install/375.126/chrome_installer.exe"
    "PuTTY"        = "https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.76-installer.msi"
    "VSCode"       = "https://update.code.visualstudio.com/latest/win32-x64/stable"
    "WinSCP"       = "https://cdn.winscp.net/files/WinSCP-6.3.3-Setup.exe?secure=ezIzssNKFq22jx_4SenjLw==,1718449436"
}
 
# Define the local file paths for the downloads
$filePaths = @{
    "GoogleChrome" = "$env:TEMP\chrome_installer.exe"
    "PuTTY"        = "$env:TEMP\putty-64bit-0.76-installer.msi"
    "VSCode"       = "$env:TEMP\VSCodeSetup.exe"
    "WinSCP"       = "$env:TEMP\WinSCP-6.3.3-Setup.exe"
 
}
 
# Function to validate URL
function Validate-Url {
    param (
        [string]$url
    )
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}
 
# Function to download files
function Download-File {
    param (
        [string]$url,
        [string]$output
    )
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
}
 
# Function to install applications
function Install-Application {
    param (
        [string]$filePath,
        [string]$appName
    )
    $silentArgs = switch ($appName) {
        "GoogleChrome" { '/silent', '/install' }
        "PuTTY"        { '/quiet', '/norestart' }
        "VSCode"       { '/verysilent', '/mergetasks=!runcode' }
        default        { '/silent', '/norestart' }
    }
 
    if ($filePath -match "\.msi$") {
        $arguments = @("/i", $filePath) + $silentArgs
        Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait
    } else {
        Start-Process -FilePath $filePath -ArgumentList $silentArgs -NoNewWindow -Wait
    }
}
 
# Function to check installation status
function Check-Installation {
    param (
        [string]$appName
    )
    switch ($appName) {
        "GoogleChrome" { return Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe" }
        "PuTTY"        { return Test-Path "C:\Program Files\PuTTY\putty.exe" }
        "VSCode"       { return Test-Path "C:\Program Files\Microsoft VS Code\Code.exe" }
    }
}
 
# Check if each application is already installed before downloading
foreach ($app in $downloads.Keys) {
    if (Check-Installation -appName $app) {
        Write-Output "$app is already installed. Skipping download and installation."
    } else {
        if (Validate-Url -url $downloads[$app]) {
            Write-Output "Downloading $app..."
            Download-File -url $downloads[$app] -output $filePaths[$app]
            Write-Output "Installing $app..."
            Install-Application -filePath $filePaths[$app] -appName $app
            if (Check-Installation -appName $app) {
                Write-Output "$app has been installed successfully."
            } else {
                Write-Output "Failed to install $app."
            }
        } else {
            Write-Output "Invalid URL for ${app}: $($downloads[$app])"
        }
    }
}
 
# Clean up downloaded files
Remove-Item -Path $filePaths.Values -Force
 
Write-Output "Installation process completed."
