#!/bin/bash
#====================================
# Project: zerotier-connect_v0.420	#
# Author:  ConzZah					#
#====================================
#00 <-- start setting main functions
function Logo {
#clear; echo "[ LAST CHANGE @ 24.03.2024 / 05:07 ]"; echo ""
echo ".:*======= ConzZah's =======*:."
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " *  ZEROTIER-CONNECT_v0.420  *"
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
}
#0
function InitialRun { #  <-- only gets triggered if no savefile/folder exists
echo "[ ~~~ type the name of the network you'd like to connect to ~~~ ]"
cd /; cd /home/$USER/Documents; mkdir ZeroTier-Connect_Save; cd ZeroTier-Connect_Save # <-- creates save folder and cd's to its location
read saved_name # <-- gets user input (for network name)
echo $saved_name >> genesis[index].txt # <-- appends network name to genesis
echo "[ ~~~ paste the network-id ~~~ ]"; read saved_id # <-- gets user input (for network id)
echo "$saved_id" > $saved_name.txt # <-- writes actual save, (as in: TheNetworkNameYouChoose.txt)
echo ""; echo "[ .:save created:. ]"; echo "";
}
#1
function ManualInput {
echo "// input network id manually"; echo ""; 
echo "[ ~~~ paste the network-id ~~~ ]"; 
read input_id
echo "~~~~~~~~~~~~~~~~"; 
sudo zerotier-cli join $input_id;
echo "~~~~~~~~~~~~~~~~"
}
#2
function LoadFromSave {
echo "// connect via savefile"; echo ""
echo "[ .:checking savefile:.. ]"; echo "" 
echo "~~~~~~~~~~~~~~~~" 
cat genesis[index].txt 
echo "~~~~~~~~~~~~~~~~"
echo "[ ~~~ type the name of the network you'd like to connect to ~~~ ]"; echo ""
read saved_name 
saved_id=$(<$saved_name.txt)
echo "~~~~~~~~~~~~~~~~"
sudo zerotier-cli join $saved_id
input_id=$saved_id
echo "~~~~~~~~~~~~~~~~"; echo "" 
echo [ NAME OF LOADED NETWORK: $saved_name ]
echo "[ ID OF LOADED NETWORK: $input_id ]" 
echo "=========================================="
}
#3
function CreateNewSave {
echo "// create new savefile"; echo ""
echo "[ ~~~ type the name of the network you'd like to connect to ~~~ ]"
read saved_name
echo $saved_name >> genesis[index].txt
echo ""
echo "[ ~~~ paste the network-id ~~~ ]"
read saved_id
echo "$saved_id" > $saved_name.txt
echo ".:save created, select load to see it:."
input_id=$saved_id
}
#4
function CheckClientInfo {
echo "// check client info" 
echo ""; sudo zerotier-cli info
}
#5
function CheckCurrentlyConnectedNetworks {
echo "// check currently connected networks" 
echo ""; sudo zerotier-cli listnetworks
} # <-- end setting main functions
#x0 (checks if genesis[index].txt exists) - if this file isn't present the script prompts the user to input a network name and network id to create the save.
if [ ! -f /home/$USER/Documents/ZeroTier-Connect_Save/genesis[index].txt ]; then echo "[ .:no savedata found:. ]"; echo ""; InitialRun
fi
cd /; cd home/$USER/Documents/; cd ZeroTier-Connect_Save # <-- cd's to save directory
#x1 StartScreen
Logo
echo "[ ~~~ CHOOSE WHAT TO DO ~~~ ]"
echo "=============================="
# MainMenu
select icccce in "input network id manually" "connect via savefile" "create new savefile" "check client info" "check currently connected networks" "exit"; do
    case $icccce in
    "input network id manually" ) clear; Logo; ManualInput; continue;;
	"connect via savefile" ) clear; Logo; LoadFromSave; continue;;
	"create new savefile" ) clear; Logo; CreateNewSave; continue;;
	"check client info" ) clear; Logo; CheckClientInfo; continue;;
	"check currently connected networks" ) clear; Logo; CheckCurrentlyConnectedNetworks continue;;
	"exit" ) clear; Logo; echo "// exit"; echo ""; echo "exiting.."; exit;;
    esac
done
