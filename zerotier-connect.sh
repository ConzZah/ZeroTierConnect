#!/bin/bash
#====================================
# Project: zerotier-connect_v0.4    #
# Author:  ConzZah	            #
#====================================
clear; #echo "[ LAST CHANGE @ 22.03.2024 / 02:56 ]"; echo ""
echo ".:*======= ConzZah's =======*:."
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " *  ZEROTIER-CONNECT_v0.4   *"
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""; echo ""
#1 (initial run only) checks if genesis[index].txt exists - if this file isn't present the script prompts the user to input a network name and network id to create the save.
if [ ! -f /home/$USER/Documents/ZeroTier-Connect_Save/genesis[index].txt ]; then echo "[ .:no savedata found:. ]"; echo "" 
   echo "[ ~~~ type the name of the network you'd like to connect to ~~~ ]"
   cd /; cd /home/$USER/Documents; mkdir ZeroTier-Connect_Save; cd ZeroTier-Connect_Save # <-- creates save folder and cd's to its location
   read saved_name # <-- gets user input (for network name)
   echo $saved_name >> genesis[index].txt # <-- appends network name to genesis
   echo "[ ~~~ paste the network-id ~~~ ]"; read saved_id # <-- gets user input (for network id)
   echo "$saved_id" > $saved_name.txt # <-- writes actual save, (as in: TheNetworkNameYouChoose.txt)
   echo ""; echo "[ .:save created:. ]"; echo "";
fi # <-- (end of initial run part)
cd /; cd home/$USER/Documents/; cd ZeroTier-Connect_Save # <-- cd's to save directory
#2 Main Menu Screen
echo "[ ~~~ CHOOSE WHAT TO DO ~~~ ]"
echo "====================================="
select icccce in "input network id manually" "connect via savefile" "create new savefile" "check client info" "check currently connected networks" "exit"; do
    case $icccce in
    "input network id manually" ) clear; echo "// input network id manually"; echo ""; echo "[ ~~~ paste the network-id ~~~ ]"; read input_id; echo "~~~~~~~~~~~~~"; sudo zerotier-cli join $input_id; echo "~~~~~~~~~~~~~"; continue;;
	"connect via savefile" ) clear; echo "// connect via savefile"; echo ""; echo "[ .:checking save file:.. ]"; echo ""; echo "~~~~~~~~~~~~~~~~"; cat genesis[index].txt; echo "~~~~~~~~~~~~~~~~"; echo "[ ~~~ type the name of the network you'd like to connect to ~~~ ]"; echo "[ ~~~ (names are case sensitive) ~~~ ]"; echo ""; read saved_name; saved_id=$(<$saved_name.txt); echo "~~~~~~~~~~~~~"; sudo zerotier-cli join $saved_id; input_id=$saved_id; echo "~~~~~~~~~~~~~"; echo ""; echo [ NAME OF LOADED NETWORK: $saved_name ]; echo "[ ID OF LOADED NETWORK: $input_id ]"; echo "======================================="; continue;;
	"create new savefile" ) clear; echo "// create new savefile"; echo ""; echo "[ ~~~ type the name of the network you'd like to connect to ~~~ ]"; read saved_name; echo $saved_name >> genesis[index].txt; echo ""; echo "[ ~~~ paste the network-id ~~~ ]"; read saved_id; echo "$saved_id" > $saved_name.txt; echo ".:save created, select load to see it:."; input_id=$saved_id; continue;;
	"check client info" ) clear; echo "// check client info"; sudo zerotier-cli info; continue;;
	"check currently connected networks" ) clear; echo "// check currently connected networks"; sudo zerotier-cli info; continue;;
	"exit" ) clear; echo "// exit"; echo ""; echo "exiting.."; exit;;
    esac
done
