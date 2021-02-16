##### Settings

$logfile = "$pwd\log.txt"
$NonChocoInstallDir = "$pwd\Install_Files_Non_Chocolatey\"

##### Softwarelijst

$software = @() # lege array aanmaken

$software += [pscustomobject]@{
    Naam = "Adobe Acrobat"      
    Commando = {choco install acrobat -y}
    Installeren = $true     }
	
$software += [pscustomobject]@{
    Naam = "Visual Code"        
    Commando = {choco install vscode -y}
    Installeren = $true     }
	
$software += [pscustomobject]@{
	Naam = "Packet Tracer"
	Commando = {	<# Start packet tracer installatiescript #>
	
				$startDir = pwd
				cd $NonChocoInstallDir
                if (test-path PacketTracer800_Build212_64bit_setup-signed.exe) {
            		$packetTracerLog = $env:temp + (get-date -UFormat "%Y_%m_%d_%H_%M_%S_%s").replace(',','') + ".txt"  # Gegarandeerd unieke filename voor geval meerdere installaties werden / worden uitgevoerd
        		.\PacketTracer800_Build212_64bit_setup-signed.exe /VERYSILENT /NORESTART /LOG="$packetTracerLog"
        		move $packetTracerLog . 
        		$InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" # local machine 
        		$InstalledSoftware += Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall" # current user
        		if ($InstalledSoftware | Foreach-Object {$_.getValue('DisplayName')} | Where-Object {$_ -match "Cisco" }) {
                            Write-Host "Installation succesful" -ForegroundColor Green
                        } else {
                            Write-Host "Installation failed" -ForegroundColor Red}		
                } else {
                    "Gelieve het script 'assemble.ps1' uit te voeren in de map $NonChocoInstallDir om de packet tracer installer te assembleren"
                }
                cd $startDir

					<# Einde packet tracer installatiescript #> }
	Installeren = $True     }
	
# Start uitvoering menu-script

do {
    Clear-Host
    Write-Host "Te installeren software" -ForegroundColor Blue
    Write-Host "-----------------------" -ForegroundColor Blue
    Write-Host "", "0: Installatie uitvoeren: $(($software.Installeren -eq $true).Count) items"
    
    0..($software.count - 1) | foreach-Object {

        $menuindex = $_ + 1
        $outputstring = "" +  
            $(if ($menuindex -lt 10) {" $menuindex"} else {"$menuindex"}) +
            ": [" +
            $(if ($software[$_].Installeren) {"x"} else {" "}) +
            "] - " +
            $software[$_].Naam
        if ($software[$_].Installeren) {
            Write-Host $outputstring -ForegroundColor Green 
        } else {
            Write-Host $outputstring -ForegroundColor Red 
        }
    }

    Write-Host ""
    $commando = Read-Host "Maak uw keuze"

    if ($commando -eq 0) { break; }
    if ((1..$software.count) -contains $commando) {
        $software[ ($commando - 1) ].Installeren = !$software[ ($commando - 1) ].Installeren
    }

} while ($true)

# Start installatie


# TODO :logging. Voor elke installatie de logbestanden aanmaken (via -log switch voor choco en via de /LOG=x switch voor packet tracer
#       nadien de logging allemaal centraliseren naar het bestand dat geconfigureerd werd door gebruiker bovenaan het script, met telkens
#       er ook bij vermeld welke software we net (probeerden) te installeren
#   
# plus eventueel een mechanisme om oude logfiles te wissen, of om een overzicht te tonen aan de gebruiker of installaties gelukt zijn...
# (wordt al getoond bij packet tracer - zelfde mechanisme kan hier gedaan worden via registry query + opzoeken of naam software voor komt hierin)

foreach ($soft in $software) {
	if ($soft.Installeren) {
		Invoke-Command -ScriptBlock $soft.Commando
	}
}
