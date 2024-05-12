#!/bin/bash
  #============================================
  # Project: zerotier-connect_v0.6
  # Author:  ConzZah / ©️ 2024
  # https://github.com/ConzZah/ZeroTierConnect
  #============================================
  #####################################
  # // SETTING ESSENTIAL FUNCTIONS //
  #####################################
# Logo
function Logo {
clear
echo " .:*======= ConzZah's =======*:."
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " *    ZEROTIER-CONNECT_v0.6     *"
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
#echo "[ LAST CHANGE TO CODE @ 12.05.2024 / 21:44 ]"
echo ""
status_screen; echo ""
}
# check4installed_zerotier_client <-- (checks if zerotier is installed, if not, will offer user to install it / if user declines, will exit.)
function check4installed_zerotier_client {
error_msg="[ [ERROR]: ZEROTIER INSTALL COULD NOT BE FOUND. ]"
zt_install_check=$(sudo zerotier-cli info); clear
if [[ "$zt_install_check" == "" ]]; then echo "$error_msg"; echo ""; ask2install_zerotier_client; fi
}
# ask2install_zerotier_client <--  ( asks user if they want to install the zerotier client if it hasnt been detected. )
function ask2install_zerotier_client {
echo "1) INSTALL ZEROTIER" 
echo "Q) EXIT"
read ask2installZT
case $ask2installZT in
	1) zt_installer;;
	q) echo ""; echo "// EXIT"; exit;;
	Q) echo ""; echo "// EXIT"; exit;;
	*) clear; check4installed_zerotier_client
