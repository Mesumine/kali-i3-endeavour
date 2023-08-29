#!/bin/bash

sudo apt install -y i3-wm i3blocks i3lock-fancy i3status xfce4-terminal rofi feh picom flameshot arandr

tar -czf .config.bak ~/.config 

cp -r config/* ~/.config/

chmod +x ~/.config/i3/scripts/*
mv ~/.zshrc ~/zshrc.bak
cp zshrc ~/.zshrc 



