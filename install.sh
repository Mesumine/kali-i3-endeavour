#!/bin/bash

declare -a packages=( "i3-wm" "i3blocks" "i3lock-fancy" "i3status" "xfce4-terminal" "rofi" "feh" "xdotool" )
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

## update 
sudo apt update 
## Install packages
echo "${selection[@]}" |  xargs sudo apt-get install -qq -y

#parrot specific configuration

uname -a | grep parrot
if [ $? -eq 0 ]; then
    sudo apt-get install -qq -y zsh i3-gaps
    sudo chsh -s $(which zsh) root
fi 

## Basic Configuration
if [[ ! -f ~/.config.bak.tar ]]; then
	echo "backing up ~/.config to ~/.config.bak.tar"
	tar -czf .config.bak.tar $HOME/.config 
fi
cp -r config/* $HOME/.config/
if [[ ! -f ~/.config.bak.tar ]]; then
	sudo tar -czf /root/.config.bak.tar /root/.config  
sudo cp -r config/* /root/.config/
fi
chmod +x $HOME/.config/i3/scripts/*
mv $HOME/.zshrc $HOME/zshrc.bak
cp zshrc $HOME/.zshrc
sudo mv /root/.zshrc /root/.zshrc.bak 
sudo cp zshrc /root/.zshrc 
sudo cp -r config/xfce4/terminal/* /root/.config/xfce4/terminal 
curl https://r4.wallpaperflare.com/wallpaper/751/849/165/space-galaxy-universe-space-art-wallpaper-a930f8fd615aadabe667486f9001b64d.jpg --output ~/.config/wallpaper 


##vm Configuration
if [ "$vm" -eq 1 ]; then
    echo "making i3 configuration more VM friendly"

    echo "Changing i3 config to use 'mod+Shift+g' for tabbed mode"
    sed -i "s/mod+g/mod+Shift+g/g" $HOME/.config/i3/config 
    
    echo "Changing i3 config to use 'mod+Shift+l' for lock screen" 
    sed -i "s/mod+l/mod+Shift+l/g" $HOME/.config/i3/config
    
    echo "Changing i3 config to use 'mod+\`' for Printscreen/flameshot"
    sed -i "s/bindsym Print/bindsym \$mod+grave/g" $HOME/.config/i3/config
    echo "updating keybindings cheat sheet" 
    sed -i "s/+g/mod+Shift+g/g" $HOME/.config/i3/keybindings 
    sed -i "s/+l/mod+Shift+l/g" $HOME/.config/i3/keybindings 
    sed -i "s/bindsym Print/bindsym \$mod+\`/g" $HOME/.config/i3/keybindings
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
    sed -i "s/exec scrot.*/exec flameshot gui/" $HOME/.config/i3/config
fi 

## picom 
if [[ "${selection[*]} " =~ "picom" ]]; then
    echo "Setting up transparent terminals"
    mkdir $HOME/.config/picom 
    cp optional/picom.conf $HOME/.config/picom/picom.conf 
    #uncomment picom.conf line
    sed -i '/picom.conf/s/^#//g' $HOME/.config/i3/config
fi 

if [ "$wp" -eq 1 ]; then
    echo -e "\nConfiguring root wallpaper change on focus"
    pip3 install -q i3ipc

    sudo grep -q "role \"root\"" /root/.zshrc
    if [[ "$?" -eq 0 ]]; then
        echo "rootwp already insterted into /root/.zshrc"
        return 1
    else    
        cat optional/rootwp/rootshell.txt | sudo tee -a /root/.zshrc
        cp optional/rootwp/i3-watch.py $HOME/.config/i3/scripts/i3-watch.py
        chmod 775 $HOME/.config/i3/scripts/i3-watch.py 
        sudo chown root:root $HOME/.config/i3/scripts/i3-watch.py 
        
        echo "exec_always --no-startup-id python3 $HOME/.config/i3/scripts/i3-watch.py" >> $HOME/.config/i3/config
    fi 

    # update xfce4-terminal
    # xfce4-terminal no longer needs to be updated for this, since we can use the window_role instead of window_class. If you want, you can have an up to date xfce4-terminal on kali.
    #sudo mv /usr/bin/xfce4-terminal /opt/.xfce4-terminal.bak 
    #sudo tar xf optional/xfce4-terminal.tar --directory=/usr/bin/
    #sudo chmod +x /usr/bin/xfce4-terminal 

    #get root wallpaper from wallpaperflare.
    echo "getting rootwallpaper"
    sudo curl https://r4.wallpaperflare.com/wallpaper/701/947/670/nebula-universe-red-nebula-sky-wallpaper-29b0484de1da4d8b4657483fe00116fd.jpg --output /usr/share/rootwallpaper 
    sudo chmod 664 /usr/share/rootwallpaper
fi  

echo -e "\n\n Configuration complete, please reboot your computer and select i3 at the lightdm login screen"
## nvim  
#if [[ "${selection[*]} " =~ "neovim" ]]; then
#    echo "Copying nvim configuration"
#    mkdir $HOME/.config/nvim 
#    cp -r optional/nvim/* $HOME/.config/nvim 
#fi 

