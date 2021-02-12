# github staat niet toe om bestanden > 100 MB up te loaden
# dus heb ik het bestand in 4 gedeeld
# dit commando re-assembleert het bestand
#    het duurt een paar minuten om uit te voeren en heeft weinig to geen nut behalve dat we zo de installatiebestanden en het script bij-een kunnen houden
#    als dit script in het echt gebruikt zou worden zouden de installatiebestanden natuurlijk meegeleverd worden op het installatiemedium of op een netwerkshare staan...


get-content .\part1.bin,.\part2.bin,.\part3.bin,.\part4.bin -Encoding Byte -ReadCount 1024 | set-content -Encoding Byte .\PacketTracer800_Build212_64bit_setup-signed.exe
