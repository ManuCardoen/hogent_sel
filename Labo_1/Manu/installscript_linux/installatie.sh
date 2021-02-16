#!/bin/bash

declare -a names=("gitKraken" "Visual Studio Code" "VLC" "FileZilla" "VirtualBox" "mySQL workbench")
declare -a commands=("yay -S gitkraken" "sudo pacman -S vscode --noconfirm" "sudo pacman -S vlc --noconfirm" "sudo pacman -S filezilla --noconfirm" "sudo pacman -S virtualBox --noconfirm" "sudo pacman -S mysql-workbench --noconfirm")
declare -a toggles=("true" "true" "true" "true" "true" "true")
amount=${#names[@]}

installatie() {
	for (( i=0; i<$amount; i++));
	do
		if [[ "${toggles[$i]}" == "true" ]]; then
			echo -e "\e[36minstallatie ${names[$i]}\e[0m"
			echo "------------------------------------------------------------"
			${commands[$i]} > /dev/null
		fi
	done
}

show_item() {
	if [[ "${2}" == "true" ]]; then
		echo -e "${1}. \e[32m[X] ${3}\e[0m"
	else
		echo -e "${1}. \e[31m[ ] ${3}\e[0m"
	fi
}

show_menu() {
	clear
	echo -e "\e[36mMENU:"
	echo -e "----- \e[0m"
	echo "0. Installatie starten"
	for (( i=1; i<${amount}+1; i++ ));
		do
		show_item "$i" "${toggles[$i-1]}" "${names[$i-1]}"
	done
	echo "$((amount+1)). Annuleren"
}

read_options() {
	local choice
	read -p "Enter choice [0..$((amount+1))] " choice
	if [[ $choice -le 0 ]]; then
		installatie
		exit 0;
	fi
	if [[ $choice -ge $amount+1 ]]; then
		exit 0;
	fi
	if [[ "${toggles[$choice-1]}" == "false" ]]; then
		toggles[$choice-1]="true"
	else
		toggles[$choice-1]="false"
	fi
}

while true
do
	show_menu
	read_options
done


