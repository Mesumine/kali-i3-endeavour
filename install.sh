#!/bin/bash

sudo apt install -y i3-wm i3blocks i3lock-fancy i3status xfce4-terminal rofi feh picom flameshot arandr
cp -r .config/* ~/.config/
mv ~/.zshrc ~/zshrc.bak
mv .zshrc ~/.zshrc 



