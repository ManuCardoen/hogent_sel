# Settings
$logfile = "log.txt"

$software = @() # lege array aanmaken

# Installatiedata

$software += [pscustomobject]@{
    Naam = "Adobe Acrobat"      
    Commando = "choco install acrobat -y"     
    Installeren = $true }
$software += [pscustomobject]@{
    Naam = "Visual Code"        
    Commando = "choco install vscode -y"
    Installeren = $true }

# Start uitvoering menu-script

do {
    Clear-Host
    Write-Host "Te installeren software" -ForegroundColor Blue
    Write-Host "-----------------------" -ForegroundColor Blue
    ""," 0: Installatie uitvoeren"
    
    0..($software.count - 1) | % {
        $menuindex = $_ + 1
        $outputstring = "$(if ($menuindex -lt 10) {" $menuindex"} else {"$menuindex"}): [$(if ($software[$_].Installeren) {"x"} else {" "})] - $($software[$_].Naam)"
        if ($software[$_].Installeren) {
            Write-Host $outputstring -ForegroundColor Green } else {
                Write-Host $outputstring -ForegroundColor Red }
    }

    ""

    $commando = Read-Host "Maak uw keuze"
    if ($commando -eq 0) { break; }
    if ((1..$software.count) -contains $commando) {
        $software[ ($commando - 1) ].Installeren = !$software[ ($commando - 1) ].Installeren
    }

} while ($true)

# Start installatie

choco upgrade chocolatey -y --log-file=$logfile
