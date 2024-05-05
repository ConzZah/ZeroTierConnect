#!/bin/bash
  #======================================
  # Project: zerotier-connect_v0.5
  # Author:  ConzZah
  #======================================
  #####################################
  # // SETTING ESSENTIAL FUNCTIONS //
  #####################################
# Logo
function Logo {
clear
echo " .:*======= ConzZah's =======*:."
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " *    ZEROTIER-CONNECT_v0.5     *"
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
#echo "[ LAST CHANGE TO CODE @ 05.05.2024 / 22:45 ]"
echo ""
status_screen; echo ""
}
# check4installed_zerotier_client <-- (checks if zerotier is installed, if not, will offer user to install it / if user declines, will exit.)
function check4installed_zerotier_client {
error_msg="[ [ERROR]: ZEROTIER INSTALL COULD NOT BE FOUND. ]"
zt_install_check=$(sudo zerotier-cli info); clear
if [[ "$zt_install_check" == "" ]]; then echo "$error_msg"; echo ""; ask2install_zerotier_client; fi
}
# ask2install_zerotier_client <--  (asks user if they want to install the zerotier client if it hasnt been detected.)
function ask2install_zerotier_client {
install_msg="[ ::: DOWNLOADING & INSTALLING ZEROTIER FROM: https://install.zerotier.com ::: ]"
pls_wait="[ ::: PLEASE WAIT ::: ]"
post_install_msg="[ INSTALL FINISHED. PRESS ANY KEY TO LAUNCH ZTC ]"
select yn in "INSTALL ZEROTIER" "EXIT"; do
	case $yn in
	"INSTALL ZEROTIER" ) echo ""; echo "$install_msg"; echo ""; echo "$pls_wait"
	install_zerotier_client=$(curl -s https://install.zerotier.com | sudo bash)
	echo ""; echo "$post_install_msg"; read -n 1 -s; break;;
	"EXIT" ) exit; break;;
	esac
