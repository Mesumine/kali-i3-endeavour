#!/bin/bash

declare -a packages=( "i3-wm" "i3blocks" "i3lock-fancy" "i3status" "xfce4-terminal" "rofi" "feh" )
declare -a optional=( "picom" "flameshot" "neovim" "arandr" )
all=( "${packages[@]}" "${optional[@]}" )
selection=( "${packages[@]}" )
min=0
vm=0
mod=0
wp=0

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
    echo -e "-w             Configure wallpaper to change whenever a root terminal is focused." 
}


while getopts "habc:mvVw" opt; do 
    case ${opt} in 
        h) usage  && exit 1
        ;;
        a) 
            selection=( "${all[@]}" )
            wp=1
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
        w) wp=1
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
sudo mv /root/.zshrc /root/.zshrc.bak 
sudo cp zshrc /root/.zshrc 
curl https://r4.wallpaperflare.com/wallpaper/751/849/165/space-galaxy-universe-space-art-wallpaper-a930f8fd615aadabe667486f9001b64d.jpg --output ~/.config/wallpaper 

sudo mv /usr/bin/xfce4-terminal /opt/.xfce4-terminal.bak 
sudo tar xf xfce4-terminal.tar 
sudo cp xfce4-terminal /usr/bin/xfce4-terminal
sudo chmod +x xfce4-terminal 


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

if [[ "${selection[*]} " =~ "flameshot" ]]; then
    echo "rebinding Print key to flameshot"
    sed -i "s/bindsym Print.*/bindsym Print exec flameshot gui/" $HOME/.config/i3/config
fi 

## picom 
if [[ "${selection[*]} " =~ "picom" ]]; then
    echo "Setting up transparent terminals"
    mkdir $HOME/.config/picom 
    cp optional/picom.conf $HOME/.config/picom/picom.conf 
    sed -i '/picom.conf/s/^#//g' $HOME/.config/i3/config
fi 

if [ "$wp" -eq 1 ]; then

    pip3 install i3ipc

    sudo grep -q "class \"root\"" /root/.zshrc
    if [[ "$?" -eq 1 ]]; then
        echo "rootwp already insterted into /root/.zshrc"
        return 1
    else    
        cat optional/rootwp/rootshell.txt | sudo tee -a /root/.zshrc
        cp optional/rootwp/i3-watch.py $HOME/.config/i3/scripts/i3-watch.py
        echo "exec --no-startup-id python3 $HOME/.config/i3/scripts/i3-watch.py" >> $HOME/.config/i3/config
    fi 

    # update xfce4-terminal 
    sudo mv /usr/bin/xfce4-terminal /opt/.xfce4-terminal.bak 
    sudo tar xf optional/xfce4-terminal.tar --directory=/usr/bin/
    sudo chmod +x /usr/bin/xfce4-terminal 

    #get root wallpaper from wallpaperflare.
    curl https://r4.wallpaperflare.com/wallpaper/701/947/670/nebula-universe-red-nebula-sky-wallpaper-29b0484de1da4d8b4657483fe00116fd.jpg --output ~/.config/rootwallpaper 
fi 

echo -e "\n\n Configuration complete, please reboot your computer and select i3 at the lightdm login screen"
## nvim  
#if [[ "${selection[*]} " =~ "neovim" ]]; then
#    echo "Copying nvim configuration"
#    mkdir $HOME/.config/nvim 
#    cp -r optional/nvim/* $HOME/.config/nvim 
#fi 

