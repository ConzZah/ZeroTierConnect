#!/bin/bash
#====================================
#project: zerotier-connect_v0.3     #
#by: ConzZah			    #
#LAST CHANGE: @ 15.03.2024 / 11:20  #
#====================================
echo "   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "   *  ZEROTIER-CONNECT_v0.3   *"
echo "   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "     *=======ConzZah=======*"
echo ""; echo ""
cd /home/$USER/Documents #cd to working dir
#1 checks if save.txt exist, if not, prompts user to input network id
if [ ! -f /home/$USER/Documents/save.txt ]; then echo "no savefile was found. input network id to create one:"
   read saved_id #gets user input
   echo "$saved_id" > save.txt #writes user input to file
fi
saved_id=$(<save.txt) #assigns content of save.txt to variable saved_id
#2 Start Screen
echo " input network id or use savefile:"
echo "=================================="
select iue in "input network id" "use savefile" "exit"; do
    case $iue in
        "input network id" ) echo "input network id"; read input_id; echo "~~~~~~~~~~~~~"; sudo zerotier-cli join $input_id; echo "~~~~~~~~~~~~~"; break;;
	"use savefile" ) echo "~~~~~~~~~~~~~"; sudo zerotier-cli join $saved_id; input_id=$saved_id; echo "~~~~~~~~~~~~~"; break;;
	"exit" ) echo "exiting.."; exit;;
    esac
done
echo "~~~~~~~~~~~~~~~~" 
echo "connected to:"; echo "$input_id"; echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
sudo zerotier-cli status; echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
#3 Control Panel
echo ""; echo "Control Panel"; echo "=============";
select jlsde in "join another network" "list all networks" "show client info" "disconnect" "exit"; do
    case $jlsde in
        "join another network" ) unset $input_id; clear; echo "input network id"; read input_id; echo "~~~~~~~~~~~~~"; sudo zerotier-cli join $input_id; echo "~~~~~~~~~~~~~"; echo ""; echo "connected to: $input_id";;
	"list all networks" ) sudo zerotier-cli listnetworks;;
	"show client info" ) sudo zerotier-cli info;;
        "disconnect" ) echo "~~~~~~~~~~~~~"; sudo zerotier-cli leave $input_id; echo "~~~~~~~~~~~~~"; sleep 3;;
	"exit" ) echo "exiting.."; exit;;
    esac
done
