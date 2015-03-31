#!/bin/bash

shred -u /etc/ssh/*_key /etc/ssh/*_key.pub
shred -u ~/.*history
shred -u ~/.ssh/authorized_keys 

touch /root/firstrun