done
}
# status_screen
function status_screen {
echo "########################################################"
echo "[ ID OF SELECTED NETWORK: $input_id ]"
echo "[ NAME OF SELECTED NETWORK: $actual_netname ]"
echo "[ ALIAS OF SELECTED NETWORK: $saved_alias ]"
echo "########################################################"
echo ""
}
# init_status
function init_status {
input_id="NONE SELECTED"
saved_id="NONE SELECTED"
saved_alias="NONE SELECTED"
actual_netname="NONE SELECTED"
}
# store__current_status
# stores current status in backup variables so we can reload them in case a user error occurs.
function store__current_status {
input_id__current=$input_id
saved_id__current=$saved_id
saved_alias__current=$saved_alias
actual_netname__current=$actual_netname
}
# recall__current_status
# loads status values, previously stored with "store__current_status", back into their actual variables.
function recall__current_status {
input_id=$input_id__current
saved_id=$saved_id__current
saved_alias=$saved_alias__current
actual_netname=$actual_netname__current
}
# fetch_actual_netname <--- (fetching network name 3 times & sleeping 3 seconds. otherwise, fails to update / display properly.)
function fetch_actual_netname {
cnbf="NAME COULD NOT BE FETCHED, ARE YOU AUTHORIZED?"
echo "[ ::: FETCHING NETWORK NAME ::: ]"; echo "";
actual_netname=$(sudo zerotier-cli get $input_id name); sleep 1 # <-- ( try 1 )
actual_netname=$(sudo zerotier-cli get $input_id name); sleep 1 # <-- ( try 2 )
actual_netname=$(sudo zerotier-cli get $input_id name); sleep 1 # <-- ( try 3 )
if [[ "$actual_netname" == "" ]]; then actual_netname="$cnbf"; fi
if [[ "$actual_netname" == "$cnbf" ]]; then sleep 1; echo ""; echo "[ ERROR: $cnbf ]"; echo ""; fi
# if network name could not be fetched after 3 tries, update actual_netname and thus status_screen with: "NAME COULD NOT BE FETCHED."
}
# if_network_not_present__fail
function if_network_not_present__fail {
error_msg="[ ~~~ [ERROR]: SELECT A NETWORK FIRST, THEN TRY AGAIN. ~~~ ]"
if [[ "$input_id" == "NONE SELECTED" ]]; then echo ""; echo "$error_msg"; echo ""; return2main_menu; fi
if [[ "$input_id" == "" ]]; then echo ""; echo "$error_msg"; echo ""; return2main_menu; fi
# will be triggered if variable input_id is set to starting value OR none at all.
}
# check4invalid__input_id <-- ( error check for: "ManualInput" )
function check4invalid__input_id {
valid_check__input_id=$(sudo zerotier-cli join $input_id )
error_msg="[ [ERROR]: $valid_check__input_id. PRESS ANY KEY TO TRY AGAIN. ]"
# if user enters "q", quit to main menu
if [[ "$input_id" == "q" ]]; then recall__current_status; return2main_menu; fi
if [[ "$valid_check__input_id" == "invalid network id" ]]; then echo "$error_msg"
read -n 1 -s; recall__current_status; Logo; ManualInput
fi # check if network id is invalid. if it is, echo error message, recall current status and reload ManualInput
}
# check4invalid__saved_id <-- ( error check for: "CreateNewSave" )
function check4invalid__saved_id {
valid_check__saved_id=$(sudo zerotier-cli join $saved_id )
error_msg="[ [ERROR]: $valid_check__saved_id. PRESS ANY KEY TO TRY AGAIN. ]"
# if user enters "q", quit to main menu
if [[ "$saved_id" == "q" ]]; then recall__current_status; return2main_menu; fi
if [[ "$valid_check__saved_id" == "invalid network id" ]]; then echo "$error_msg"
read -n 1 -s; recall__current_status; Logo; CreateNewSave
fi # check if network id is invalid. if it is, echo error message, recall current status and reload CreateNewSave
}
# check4invalid__saved_alias <-- ( error check for: "LoadFromSave" )
function check4invalid__saved_alias {
error_msg="$saved_alias doesn't exist. press any key to try again."
# if user enters "q", quit to main menu
if [[ "$saved_alias" == "q" ]]; then recall__current_status; return2main_menu; fi
if [ ! -f ~/ZTC_Save/$saved_alias.txt ]; then echo "$error_msg"; read -n 1 -s; recall__current_status; Logo; LoadFromSave; fi
}
# InitialRun <--- (only gets called if no savefile is detected)
function InitialRun {
init_status
# cd's to savepath and, if not present, creates savefolder.
cd ~; if [ ! -d ~/ZTC_Save ]; then mkdir ZTC_Save; fi; cd ZTC_Save
CreateNewSave
} #################################
  # // ESSENTIAL FUNCTIONS SET //
  #################################
  ##########################################
  # /// start setting core functions ///
  ##########################################
