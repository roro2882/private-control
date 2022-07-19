#!/bin/sh

udev_workarounds() {
    if [ "$SETSID" != "1" ]
    then
        SETSID=1 setsid "$0" "$@" &
        exit
    fi

    # udev might call twice
    mkdir /tmp/MiniClock || exit
}

# nickel stuff
wait_for_nickel() {
    while ! pidof nickel || ! grep /mnt/onboard /proc/mounts
    do
      	sleep 5
    done
}

udev_workarounds
wait_for_nickel

echo restart >> /root/log.txt
/root/kobocontrol.sh >> /root/log.txt 2>&1
echo stop >> /root/log.txt
