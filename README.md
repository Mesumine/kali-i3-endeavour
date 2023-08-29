
Take your hacking to the next level with this highly efficient configuration for kali. This guide details how to get endeavourOS-like configurations onto kali. This is a pretty decent setup for hacking, as it allows moving and changing tiles (windows) from the keyboard.  

![alt text](https://github.com/mesumine/kali-i3-endeavour/blob/main/attachments/image.jpg?raw=true)
![[Kali with i3 - EndeavourOS themed._image_1.png]]

# Installation

## Download requirements

Clone this repository and then cd into the kali-i3-endeavour folder.

```
chmod +x install.sh 
./install.sh 
```

## Log in with i3.

In order to use i3, you'll need to logout. and then click the icon in the top right to choose i3. Then you can login again.

![[Kali with i3 - EndeavourOS themed._image_8.png]]

## Important notes about i3

## rofi

rofi powers a lot of menus in i3 to make it easier to find and open applications and to switch windows. 

windows + d - brings up the rofi dmenu, where you can start typing the name of an application and then select it to open it. 

windows + t - brings up the list of open tiles. This works the same as the dmenu.

There are other rofi menus and features, but those are the two you will use the most.


## Terminal

open a terminal with windows + Enter. 

## Bind key

the bind key in i3 is the windows key by default. This may cause issues if using with virtualization. There are two methods to address the problem if you plan to use this in a VM. 

- Grab keyboard input. There's usually an option in VM managers or remote desktops that allow the VM to grab keyboard input when it is focused. The following is the location in NoMachine.

![[Kali with i3 - EndeavourOS themed._image_9.png]]

- Change bind key to alt
in ~/.config/i3/config change

`set $mod Mod4`

to

`set $mod Mod1`

## Keybindings

A keybindings cheat sheet can be found in the ~/.config/i3/keybindings file.


## Tabbed, Stacked and fullscreen modes

Win + g = tabbed mode. The tiles will be put in a tab arrangement. They can still be navigated with mouse or with Win + (left|right)

Win + s = stacking mode. The tiles will stack on top of each other. They can still be navigated with mouse or with Win + (up|down)

win + e = split mode. To return to the default i3 split tile mode.

win  + f = fullscreen mode. To make a tile fill the screen and hide everything behind it. This is useful, but can be annoying when you forget that you are in it and try to open a new window or link.

## Workspaces

This configuration comes with 10 workspaces by default. The can be switched to by hitting win +(num) or by scrolling up and down on the bottom bar. You can move a tile to another workspace with win + shift + (num).

If you want to alias a command to automatically open and focus something on a new workspace, use the i3-msg command. The following alias in .zshrc will open a new workspace, label it with the  , and then focus the workspace. Custom icons can be found at https://fontawesome.com/v4/cheatsheet/

`alias word="i3-msg 'workspace ;exec --no-startup-id firefox http://docs.google.com focus"`


## Multiple Monitors and Display Settings

If you have multiple monitors, you need to configure them in xrandr. Arandr is a gui utility that allows you to do this in an easy way.

If you have two monitors plugged in, and only one is showing open arandr, and go to outputs and make sure that it is active.

Then you can drag the second monitor to where you want it and click apply. You can also change the resolution in arandr. Once everything is setup the way you want it, you can save the configuration as a bash script. 

If you place it in ~/.config/.screenlayout/monitor.sh, it will automatically be setup when you launch or refresh i3. You can change this location in the i3 config file.



# Manual install

If you want to change the configuration yourself, or to understand what this script does, here is what I did.


## Download requirements

`sudo apt install i3-wm i3blocks i3lock-fancy i3status xfce4-terminal rofi feh `

Optional packages that are used in this guide. 

- picom - for transparent terminals and windows
- flameshot - to take screenshots like a champion
- arandr - easily configure graphics settings for multiple monitors


## Copy EndeavourOS configs

`git clone https://github.com/endeavouros-team/endeavouros-i3wm-setup.git`
`cd endeavouros-i3wm-setup/.config`

`cp -r ./* ~/.config`

## .config/i3/config

1.) comment all the assign and focus blocks, remove the icons from workstations.
![[Kali with i3 - EndeavourOS themed._image_2.png]]

2.) comment the annoying firefox startup.

![[Kali with i3 - EndeavourOS themed._image_3.png]]

3.) Change wallpaper

Download a wallpaper change the line about wallpapers to:

`exec_always feh --bg-fill ~/.config/wallpaper`

4.) Flameshot

Change the line with "bindsym Print exec scrot ...." to:

`bindsym Print exec flameshot gui`


5.) Picom

If you want to use picom for transparent windows, add this to ~/.config/i3/config

`exec_always --no-startup-id picom --config ~/.config/picom.conf`

![[Kali with i3 - EndeavourOS themed._image_4.png]]


## .config/i3/i3blocks.conf

put the following wherever you want, but probably replace bandwidth2
```bash 
[tun0]
label=
command=~echo "tun0: $(ip -br a | grep eth0 | awk -F ' ' '{print substr($3, 1, length($3)-3)}')""
interval=5
```