esac
}
# zt_installer <-- ( downloads & installs zerotier client from https://www.zerotier.com/download/ )
# Also checks if curl is available. curl is needed to download the zerotier client. 
# The script installs curl via apt if it isn't found on the system. 
function zt_installer {
zt_install_msg0="[ ::: DOWNLOADING & INSTALLING ZEROTIER VIA: ::: ]"
zt_install_msg1="[ ::: https://install.zerotier.com ::: ]"
pls_wait_msg="[ :::  PLEASE WAIT  ::: ]"
post_install_msg="[ INSTALL FINISHED. PRESS ANY KEY TO LAUNCH ZTC ]"
curl_missing_msg="[ ::: ERROR: MISSING DEPENDENCY: CURL ::: ]"
curl_install_msg=" [ ::: INSTALLING DEPENDENCY: CURL... :::]"
curl_post_install_msg="  [ ::: INSTALLED DEPENDENCY: CURL. :::]"
command -v curl >/dev/null 2>&1 || { echo ""; echo "$curl_missing_msg"; echo ""; echo "$curl_install_msg"
sudo apt install curl >/dev/null 2>&1; echo ""; echo "$curl_post_install_msg"; echo ""; }
echo ""; echo "$zt_install_msg0"; echo "$zt_install_msg1"; echo "$pls_wait_msg"; echo ""
install_zerotier_client=$(curl -s https://install.zerotier.com | sudo bash)
echo ""; echo "$post_install_msg"; echo ""; read -n 1 -s
}
# status_screen
function status_screen {
echo "##########################################################"
echo "[ ID OF SELECTED NETWORK: $input_id ]"
echo "[ NAME OF SELECTED NETWORK: $actual_netname ]"
echo "[ ALIAS OF SELECTED NETWORK: $saved_alias ]"
echo "##########################################################"
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
# store__lcn
# stores last connected network values in .txt files to reload them when needed.
function store__lcn {
if [ ! -d ~/ZTC_Save/.LCN ]; then mkdir .LCN; fi; cd ~/ZTC_Save/.LCN
echo "$input_id" > .lcn__input_id.txt
echo "$saved_alias" > .lcn__saved_alias.txt
echo "$actual_netname" > .lcn__actual_netname.txt
cd ~/ZTC_Save/
}
# recall__lcn
# recalls last connected network values into their variables
function recall__lcn {
if [ ! -d ~/ZTC_Save/.LCN ]; then mkdir .LCN; init_status; fi; cd ~/ZTC_Save/.LCN
input_id=$(<.lcn__input_id.txt)
saved_alias=$(<.lcn__saved_alias.txt)
actual_netname=$(<.lcn__actual_netname.txt)
cd ~/ZTC_Save/
}
# fetch_network_details 
function fetch_network_details {
# (fetching network name 4 times & sleeping 4 seconds, so we can be sure before calling errors.
fetch_cmd="sudo zerotier-cli get $input_id name"
cnbf="UNABLE TO FETCH. AUTHORIZED?"
netname_error_msg="[ ERROR: NAME COULD NOT BE FETCHED. ARE YOU AUTHORIZED? ]"
echo "[ /// FETCHING NETWORK DETAILS.. ]"; echo "";
actual_netname=$($fetch_cmd); sleep 1; actual_netname=$($fetch_cmd); sleep 1
actual_netname=$($fetch_cmd); sleep 1; actual_netname=$($fetch_cmd); sleep 1
if [[ "$actual_netname" == "" ]]; then actual_netname="$cnbf"; fi
if [[ "$actual_netname" == "$cnbf" ]]; then echo ""; echo "$netname_error_msg"; echo ""; fi
# ^ if network name could not be fetched after 4 tries, update actual_netname & status_screen with: "NAME COULD NOT BE FETCHED."
# /// getting network settings / rules
allow_dns_status=$(sudo zerotier-cli get $input_id allowDNS)
allow_default_status=$(sudo zerotier-cli get $input_id allowDefault)
allow_global_status=$(sudo zerotier-cli get $input_id allowGlobal)
allow_managed_status=$(sudo zerotier-cli get $input_id allowManaged)
ip_status=$(sudo zerotier-cli get $input_id ip)
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
if [[ "$input_id" == "q" ]] || [[ "$input_id" == "Q" ]] ; then recall__current_status; return2main_menu; fi 
# ^ ^ ^ if user enters "q / Q", recall last known network values & quit to main menu
# check if network id is invalid. if it is, echo error message, recall current status and reload ManualInput
if [[ "$valid_check__input_id" == "invalid network id" ]]; then echo "$error_msg"
read -n 1 -s; recall__current_status; Logo; ManualInput
fi
# gets triggered when user enters nothing & restores state from backup variables
if [[ "$input_id" == "" ]]; then echo "$error_msg"; echo ""; read -n 1 -s; recall__current_status; ManualInput
fi
}
# check4invalid__saved_id <-- ( error check for: "CreateNewSave" )
function check4invalid__saved_id {
valid_check__saved_id=$(sudo zerotier-cli join $saved_id )
error_msg="[ [ERROR]: $valid_check__saved_id. PRESS ANY KEY TO TRY AGAIN. ]"
if [[ "$saved_id" == "q" ]] || [[ "$saved_id" == "Q" ]]; then recall__current_status; return2main_menu; fi 
# check if network id is invalid. if it is, echo error message, recall current status and reload CreateNewSave
if [[ "$valid_check__saved_id" == "invalid network id" ]]; then echo "$error_msg"
read -n 1 -s; recall__current_status; Logo; CreateNewSave
fi
}
# check4invalid__saved_alias <-- ( error check for: "LoadFromSave" )
function check4invalid__saved_alias {
error_msg="[ ERROR: $saved_alias doesn't exist. press any key to try again. ]"
if [[ "$saved_alias" == "q" ]] || [[ "$saved_alias" == "Q" ]]; then recall__current_status; return2main_menu; fi # <-- if user enters "q", quit to main menu
if [ ! -f ~/ZTC_Save/SAVED_NETWORKS/$saved_alias.txt ]; then echo "$error_msg"; read -n 1 -s; recall__current_status; Logo; LoadFromSave; fi
}
# gen_alias_index_txt <-- generates alias_index.txt with all savefiles found in save directory (using ls and sed) 
function gen_alias_index_txt {
ls > raw_alias_index.txt
sed -i 's/.txt//g' raw_alias_index.txt
sed -i 's/raw_alias_index//g' raw_alias_index.txt
sed -i 's/alias_index//g' raw_alias_index.txt
sed '/^$/d' ~/ZTC_Save/SAVED_NETWORKS/raw_alias_index.txt > alias_index.txt
rm raw_alias_index.txt
}
# InitialRun <--- (only gets called if no savefile is detected)
function InitialRun {
# cd's to savepath and, if not present, creates main savefolder.
cd ~; if [ ! -d ~/ZTC_Save ]; then mkdir ZTC_Save; fi; cd ZTC_Save
if [ ! -d ~/ZTC_Save/SAVED_NETWORKS ]; then mkdir SAVED_NETWORKS; fi
init_status
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
check4invalid__input_id; clear
echo "[ CONNECTING TO: $input_id.. ]"; echo ""
echo "$ui1"; sudo zerotier-cli join $input_id; echo "$ui1"; echo ""
saved_id=$input_id # <-- syncs value in input_id to saved_id
saved_alias="NONE SELECTED"
fetch_network_details
echo "[ STATUS UPDATED: ]"; echo ""
status_screen
store__lcn
return2main_menu
}
#2 LoadFromSave
function LoadFromSave {
store__current_status
cd ~/ZTC_Save/SAVED_NETWORKS
gen_alias_index_txt
echo "/// CONNECT TO SAVED NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
echo "[ SAVEFILE FOUND ]"; echo ""
echo "$ui1"; cat alias_index.txt; echo "$ui1"; echo ""
echo "[ ~~~ type network alias & press [ENTER] ~~~ ]"; echo ""
read saved_alias
check4invalid__saved_alias; clear
saved_id=$(<$saved_alias.txt) # <-- loads content of .txt into saved_id.
input_id=$saved_id # <-- syncs value in saved_id to input_id
echo "[ CONNECTING TO: $saved_id / ALIAS: $saved_alias ]"; echo ""; echo "$ui1"
sudo zerotier-cli join $saved_id # <-- connects with network id stored in saved_id.
echo "$ui1"; echo ""; fetch_network_details
echo "[ STATUS UPDATED: ]"; echo ""
cd ~/ZTC_Save/
status_screen
store__lcn
return2main_menu
}
#3 CreateNewSave
function CreateNewSave {
store__current_status
cd ~/ZTC_Save/SAVED_NETWORKS
echo "/// CREATE NEW SAVED NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
echo "[ ~~~ paste network-id ~~~ ]"; echo ""
read saved_id; check4invalid__saved_id; echo ""
echo "[ ~~~ type network alias & press [ENTER] ~~~ ]"; echo ""; read saved_alias; echo ""
echo "$saved_id" > $saved_alias.txt # <-- stores network id in .txt <-- ( writes actual save )
input_id=$saved_id # <-- syncs value in saved_id to input_id
gen_alias_index_txt
echo "[ .:SAVE CREATED:. ]"; echo ""
fetch_network_details
echo "[ STATUS UPDATED: ]"; echo ""
cd ~/ZTC_Save/
status_screen
store__lcn
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
clear
echo "// GET NETWORK SETTINGS FOR $input_id:"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
fetch_network_details
echo "Allow DNS: $allow_dns_status"; echo ""
echo "Allow Default: $allow_default_status"; echo ""
echo "Allow Global: $allow_global_status"; echo ""
echo "Allow Managed: $allow_managed_status"; echo ""
echo "Network ID: $input_id"; echo ""
echo "Network Name: $actual_netname"; echo ""
echo "Assigned IP: $ip_status"; echo ""
return2main_menu
}
#9 set_net_settings <--- [ IN DEVELOPMENT ] ##############
function set_net_settings {
echo "// SET NETWORK SETTINGS FOR $input_id:"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
echo "     ( feature will be added in v0.7 )"
return2main_menu
}; ui1="~~~~~~~~~~~~~~~~~~" 
##########################################
# /// core functions set ///
##########################################
##########################################
# /// start setting menu functions ///
##########################################
# connection_menu ( sub menu 1 )
function connection_menu {
echo "// CONNECT TO NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~"
echo "1) CONNECT VIA NETWORK ID" 
echo "2) CONNECT TO SAVED NETWORK" 
echo "3) CREATE NEW SAVED NETWORK" 
echo "Q) RETURN TO MAIN MENU"
read connection_menu
case $connection_menu in
	1) clear; Logo; ManualInput;;
	2) clear; Logo; LoadFromSave;;
	3) clear; Logo; CreateNewSave;;
	q) return2main_menu;;
	Q) return2main_menu;;
	*) connection_menu
