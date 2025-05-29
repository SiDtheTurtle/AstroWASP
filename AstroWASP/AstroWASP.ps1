#Requires -RunAsAdministrator

##############################################
# Astro WASP                                 #
#                                            #
# W.indows                                   #
# A.strophotography                          #
# S.etup                                     #
# P.rogramme                                 #
#                                            #
# Kieran Seeburn                             #
# https://github.com/SiDtheTurtle/AstroWASP  #
##############################################

. .\Includes\MenuHelpers.ps1
. .\Includes\TweaksMenu.ps1
. .\Includes\VendorMenu.ps1
. .\Includes\DownloadHelpers.ps1

# Function to get the path of the config folder which stores the menu entries
function Get-ConfigPath {
    return (Get-Location).path + "\Config\"
}

function Write-MainMenu {
    #Clear the screen
    Clear-Host

    # Load the menu config file, sorted by index
    $FileName = (Get-ConfigPath) + "CoreMenu.csv"
    $MenuCSV = Import-CSV -Path $FileName | Sort-Object -Property Index

    # Add a quit row
    $ExitRow = New-Object PsObject -Property @{ Index = "X"; Category = "Exit"; Description = "Exit this app" }
    $MenuCSV += $ExitRow

    # Save an array that stores the valid menu choices
    [Array]$ValidChoices = $MenuCSV.Index

    # Render the menu
    Write-Host ($MenuCSV | Format-Table -Property Index, Category, Description -Wrap -AutoSize | Out-String)

    # Prompt the user to make a menu choice and figure out the category they chose
    $Choice = Read-MenuChoice -ValidChoices $ValidChoices
    $ChoiceRow = $MenuCSV | Where-Object Index -eq $Choice
    $Category =  $ChoiceRow | Select-Object -ExpandProperty Category
    
    # Go to the chosen sub-menu or quit
    If ($Category -eq "Tweaks") {
        Write-TweaksMenu      
    }
    Elseif ($Category -eq "Vendor Drivers") {
        Write-VendorMenu
    }
    Elseif ($Category -eq "Exit") {
        Clear-Host
        Write-Host "Clear skies!"
        Exit
    }
    Else {
        Install-File -ChoiceRow $ChoiceRow
    }

    Write-MainMenu

}

Clear-Host
Write-MainMenu
