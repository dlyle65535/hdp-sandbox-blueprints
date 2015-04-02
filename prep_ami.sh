#!/bin/bash

shred -u /etc/ssh/*_key /etc/ssh/*_key.pub
shred -u ~/.*history
shred -u ~/.ssh/authorized_keys
shred -u /var/log/wtmp
shred -u /var/log/btmp
shred -u /var/log/lastlog

touch /root/firstrun

history -c