esac
}
# status_menu ( sub menu 2 )
function status_menu {
echo "// CHECK STATUS"
echo "~~~~~~~~~~~~~~~~~"
echo "1) LIST CONNECTED NETWORKS" 
echo "2) LIST CONNECTED PEERS" 
echo "3) CHECK CLIENT INFO" 
echo "4) CHECK IP ADDRESS" 
echo "Q) RETURN TO MAIN MENU"
read status_menu
case $status_menu in
	1) clear; Logo; CheckConnectedNetworks;;
	2) clear; Logo; CheckPeers;;
	3) clear; Logo; CheckClientInfo;;
	4) clear; Logo; CheckIP;;
	q) return2main_menu;;
	Q) return2main_menu;;
	*) status_menu
esac
}
# get_set_menu ( sub menu 3 )
function get_set_menu {
echo "// GET / SET NETWORK SETTINGS (ADVANCED) "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
if_network_not_present__fail
echo "1) GET NETWORK SETTINGS FOR $input_id" 
echo "2) SET NETWORK SETTINGS FOR $input_id" 
echo "Q) RETURN TO MAIN MENU"
read get_set_menu
case $get_set_menu in
	1) clear; Logo; get_net_settings;;
	2) clear; Logo; set_net_settings;;
	q) return2main_menu;;
	Q) return2main_menu;;
	*) get_set_menu
