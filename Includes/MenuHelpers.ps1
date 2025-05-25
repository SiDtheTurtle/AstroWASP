function Write-BackRow {
    param (
        [Parameter(Mandatory)][String]$DescriptionColumn
    )

    New-Object PsObject -Property @{ Index = "B"; ($DescriptionColumn) = "Back to main menu" }
}

function Read-MenuChoice {
    param (
        [Parameter(Mandatory)][string[]] $ValidChoices
    )
    
    $Prompt = "Select a menu option (" + ($ValidChoices -join ', ') + ")"
    $Choice = Read-Host -Prompt $Prompt

    if ($ValidChoices.Contains($Choice.ToUpper()) -eq $false) {
        Write-Host "Invalid selection, try again!"
        Read-MenuChoice -ValidChoices $ValidChoices
    }

    Return $Choice
}