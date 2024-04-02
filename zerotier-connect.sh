#!/bin/bash
#====================================
# Project: zerotier-connect_v0.420x
# Author:  ConzZah
#====================================
#/// start setting functions
function Logo {
clear
status_screen
echo " .:*======= ConzZah's =======*:."
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " *   ZEROTIER-CONNECT_v0.420x   *"
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "[ LAST CHANGE TO CODE @ 02.04.2024 / 06:32 ]"
echo ""
}
#0
function InitialRun { #  <-- gets called if no savefile is detected
cd /; cd /home/$USER/Documents
if [ ! -d /home/$USER/Documents/ZeroTier-Connect_Save ]; then mkdir ZeroTier-Connect_Save
fi; cd ZeroTier-Connect_Save
echo "[ ~~~ type network alias ~~~ ]"; echo ""
read saved_name # <-- gets user input (for network name)
echo $saved_name >> genesis[index].txt # <-- appends network name to genesis
echo "[ ~~~ paste the network-id ~~~ ]"; echo ""
read saved_id # <-- gets user input (for network id)
echo "$saved_id" > $saved_name.txt # <-- writes actual save, (as in: TheNetworkNameYouChoose.txt)
echo ""; echo "[ .:SAVE CREATED:. ]"; echo ""
input_id=$saved_id # <-- syncs value in saved_id to input_id
echo "[ STATUS UPDATED: ]"; echo ""
status_screen
return2main_menu
}
#1
function ManualInput {
echo "/// CONNECT TO NETWORK ID"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo "" 
echo "[ ~~~ paste network-id ~~~ ]"; echo ""
read input_id
echo "~~~~~~~~~~~~~~~~"; 
sudo zerotier-cli join $input_id;
echo "~~~~~~~~~~~~~~~~"; echo ""
saved_id=$input_id # <-- syncs value in input_id to saved_id
saved_name="NONE SELECTED"
echo "[ STATUS UPDATED: ]"; echo ""
status_screen
return2main_menu
}
#2
function LoadFromSave {
unset saved_name; unset input_id
echo "/// CONNECT TO SAVED NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
echo "[ SAVEFILE FOUND ]"
echo "~~~~~~~~~~~~~~~~~~"
cat genesis[index].txt
echo "~~~~~~~~~~~~~~~~~~"; echo ""
echo "[ ~~~ type network alias ~~~ ]"; echo ""
read saved_name 
if [ ! -f /home/$USER/Documents/ZeroTier-Connect_Save/$saved_name.txt ]; then echo "$saved_name doesn't exist. press any key to try again."; read -n 1 -s; init_status_screen; Logo; LoadFromSave
fi # <-- (error handling) checks if savefile corresponding to user input exists, if not, prints string and lets user try again.
saved_id=$(<$saved_name.txt) # <-- loads content of .txt into saved_id.
echo "~~~~~~~~~~~~~~~~"
sudo zerotier-cli join $saved_id # <-- connects with network id stored in saved_id.
echo "~~~~~~~~~~~~~~~~"; echo "" 
input_id=$saved_id # <-- syncs value in saved_id to input_id
echo "[ STATUS UPDATED: ]"; echo ""
status_screen
return2main_menu
}
#3
function CreateNewSave {
echo "/// CREATE NEW SAVED NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
echo "[ ~~~ type network alias ~~~ ]"; echo ""
read saved_name
echo $saved_name >> genesis[index].txt # <-- appends network name to index file
echo ""
echo "[ ~~~ paste network-id ~~~ ]"; echo ""
read saved_id
echo "$saved_id" > $saved_name.txt # <-- stores network id in .txt
input_id=$saved_id # <-- syncs value in saved_id to input_id
echo ""
echo "[ .:SAVE CREATED:. ]"; echo ""
echo "[ STATUS UPDATED: ]"; echo ""
status_screen
return2main_menu
}
#4
function CheckClientInfo {
echo "/// CHECK CLIENT INFO" 
echo "~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
sudo zerotier-cli info
return2main_menu
}
#5
function CheckConnectedNetworks {
echo "/// CHECK CONNECTED NETWORKS"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo "" 
sudo zerotier-cli listnetworks; echo ""
status_screen
return2main_menu
} 
#6
function Disconnect {
sudo zerotier-cli listnetworks; echo ""
echo "/// DISCONNECT FROM NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
select dc in "DC FROM SELECTED NETWORK" "DC FROM DIFFERENT NETWORK"; do
	case $dc in
	"DC FROM SELECTED NETWORK" ) sudo zerotier-cli leave $input_id; break;;
	"DC FROM DIFFERENT NETWORK" ) echo""; echo "[ ~~~ paste network-id ~~~ ]"; read disconnect; sudo zerotier-cli leave $disconnect; break;;
	esac
