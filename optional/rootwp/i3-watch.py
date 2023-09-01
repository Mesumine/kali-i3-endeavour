
#!/usr/bin/env python3

import i3ipc

def on(i3, e):
    if e.container.window_class in ['root']:
        e.container.command('exec sudo feh --bg-fill /usr/share/rootwallpaper')
    else:
        e.container.command('exec feh --bg-fill ~/.config/wallpaper')
i3 = i3ipc.Connection()
i3.on('window::focus', on)
try:
    i3.main()
finally:
    i3.main_quit()

