#!/bin/bash

pip3 install i3ipc
sudo cat rootshell.txt >> /root/.zshrc
cp i3-watch.py $HOME/.config/i3/scripts/i3-watch.py
chmod $HOME/.config/i3/scripts/i3-watch.py

echo "exec --no-startup-id python3 $HOME/.config/i3/scripts/i3-watch.py" >> $HOME/.config/i3/config

#get root wallpaper from wallpaperflare.
curl https://r4.wallpaperflare.com/wallpaper/701/947/670/nebula-universe-red-nebula-sky-wallpaper-29b0484de1da4d8b4657483fe00116fd.jpg --output ~/.config/rootwallpaper 




