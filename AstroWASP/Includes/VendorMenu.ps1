. .\Includes\MenuHelpers.ps1
. .\Includes\DownloadHelpers.ps1

# Function to get the path to the vendors config folder, which contains a csv per-vendor
function Get-VendorsPath {
    return (Get-Location).path + "\Vendors\"
}

# Function to return the vendor-specific sub-menu, driven by the contents of the vendor csv file
function Write-VendorSubMenu {
    [Parameter(Mandatory=$true)][String]$FileName # Name of the vendor's CSV file
    
    #Clear the screen
    Clear-Host

    # Load the menu config file, sorted by index, wrap in @() in case the csv only have one row
    $Path = (Get-VendorsPath) + $FileName
    $VendorCSV = @(Import-CSV -Path $Path | Sort-Object -Property Index)

    # Add a return row

    $VendorCSV += Write-BackRow -DescriptionColumn "Description"

    # Save an array that stores the valid menu choices
    [Array]$ValidChoices = $VendorCSV.Index

    # Render the menu
    Write-Host ($VendorCSV | Format-Table -Property Index, Name, Description -Wrap -AutoSize | Out-String)

    # Prompt the user to make a menu choice and figure out the category they chose
    $Choice = Read-MenuChoice -ValidChoices $ValidChoices
    $ChoiceRow = $VendorCSV | Where-Object Index -eq $Choice
    
    # Install the chosen file or go back
    If ($Choice.ToUpper() -eq "B") {
        Write-VendorMenu
    }
    # Otherwise, the user has selected something to istall
    Else {
        Install-File -ChoiceRow $ChoiceRow
    }

    # Go back to the top of this function
    Write-VendorSubMenu($FileName)
}

# Main vendor menu function that returns an entry for every vendor CSV found
function Write-VendorMenu {
    Clear-Host

    # Get the menu entries by scanning the vendors folder for CSVs
    $Vendors = Get-ChildItem -Path (Get-VendorsPath) -Filter "*.csv" | Select-Object Name, BaseName, "Index" | Sort-Object -Property Name

    # Iterate through and add a unique index for each one
    $Index = 0
    $Vendors | ForEach-Object {
        $Index++
        $_.Index = $Index
    }

    # Add a return row
    $Vendors += Write-BackRow -DescriptionColumn "Name"

    # Save an array that stores the valid menu choices
    [Array]$ValidChoices = $Vendors.Index

    # Render the menu
    Write-Host ($Vendors | Format-Table -Property Index, @{Label='Vendor';Expression='BaseName'} -Wrap -AutoSize | Out-String)

    # Prompt the user to make a menu choice
    $Choice = Read-MenuChoice -ValidChoices $ValidChoices

    # Go to the chosen sub-menu or quit
    If ($Choice.ToUpper() -eq "B") {
        Write-MainMenu
    }
    # Otherwise, the user has selected a vendor
    Else {
        $FileName = $Vendors | Where-Object Index -eq $Choice | Select-Object -ExpandProperty Name
        Write-VendorSubMenu -FileName = $FileName
    }

    # Render the vendor menu again
    Write-VendorMenu
}