done
init_status_screen
return2main_menu
}
#7 
function CheckPeers {
echo "/// LIST CONNECTED PEERS"
echo "~~~~~~~~~~~~~~~~~~~~~~~~"; echo "" 
sudo zerotier-cli peers; echo ""
return2main_menu
}
# main menu
function main_menu {
clear
Logo
echo "// MAIN MENU"
echo "~~~~~~~~~~~~~~"
select ccde in "CONNECT TO NETWORK" "CHECK STATUS" "DISCONNECT FROM NETWORK" "EXIT"; do
    case $ccde in
    "CONNECT TO NETWORK" ) clear; Logo; connection_menu; continue;;
	"CHECK STATUS" ) clear; Logo; status_menu; continue;;
	"DISCONNECT FROM NETWORK" ) clear; Logo; Disconnect; continue;;
	"EXIT" ) echo "// EXIT"; echo ""; echo "exiting.."; exit;;
    esac
done
}
# connection_menu ( sub menu )
function connection_menu {
Logo
echo "// CONNECT TO NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~"
select ccc in "CONNECT VIA NETWORK ID" "CONNECT TO SAVED NETWORK" "CREATE NEW SAVED NETWORK"; do
    case $ccc in
	"CONNECT VIA NETWORK ID" ) clear; Logo; ManualInput; break;;
	"CONNECT TO SAVED NETWORK" ) clear; Logo; LoadFromSave; break;;
	"CREATE NEW SAVED NETWORK" ) clear; Logo; CreateNewSave; break;;
    esac
done
}

# status_menu ( sub menu )
function status_menu {
echo "// CHECK STATUS"
echo "~~~~~~~~~~~~~~~~~"
select lls in "LIST CONNECTED NETWORKS" "LIST CONNECTED PEERS" "SHOW CLIENT INFO"; do
    case $lls in
	"LIST CONNECTED NETWORKS" ) clear; Logo; CheckConnectedNetworks; break;;
	"LIST CONNECTED PEERS" ) clear; Logo; CheckPeers; break;;
	"SHOW CLIENT INFO" ) clear; Logo; CheckClientInfo; break;;
    esac
done
}
# --- sub functions --- 
# status screen
function status_screen {
echo "[ NAME OF SELECTED NETWORK: $saved_name ]"
echo "[ ID OF SELECTED NETWORK: $input_id ]" 
echo ""
}
# initialize status screen
function init_status_screen {
saved_name="NONE SELECTED"
input_id="NONE SELECTED"
}
# return to main menu
function return2main_menu {
echo ""
echo "[ ~~~ PRESS ANY KEY TO RETURN TO MAIN MENU ~~~ ]"
read -n 1 -s
main_menu
}
# /// all functions set /// start launch prep
# checks if genesis[index].txt exists - if not present, script will call InitialRun.
if [ ! -f /home/$USER/Documents/ZeroTier-Connect_Save/genesis[index].txt ]; then echo "[ NO SAVEDATA FOUND. ]"; echo ""; InitialRun
fi; cd /; cd home/$USER/Documents/; cd ZeroTier-Connect_Save # <-- cd's to working directory 
init_status_screen; main_menu # <--  ( //LAUNCH\\ ) 
