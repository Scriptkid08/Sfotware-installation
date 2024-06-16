    # Define a list of software to be installed
    $softwareList = @(
        "googlechrome",
        "git",
        "vscode"
        # Add more software names here
    )
 
    # Function to check if Chocolatey is installed
    function Install-Chocolatey {
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Write-Output "Chocolatey is not installed. Installing Chocolatey..."
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
            Write-Output "Chocolatey installed successfully."
        } else {
            Write-Output "Chocolatey is already installed."
        }
    }
 
    # Function to check if software is installed
    function Is-SoftwareInstalled {
        param(
            [string]$SoftwareName
        )
        try {
            # Check if the software is installed (assuming Chocolatey is used)
            $installedPackages = choco list --local-only
            return $installedPackages -match $SoftwareName
        } catch {
            Write-Error "Error checking if $SoftwareName is installed: $_"
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
                Write-Output "$SoftwareName is already installed on $vmName."
            } else {
                Write-Output "Installing $SoftwareName on $vmName"
                choco install $SoftwareName -y
                Write-Output "$SoftwareName installed successfully on $vmName"
            }
        } catch {
            Write-Error "Failed to install $SoftwareName $_"
        }
    }
 
    # Ensure Chocolatey is installed
    Install-Chocolatey
 
    # Iterate over each software and install it
    foreach ($software in $softwareList) {
        Install-Software -SoftwareName $software
    }
 
    Write-Output "Software installation completed successfully on $vmName"
