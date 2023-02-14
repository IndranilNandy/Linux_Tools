#!/usr/bin/env bash

GNOME_TERMINAL_PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | awk -F \' '{print $2}')

for key in $(gsettings list-keys org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:"$GNOME_TERMINAL_PROFILE"/); do
    echo "key: $key"
    echo "$key: $(gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ $key)" >> temp.txt
done
