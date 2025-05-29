# Function that returns the location of the installers
function Get-InstallersPath {
    return (Get-Location).path + "\Installers\"
}

# Function to download and install a file, simply by running it- the file's own installer menu will then need to be driven by the user
function Install-File {
    param (
        [Parameter(Mandatory=$true)][Array]$ChoiceRow # Row from the installer menu that contains the download method, uri and filename
    )

    $InstallerMethod = $ChoiceRow | Select-Object -ExpandProperty Method # Set the method to download method, used in a a larger if statement in the Get-Installer function
    $InstallerUri = $ChoiceRow | Select-Object -ExpandProperty Uri # Set the uri of the installer
    $InstallerFileName = $ChoiceRow | Select-Object -ExpandProperty FileName # Set the target filename for the downloaded file
    $InstallerPath = Get-Installer -Uri $InstallerUri -File $InstallerFileName -Method $InstallerMethod # Run the Get-Installer function, which will return the location of the downloaded file

    # Run the downloaded file
    Start-Process $InstallerPath -NoNewWindow -Wait
}

# Main function to download a file, contains a large if statement with various methods to get to a file depending on where on the Internet it's hosted
function Get-Installer {
    param (
        [Parameter(Mandatory=$true)][string]$Uri,   # Uri to download
        [Parameter(Mandatory=$true)][string]$File,  # Target file name
        [Parameter(Mandatory=$true)][string]$Method # Method to download the file
    )

    # The installers folder might not exist, so create it
    if ((Test-Path -Path (Get-InstallersPath)) -eq $false) {
        New-Item -Path (Get-Location) -Name "Installers" -ItemType "Directory"
    }

    # Store the path to the target file, used to check it if exists
    $Path = (Get-InstallersPath) + $File
  
    # Do a check if the file exists to see if the user wants to redownload it, if so it will continue to the next code block, else exit the function with the path of the pre-existing file
    if (Test-Path -Path $Path) {
        $Choice = Read-Host "File already exists, (o)verwrite or (s)kip download"
        if ($Choice.ToUpper() -eq "O") {
            # Do nothing, download will overwrite file
        }
        elseif ($Choice.ToUpper() -eq "S") {
            # Return to parent function having not downloaded anything
            Return $Path
        }
        else {
            # Lazy, but assume if another value was entered, skip the download
            Return $Path
        }
    }

    # Main code block to download files
    # If statement branches cater to various websites

    # Basic method to download a file
    if ($Method -eq "Standard") {
        Invoke-WebRequest -Uri $Uri -OutFile $Path
    }
    # Method if the file is hosted in GitHub, first need to pull the latest release, then grab the first file
    elseif ($Method -eq "GitHub") {
        $GitUri = ((Invoke-WebRequest -Uri $Uri).Content | ConvertFrom-Json).assets[0].browser_download_url # Hacky, just picking first file in the list!
        Invoke-WebRequest -Uri $GitUri -OutFile $Path
    }
    # Method if the file is hosted in SourceForge, need to spoof the user agent to be 'Wget' to make it work
    elseif ($Method -eq "SourceForge") {
        Invoke-WebRequest -Uri $Uri -OutFile $Path -UserAgent "Wget"
    }
    # Method if the file is the Nina installer, first go to the downlaod page, find the download button and find its targer, then expand the archive downloaded and pull out the installer
    elseif ($Method -eq "Nina") {
        $NinaDownloadPage = Invoke-WebRequest -Uri $Uri
        $NinaDownloadPageHTML = $NinaDownloadPage.ParsedHtml
        $NinaDownloadUri = $NinaDownloadPageHTML.getElementsByClassName("download_button")[0].href
        Invoke-WebRequest -Uri $NinaDownloadUri -OutFile $Path
        Expand-Archive -Path $Path -DestinationPath (Get-InstallersPath) -Force
        $Path = (Get-InstallersPath) + "NINASetupBundle.exe"
    }
    # Catch all, if you end up here something's gone wrong!
    else {
        Write-Host "Unknown download method!"
        $Path = ""
        PAUSE
    }

    return $Path
}