comment out or delete the battery indicator and power-profile sections, unless you want them.


## Configure Scripts

`chmod +x ~/.config/i3/scripts/*`

### .config/i3/scripts/powermenu

Replace commented LOCKSCRIPT line with

`LOCKSCRIPT="i3lock-fancy"`

![[Kali with i3 - EndeavourOS themed._image_5.png]]

![[Kali with i3 - EndeavourOS themed._image_6.png]]
The location of the powermenu


## XFCE4-Terminal/ZSH


### ~/.config/xfce4/terminal/terminalrc

after you've moved the i3 xfce4/terminal files over, it will make the .zshrc terminal colors look bad because of the custom palette, as well as the bad font.

swap the values in terminalrc with the following

```
FontName=Monospace 10
ColorPallette=#000000;#cc0000;#4e9a06;#c4a000;#3465a4;#75507b;#06989a;#d3d7cf;#555753;#ef2929;#8ae234;#fce94f;#739fcf;#ad7fa8;#34e2e2;#eeeeec 
```

### ~/.zshrc

- prompt - The prompt will also look bad, because it is blue on the the dark purple from endeavour. I changed it to white and green. Alternatively you can install oh-my-zsh and pick a theme. I recommend backing up the kali .zshrc before installing oh-my-zsh.

Change the first `PROMPT=` in the configure_prompt function.

```zsh
            PROMPT=$'%F{%(#.white.green)}┌──${debian_chroot:+($debian_chroot)─}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))─}(%B%F{%(#.red.white)}%n'$prompt_symbol$'%m%b%F{%(#.white.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.white.green)}]\n└─%B%(#.%F{red}#.%F{green}$)%b%F{reset} '
```


- The kali .zshrc is really solid, but the short history needs to be taken care of. Extend the HISTSIZE and SAVEHIST to much larger values. 

![[Kali with i3 - EndeavourOS themed._image_7.png]]

## Transparent terminals with Picom

The following will change the transparency of terminals. They will be mostly opaque when focused and more transparent when they aren't. Copy the example.picom.conf from endeavouros-i3wm to ~/.config/picom.conf

add the following lines

```bash
#Custom rule for terminal
opacity-rule = [
  "98:class_g = 'Xfce4-terminal' && focused",
  "65:class_g = 'Xfce4-terminal' && !focused"
];
```

## Log in with i3.

In order to use i3, you'll need to logout. and then click the icon in the top right to choose i3. Then you can login again.

![[Kali with i3 - EndeavourOS themed._image_8.png]]


## Important notes

## rofi

rofi powers a lot of menus in i3 to make it easier to find and open applications and to switch windows. 

windows + d - brings up the rofi dmenu, where you can start typing the name of an application and then select it to open it. 

windows + t - brings up the list of open tiles. This works the same as the dmenu.

There are other rofi menus and features, but those are the two you will use the most.


## Terminal

open a terminal with windows + Enter. 
## Bind key

the bind key in i3 is the windows key by default. This may cause issues if using with virtualization. There are two methods to address the problem if you plan to use this in a VM. 

- Grab keyboard input. There's usually an option in VM managers or remote desktops that allow the VM to grab keyboard input when it is focused. The following is the location in NoMachine.

![[Kali with i3 - EndeavourOS themed._image_9.png]]

- Change bind key to alt
in ~/.config/i3/config change

`set $mod Mod4`

to

`set $mod Mod1`

## Keybindings

A keybindings cheat sheet can be found in the ~/.config/i3/keybindings file.


## Tabbed, Stacked and fullscreen modes

Win + g = tabbed mode. The tiles will be put in a tab arrangement. They can still be navigated with mouse or with Win + (left|right)

Win + s = stacking mode. The tiles will stack on top of each other. They can still be navigated with mouse or with Win + (up|down)

win + e = split mode. To return to the default i3 split tile mode.

win  + f = fullscreen mode. To make a tile fill the screen and hide everything behind it. This is useful, but can be annoying when you forget that you are in it and try to open a new window or link.

## Workspaces

This configuration comes with 10 workspaces by default. The can be switched to by hitting win +(num) or by scrolling up and down on the bottom bar. You can move a tile to another workspace with win + shift + (num).

If you want to alias a command to automatically open and focus something on a new workspace, use the i3-msg command. The following alias in .zshrc will open a new workspace, label it with the  , and then focus the workspace. Custom icons can be found at https://fontawesome.com/v4/cheatsheet/

`alias word="i3-msg 'workspace ;exec --no-startup-id firefox http://docs.google.com focus"`


## Multiple Monitors and Display Settings

If you have multiple monitors, you need to configure them in xrandr. Arandr is a gui utility that allows you to do this in an easy way.

If you have two monitors plugged in, and only one is showing open arandr, and go to outputs and make sure that it is active.

Then you can drag the second monitor to where you want it and click apply. You can also change the resolution in arandr. Once everything is setup the way you want it, you can save the configuration as a bash script. 

If you place it in ~/.config/.screenlayout/monitor.sh, it will automatically be setup when you launch or refresh i3. You can change this location in the i3 config file.
