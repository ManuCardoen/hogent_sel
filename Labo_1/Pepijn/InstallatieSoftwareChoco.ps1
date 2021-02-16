#Automatiseren software-installatie

Write-Host "Installatie Algemene Applicaties"
choco install -y git
choco install -y adobereader
choco install -y brave
choco install -y github-desktop
choco install -y vscode
choco install -y vlc

Write-Host "Software voor System Engineering Lab"
choco install -y filezilla
choco install -y virtualbox
choco install -y mysql.workbench

choco upgrade all