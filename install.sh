#!/bin/bash

declare -a packages=( "i3-wm" "i3blocks" "i3lock-fancy" "i3status" "xfce4-terminal" "rofi" "feh" )
declare -a optional=( "picom" "flameshot" "neovim" "arandr" )
all=( "${packages[@]}" "${optional[@]}" )
selection=( "${packages[@]}" )
min=0
vm=0
mod=0

usage()
{
    echo "Please select some options" 
    echo -e "Usage:\n'./install.sh -a'\t\t to install all optional programs, aimed at full installation"
    echo -e "'./install.sh -m -v' \t\t to install only required programs, aimed at Virtual machine"
    echo -e "'./install.sh -c list.txt -v -b'\t to install optional programs from list, aimed at VM, with Alt as bind key"
    echo -e "\n\nThe optional programs are:"
    echo -e "Flameshot:\t a screen capture tool that can grab sections of the screen and edit on the fly."
    echo -e "neovim:\t hyperextensible Vim-based editor."
    echo -e "picom:\t a lightweight compositor for x11. Will be used for transparent terminals"
    echo -e "arandr:\t gui interface for xrandr. used for changing display settings\n\n"
    echo -e "-a             Install and configure all optional packages."
    echo -e "-m             Install and configure only the required packages."
    echo -e "-b             Change bind key from Windows to Alt."
    echo -e "-c <list.txt>  Install and configure the packages in the list in addition to the required packages."
    echo -e "-v             Configure towards VM. change $mod+g to $mod+Shift+g. change $mod+l to $mod+Shift+l"
    echo -e "-h             Print help."


}


while getopts "habc:mvV" opt; do 
    case ${opt} in 
        h) usage  && exit 1
        ;;
        a) 
            selection=( "${all[@]}" )
        ;;
        b) 
            mod=1
        ;;
        c)  
            while read package; do
                if [[ "${all[*]} " =~ "${package}" ]]; then
                    selection+=("$package") 
                else
                    echo -e "package: $package is not valid!"
                fi
           done < "${OPTARG}"
        ;;
        m) min=1
        ;;
        v) vm=1
        ;;
        \?) usage && exit 1
        ;;
        \:) usage && exit 1 
        ;;
    esac
done


## Install packages


echo "${selection[@]}" |  xargs sudo apt-get install -y


## Basic Configuration
tar -czf .config.bak $HOME/.config 
cp -r config/* $HOME/.config/
chmod +x $HOME/.config/i3/scripts/*
mv $HOME/.zshrc $HOME/zshrc.bak
cp zshrc $HOME/.zshrc 

##vm Configuration
if [ "$vm" -eq 1 ]; then
    echo "making i3 configuration more VM friendly"
    sed -i "s/mod+g/mod+Shift+g/g" $HOME/.config/i3/config 
    sed -i "s/mod+l/mod+Shift+l/g" $HOME/.config/i3/config 
    echo "Changing i3 config to use 'mod+Shift+g' for tabbed mode"
    sed -i "s/+g/mod+Shift+g/g" $HOME/.config/i3/keybindings 
    sed -i "s/+l/mod+Shift+l/g" $HOME/.config/i3/keybindings 
    echo "Changing i3 config to use 'mod+Shift+l' for lock screen" 
fi 

## alt bindkey
if [ "$mod" -eq 1 ]; then
    echo "Changing mod key to Alt"
    sed -i "s/Mod4/Mod1/g" $HOME/.config/i3/config 
    sed -i "s/windows key/alt key/g" $HOME/.config/i3/keybindings
fi 
#flameshot

if [[ "${selection[*]} " =$HOME "flameshot" ]]; then
    echo "rebinding Print key to flameshot"
    sed -i "s/bindsym Print.*/bindsym Print exec flameshot gui"
fi 

## picom 
if [[ "${selection[*]} " =$HOME "picom" ]]; then
    echo "Setting up transparent terminals"
    mkdir $HOME/.config/picom 
    cp optional/picom.conf $HOME/.config/picom/picom.conf 
    sed -i '/picom.conf/s/^#//g' $HOME/.config/i3/config
fi 


## nvim  
if [[ "${selection[*]} " =$HOME "nvim" ]]; then
    echo "Copying nvim configuration"
    mkdir $HOME/.config/nvim 
    cp -r optional/nvim/* $HOME/.config/nvim 
fi 