#1 ManualInput
function ManualInput {
store__current_status
error_msg="[ ~~~ [ERROR]: ID CANNOT BE EMPTY. PRESS ANY KEY TO TRY AGAIN. ~~~ ]"
clear; Logo
echo "/// CONNECT TO NETWORK ID"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
echo "[ ~~~ paste network-id ~~~ ]"; echo ""
read input_id
if [[ "$input_id" == "" ]]; then echo "$error_msg"; echo ""; read -n 1 -s; recall__current_status; ManualInput
fi # <-- gets triggered when user enters nothing & falls back to value stored in saved_id
check4invalid__input_id
echo "~~~~~~~~~~~~~~~~";
sudo zerotier-cli join $input_id
echo "~~~~~~~~~~~~~~~~"; echo ""
saved_id=$input_id # <-- syncs value in input_id to saved_id
saved_alias="NONE SELECTED"
fetch_actual_netname
echo "[ STATUS UPDATED: ]"; echo ""
status_screen
return2main_menu
}
#2 LoadFromSave
function LoadFromSave {
store__current_status
echo "/// CONNECT TO SAVED NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
echo "[ SAVEFILE FOUND ]"
echo "~~~~~~~~~~~~~~~~~~"
cat alias_index.txt
echo "~~~~~~~~~~~~~~~~~~"; echo ""
echo "[ ~~~ type network alias & press [ENTER] ~~~ ]"; echo ""
read saved_alias
check4invalid__saved_alias
saved_id=$(<$saved_alias.txt) # <-- loads content of .txt into saved_id.
echo "~~~~~~~~~~~~~~~~"
sudo zerotier-cli join $saved_id # <-- connects with network id stored in saved_id.
input_id=$saved_id # <-- syncs value in saved_id to input_id
echo "~~~~~~~~~~~~~~~~"; echo ""
fetch_actual_netname
echo "[ STATUS UPDATED: ]"; echo ""
status_screen
return2main_menu
}
#3 CreateNewSave
function CreateNewSave {
store__current_status
echo "/// CREATE NEW SAVED NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
echo "[ ~~~ paste network-id ~~~ ]"; echo ""
read saved_id; check4invalid__saved_id; echo ""
echo "[ ~~~ type network alias & press [ENTER] ~~~ ]"; echo ""; read saved_alias; echo ""
echo $saved_alias >> alias_index.txt # <-- appends network number to index file
echo "$saved_id" > $saved_alias.txt # <-- stores network id in .txt <-- ( writes save )
input_id=$saved_id # <-- syncs value in saved_id to input_id
echo "[ .:SAVE CREATED:. ]"; echo ""
fetch_actual_netname
echo "[ STATUS UPDATED: ]"; echo ""
status_screen
return2main_menu
}
#4 CheckClientInfo
function CheckClientInfo {
echo "/// CHECK CLIENT INFO"
echo "~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
sudo zerotier-cli info; echo ""
return2main_menu
}
#5 CheckConnectedNetworks
function CheckConnectedNetworks {
echo "/// LIST CONNECTED NETWORKS"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
sudo zerotier-cli listnetworks; echo ""
return2main_menu
}
#6 CheckPeers
function CheckPeers {
echo "/// LIST CONNECTED PEERS"
echo "~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
sudo zerotier-cli peers; echo ""
return2main_menu
}
#7 CheckIP
function CheckIP {
echo "/// CHECK IP ADDRESS"
echo "~~~~~~~~~~~~~~~~~~~~~"; echo ""
if_network_not_present__fail
echo IP OF SELECTED ZEROTIER NETWORK:; echo ""
sudo zerotier-cli get $input_id ip; echo ""
return2main_menu
}
#8 get_net_settings
function get_net_settings {
# /// setting variables
allow_dns_status=$(sudo zerotier-cli get $input_id allowDNS)
allow_default_status=$(sudo zerotier-cli get $input_id allowDefault)
allow_global_status=$(sudo zerotier-cli get $input_id allowGlobal)
allow_managed_status=$(sudo zerotier-cli get $input_id allowManaged)
ip_status=$(sudo zerotier-cli get $input_id ip)
# /// variables set
echo "// GET NETWORK SETTINGS FOR $input_id:"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
echo "Allow DNS: $allow_dns_status"; echo ""
echo "Allow Default: $allow_default_status"; echo ""
echo "Allow Global: $allow_global_status"; echo ""
echo "Allow Managed: $allow_managed_status"; echo ""
echo "Network ID: $input_id"; echo ""
echo "Network Name: $actual_netname"; echo ""
echo "Assigned IP: $ip_status"; echo ""
return2get_set_menu
}
#9 set_net_settings <--- [ IN DEVELOPMENT ] ##############
function set_net_settings {
echo "// SET NETWORK SETTINGS FOR $input_id:"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
echo "( under construction, feature will be added soon )"
return2get_set_menu
} ##########################################
  # /// core functions set ///
  ##########################################
  ##########################################
  # /// start setting menu functions ///
  ##########################################
# connection_menu ( sub menu 1 )
function connection_menu {
echo "// CONNECT TO NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~"
select cccr in "CONNECT VIA NETWORK ID" "CONNECT TO SAVED NETWORK" "CREATE NEW SAVED NETWORK" "RETURN TO MAIN MENU"; do
    case $cccr in
	"CONNECT VIA NETWORK ID" ) clear; Logo; ManualInput; break;;
	"CONNECT TO SAVED NETWORK" ) clear; Logo; LoadFromSave; break;;
	"CREATE NEW SAVED NETWORK" ) clear; Logo; CreateNewSave; break;;
	"RETURN TO MAIN MENU" ) return2main_menu; break;;
    esac
