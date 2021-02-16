##### Guards

$errormsg = ""
$adminrechten = (New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

try { choco -v | out-null } catch { $errormsg = "Chocolatey is Not installed" }
if (!$adminrechten) { $errormsg = "Adminrechten zijn vereist om dit script uit te voeren" }

if ($errormsg) { Write-Host "ERROR: $errormsg" -ForeGroundColor Red ; exit }

##### Settings

$NonChocoInstallDir = "$pwd\Install_Files_Non_Chocolatey\"
$VPInstallDirectory = "C:\Program Files\Visual Paradigm 16.0\"

##### Softwarelijst

$software = @() + [pscustomobject]@{
    Naam 		= "Adobe Reader" ;	Installeren = $true ; 	Verificatie = "adobereader"
	Commando 	= {choco install adobereader -y}	}
	
$software += [pscustomobject]@{
    Naam 		= "Visual Code"	;	Installeren = $true	;	Verificatie = "Microsoft Visual Studio Code"
	Commando 	= {choco install vscode -y}    	}
	
$software += [pscustomobject]@{
	Naam		= "Firefox" ;		Installeren = $true ; 	Verificatie = "firefox"
	Commando	= {choco install firefox -y}	}

$software += [pscustomobject]@{
	Naam 		= "VLC Media Player"; Installeren = $true ; Verificatie = "vlc"
	Commando	= {choco install vlc -y}	}

$software += [pscustomobject]@{
	Naam		= "Github Desktop"; Installeren = $true ; Verificatie = "github-desktop"
	Commando 	= {choco install github-desktop -y}		}

$software += [pscustomobject]@{
	Naam		= "Visual Studio Code"; Installeren = $true ; Verificatie = "vscode"
	Commando	= {choco install vscode -y}		}

$software += [pscustomobject]@{
	Naam		= "FileZilla" ; Installeren = $true ; Verificatie = "filezilla"
	Commando 	= {choco install filezilla -y}		}

$software += [pscustomobject]@{
	Naam		= "VirtualBox" ; Installeren = $true ; Verificatie	= "virtualbox"
	Commando 	= {choco install virtualbox -y}		}

$software += [pscustomobject]@{
	Naam		= "MySQL workbench"; Installeren = $true ; Verificatie = "mysql.workbench"
	Commando 	= {choco install mysql.workbench -y}	}
	
$software += [pscustomobject]@{
	Naam 		= "Packet Tracer"
	Installeren = $False
	Verificatie = "Cisco Packet Tracer"	
	Commando 	= {	
		<# Start packet tracer installatiescript #>
		$startDir = pwd
	
		cd $NonChocoInstallDir
        if (test-path PacketTracer800_Build212_64bit_setup-signed.exe) {
			.\PacketTracer800_Build212_64bit_setup-signed.exe /VERYSILENT /NORESTART        		
        } else {
            "Installatiebestanden ontbreken in directory $NonChocoInstallDir"
		}

        cd $startDir
		<# Einde packet tracer installatiescript #> }	
	}
	
$software += [pscustomobject]@{
	Naam = "Visual Paradigm"
	Installeren = $False
	Verificatie = "Visual Paradigm" 
	Commando = { 	
			<# Start Visual Paradigm unattended installation #>
			$startDir = pwd
			
			cd $NonChocoInstallDir
			if (test-path .\Visual_Paradigm_16_2_20210201_Win64.exe) {
				.\Visual_Paradigm_16_2_20210201_Win64 -q -dir $VPInstallDirectory
				while (select-string "Visual_Paradigm" -inputobject ((get-process).name)) {
					Start-Sleep -Seconds 5
				}			
			} else {
				"Installatiebestanden ontbreken in directory $NonChocoInstallDir"				
			}
			
			cd $startDir
			<# Einde Visual Paradigm unattended installation #>	}
	}
				
##### Menu

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
		"$($software.Count + 1): Installatie annuleren"

    Write-Host ""
    $commando = Read-Host "Maak uw keuze"

    if ($commando -eq 0) { break; }
	if ($commando -eq $($software.count + 1)) { exit }
    if ((1..$software.count) -contains $commando) {
        $software[ ($commando - 1) ].Installeren = !$software[ ($commando - 1) ].Installeren
    }

} while ($true)

##### Installatie

foreach ($soft in $software) {
	if ($soft.Installeren) {
		Invoke-Command -ScriptBlock $soft.Commando		
    }
}

##### Verificatie

$InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" # local machine 
$InstalledSoftware += Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall" # current user
$registrypackages = $InstalledSoftWare | % {$_.getValue('DisplayName')} # enkel namen in lijst opnemen

$chocopackages = $(choco list -local)
$chocopackages = $chocopackages | ? {!($_ -match "packages installed.")} # weglaten melding "xx packages installed."

$installed = $registrypackages + $chocopackages

Clear-Host
Write-Host "Overzicht:" -ForegroundColor Yellow
Write-Host "----------" -ForegroundColor Yellow
"",""

foreach ($soft in $software) {	
	if ($soft.Installeren) {
		if (select-string $soft.Verificatie -InputObject $installed) { 
              Write-Host "$($soft.Naam): Software is geïnstalleerd" -ForegroundColor Green
        } else {
              Write-Host "$($soft.Naam): Software is NIET geïnstalleerd" -ForegroundColor Red
		}		
	}
}