esac
}
# disconnection_menu ( sub menu 4 )
function disconnection_menu {
echo "// DISCONNECT FROM NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "1) DC FROM $input_id" 
echo "2) DC FROM ANOTHER NETWORK" 
echo "Q) RETURN TO MAIN MENU"
read disconnection_menu
case $disconnection_menu in
	1) sudo zerotier-cli leave $input_id;;
	2) sudo zerotier-cli listnetworks; echo ""; echo "[ ~~~ paste network-id ~~~ ]"; 
		read dc_other; sudo zerotier-cli leave $dc_other;;
	q) return2main_menu;;
	Q) return2main_menu;;
	*) clear; disconnection_menu
esac
init_status
store__lcn
return2main_menu
}
# return2main_menu
function return2main_menu {
echo ""
echo "[ ~~~ PRESS ANY KEY TO RETURN TO MAIN MENU ~~~ ]"
read -n 1 -s
main_menu
}
# main_menu
function main_menu {
clear; Logo
echo "// MAIN MENU"
echo "~~~~~~~~~~~~~~"
echo "1) CONNECT TO NETWORK"
echo "2) CHECK STATUS"
echo "3) GET / SET NETWORK SETTINGS (ADVANCED)"
echo "4) DISCONNECT FROM NETWORK"
echo "Q) EXIT"
read main_menu
case $main_menu in
	1) clear; Logo; connection_menu;;
	2) clear; Logo; status_menu;;
	3) clear; Logo; get_set_menu;;
	4) clear; Logo; disconnection_menu;;
	q) echo ""; echo "// EXIT"; exit;;
	Q) echo ""; echo "// EXIT"; exit;;
	*) main_menu
esac
}
#####################################################
# /// all functions set /// starting launch prep ///
#####################################################
# checks if zerotier is installed & if alias_index.txt exists - if not present, script will call InitialRun.
clear; check4installed_zerotier_client
if [ ! -f ~/ZTC_Save/SAVED_NETWORKS/alias_index.txt ]; then echo "[ ERROR ]: NO SAVEDATA FOUND.  ]"; echo ""; InitialRun; fi
cd ~; cd ZTC_Save # <-- cd's to save directory
init_status; recall__lcn; main_menu # <--  ( //LAUNCH\\ )