done
}
# status_menu ( sub menu 2 )
function status_menu {
echo "// CHECK STATUS"
echo "~~~~~~~~~~~~~~~~~"
if_network_not_present__fail
select llccr in "LIST CONNECTED NETWORKS" "LIST CONNECTED PEERS" "CHECK CLIENT INFO" "CHECK IP ADDRESS" "RETURN TO MAIN MENU"; do
    case $llccr in
	"LIST CONNECTED NETWORKS" ) clear; Logo; CheckConnectedNetworks; break;;
	"LIST CONNECTED PEERS" ) clear; Logo; CheckPeers; break;;
	"CHECK CLIENT INFO" ) clear; Logo; CheckClientInfo; break;;
	"CHECK IP ADDRESS" ) clear; Logo; CheckIP; break;;
	"RETURN TO MAIN MENU" ) return2main_menu; break;;
    esac
done
}
# get_set_menu ( sub menu 3 ) <--- [ IN DEVELOPMENT ] ##############
function get_set_menu {
echo "// GET / SET NETWORK SETTINGS (ADVANCED) "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
if_network_not_present__fail
select gsr in "GET NETWORK SETTINGS FOR $input_id" "SET NETWORK SETTINGS FOR $input_id" "RETURN TO MAIN MENU"; do
	case $gsr in
	"GET NETWORK SETTINGS FOR $input_id" ) clear; Logo; get_net_settings; continue;;
	"SET NETWORK SETTINGS FOR $input_id" ) clear; Logo; set_net_settings; continue;;
	"RETURN TO MAIN MENU" ) return2main_menu; break;;
	esac
done
}
# disconnection_menu ( sub menu 4 )
function disconnection_menu {
echo "/// DISCONNECT FROM NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
select dcr in "DC FROM $input_id" "DC FROM OTHER NETWORK" "RETURN TO MAIN MENU"; do
	case $dcr in
	"DC FROM $input_id" ) sudo zerotier-cli leave $input_id; break;;
	"DC FROM OTHER NETWORK" ) sudo zerotier-cli listnetworks; echo""; echo "[ ~~~ paste network-id ~~~ ]"; read disconnect; sudo zerotier-cli leave $disconnect; break;;
	"RETURN TO MAIN MENU" ) return2main_menu; break;;
	esac
done
init_status
return2main_menu
}
# return2get_set_menu
function return2get_set_menu {
echo ""
echo "[ ~~~ PRESS ANY KEY TO RETURN TO GET / SET MENU ~~~ ]"
read -n 1 -s
clear; Logo
get_set_menu
}
# return2main_menu
function return2main_menu {
echo ""
echo "[ ~~~ PRESS ANY KEY TO RETURN TO MAIN MENU ~~~ ]"
read -n 1 -s
main_menu
}
# main menu
function main_menu {
clear; Logo
echo "// MAIN MENU"
echo "~~~~~~~~~~~~~~"
select ccgde in "CONNECT TO NETWORK" "CHECK STATUS" "GET / SET NETWORK SETTINGS (ADVANCED)" "DISCONNECT FROM NETWORK" "EXIT"; do
    case $ccgde in
    "CONNECT TO NETWORK" ) clear; Logo; connection_menu; continue;;
	"CHECK STATUS" ) clear; Logo; status_menu; continue;;
	"GET / SET NETWORK SETTINGS (ADVANCED)" ) clear; Logo; get_set_menu; continue;;
	"DISCONNECT FROM NETWORK" ) clear; Logo; disconnection_menu; continue;;
	"EXIT" ) echo "// EXIT"; echo ""; echo "exiting.."; exit;;
    esac
done
} ###################################################
  # /// all functions set /// start launch prep ///
  ###################################################
# checks if zerotier is installed & if alias_index.txt exists - if not present, script will call InitialRun.
clear; check4installed_zerotier_client
if [ ! -f ~/ZTC_Save/alias_index.txt ]; then Logo; echo "[ ERROR ]: NO SAVEDATA FOUND.  ]"; echo ""; InitialRun; fi
cd ~; cd ZTC_Save # <-- cd's to working / save directory
init_status; main_menu # <--  ( //LAUNCH\\ )
