. .\Includes\MenuHelpers.ps1

# Function to flip a registry key between two values, usually on and off
function Set-BooleanRegistryValue {
    param (
        [Parameter(Mandatory)][string] $Path,         # Registry Path
        [Parameter(Mandatory)][string] $Name,         # Registry Key Name
        [Parameter(Mandatory)][string] $EnabledValue, # Value if the key is set to enabled
        [Parameter(Mandatory)][string] $DisabledValue # Value if the key is set to disabled
    )

    # Get the current value, ignore errors so it'll be blank if the registry key doesn't exist, which will allow the creation of a new key later
    $CurrentValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $Name

    # If the current key value is the enabled value, flip it to the disabled value
    If ($CurrentValue -eq $EnabledValue) {
        Set-ItemProperty -Path $Path -Name $Name -Value $DisabledValue
    }
    # If the current key value is the disabled value, flip it to the enabled value
    Elseif ($CurrentValue -eq $DisabledValue) {
        Set-ItemProperty -Path $Path -Name $Name -Value $EnabledValue
    }
    # If the current key value is null, create the key instead
    Else {
        New-ItemProperty -Path $Path -Name $Name -Value $EnabledValue -PropertyType DWORD
    }
}

# Function to create the registry tweaks menu
function Write-TweaksMenu {
    #Clear the screen
    Clear-Host

    # Load the menu config file, sorted by Index
    $FileName = (Get-ConfigPath) + "CoreTweaks.csv"
    $MenuCSV = Import-CSV -Path $FileName | Sort-Object -Property Index

    # Add a column to return the current registry entry status
    $MenuCSV = $MenuCSV | Select-Object *, "Enabled"
    
    # Add the current registry status for each row
    $MenuCSV | ForEach-Object {

        #Query the registry
        $RegValue = Get-ItemProperty -Path $_.Path -Name $_.Name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $_.Name
       
        # Write a human-readable description on whether the value is set or not
        If ($RegValue -eq $_.EnabledValue) {
            $Enabled = "Yes"
        }
        Elseif ($RegValue -eq $_.DisabledValue) {
            $Enabled = "No"
        }
        Else {
            $Enabled = "[Key not found]"
        }

        # Write the entry to the row
        $_.Enabled = $Enabled
    }
 
    # Add a return row
    $MenuCSV += Write-BackRow -DescriptionColumn "Description"

    # Save an array that stores the valid menu choices
    [Array]$ValidChoices = $MenuCSV.Index

    # Render the menu
    Write-Host ($MenuCSV | Format-Table -Property Index, Description, Notes, Enabled -Wrap -AutoSize | Out-String)

    # Prompt the user to make a menu choice
    $Choice = Read-MenuChoice -ValidChoices $ValidChoices

    # Go to the chosen sub-menu or quit
    If ($Choice.ToUpper() -eq "B") {
        Write-MainMenu
    }
    # Otherwise, the user has selected a registry change option
    Else {
        # Get the parameters needed to change the registry entry
        $RegPath = [String]($MenuCSV | Where-Object Index -eq $Choice | Select-Object -ExpandProperty Path)
        $RegName =  [String]($MenuCSV | Where-Object Index -eq $Choice | Select-Object -ExpandProperty Name)
        $RegEnabledValue = [String]($MenuCSV | Where-Object Index -eq $Choice | Select-Object -ExpandProperty EnabledValue)
        $RegDisabledValue = [String]($MenuCSV | Where-Object Index -eq $Choice | Select-Object -ExpandProperty DisabledValue)

        # Call custom function to flip the registry entry
        Set-BooleanRegistryValue -Path $RegPath -Name $RegName -EnabledValue $RegEnabledValue -DisabledValue $RegDisabledValue
    }

    # Render the tweak menu again
    Write-TweaksMenu
}