#!/usr/bin/env bash
  #============================================
  # Project: zerotier-connect_v0.7
  # Author:  ConzZah / ©️ 2024
  # https://github.com/ConzZah/ZeroTierConnect
  #============================================
# Logo
function Logo {
clear
echo " .:*======= ConzZah's =======*:."
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " *    ZEROTIER-CONNECT_v0.7     *"
echo " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
#echo "[ LAST CHANGE TO CODE @ 24.06.2024 / 18:32 ]"
echo ""
status_screen; echo ""
}
# check4installed_zerotier_client <-- ( checks if zerotier is installed )
function check4installed_zerotier_client {
error_msg="[ [ERROR]: ZEROTIER INSTALL COULD NOT BE FOUND. ]"
zt_install_check=$($_doso "$_ztc" $_i); clear
if [[ "$zt_install_check" == "" ]]; then echo "$error_msg"
if [ ! -f /usr/sbin/zerotier-one ]; then echo ""; ask2install_zerotier_client; fi; fi
}
# ask2install_zerotier_client <--  ( asks user if they want to install the zerotier client if it hasnt been detected. )
function ask2install_zerotier_client {
echo "1) INSTALL ZEROTIER" 
echo "Q) EXIT"
echo ""; read -r ask2installZT
case $ask2installZT in
	1) zt_installer;;
	q) echo ""; echo "// EXIT"; exit;;
	Q) echo ""; echo "// EXIT"; exit;;
	*) clear; check4installed_zerotier_client
esac
}
# zt_installer <-- ( downloads & installs zerotier client binarys through https://www.zerotier.com/download/ )
#( or will ask you if you want to build from source if you're on Alpine Linux. )
#( since Alpine v3.17, ZeroTier apparently got removed from the community repo, thats why this is an option.)
function zt_installer {
if [[ "$is_alpine" == "Alpine" ]]; then echo "ALPINE DETECTED"; echo ""; compile4alpine; fi 
zt_install_msg0="[ ::: DOWNLOADING & INSTALLING ZEROTIER ::: ]"
ZT_done_msg="[ INSTALL FINISHED. PRESS ANY KEY TO LAUNCH ZTC ]"
curl_missing_msg="[ ::: ERROR: MISSING DEPENDENCY: CURL ::: ]"
curl_done_msg="  [ ::: INSTALLED DEPENDENCY: CURL. :::]"
command -v curl >/dev/null 2>&1 || { echo ""; echo "$curl_missing_msg"
$_doso $add $_y curl >/dev/null 2>&1; echo ""; } #dependency check 4 curl
echo ""; echo "$zt_install_msg0"; echo ""
ZTinstall=$(curl -s https://install.zerotier.com | $_doso bash) # default install through official script
echo ""; echo "$ZT_done_msg"; echo ""; read -r -n 1 -s
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
fetch_cmd="$_doso "$_ztc" get $input_id name"
cnbf="UNABLE TO FETCH. AUTHORIZED?"
netname_error_msg="[ ERROR: NAME COULD NOT BE FETCHED. ARE YOU AUTHORIZED? ]"
echo "[ /// FETCHING NETWORK DETAILS.. ]"; echo "";
for net in {1..4}; do actual_netname=$($fetch_cmd)
	sleep 1
done
if [[ "$actual_netname" == "" ]]; then actual_netname="$cnbf"; fi
if [[ "$actual_netname" == "$cnbf" ]]; then echo ""; echo "$netname_error_msg"; echo ""; fi
# ^ if network name could not be fetched after 4 tries, update actual_netname & status_screen with: "NAME COULD NOT BE FETCHED."
# /// getting network settings / rules
allow_dns_status=$($_doso "$_ztc" get $input_id allowDNS)
allow_default_status=$($_doso "$_ztc" get $input_id allowDefault)
allow_global_status=$($_doso "$_ztc" get $input_id allowGlobal)
allow_managed_status=$($_doso "$_ztc" get $input_id allowManaged)
ip_status=$($_doso "$_ztc" get $input_id ip)
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
valid_check__input_id=$($_doso "$_ztc" "$_j" $input_id )
error_msg="[ [ERROR]: $valid_check__input_id. PRESS ANY KEY TO TRY AGAIN. ]"
if [[ "$input_id" == "q" ]] || [[ "$input_id" == "Q" ]] ; then recall__current_status; return2main_menu; fi 
# ^ ^ ^ if user enters "q / Q", recall last known network values & quit to main menu
# check if network id is invalid. if it is, echo error message, recall current status and reload ManualInput
if [[ "$valid_check__input_id" == "invalid network id" ]]; then echo "$error_msg"
echo ""; read -r -n 1 -s; recall__current_status; Logo; $action
fi
# gets triggered when user enters nothing & restores state from backup variables
if [[ "$input_id" == "" ]]; then echo "$error_msg"; echo ""; read -r -n 1 -s; recall__current_status; $action # NOTE: $action refers to the function that it was called from
fi
action=""
}
# check4invalid__saved_id <-- ( error check for: "CreateNewSave" )
function check4invalid__saved_id {
valid_check__saved_id=$($_doso "$_ztc" "$_j" $saved_id )
error_msg="[ [ERROR]: $valid_check__saved_id. PRESS ANY KEY TO TRY AGAIN. ]"
if [[ "$saved_id" == "q" ]] || [[ "$saved_id" == "Q" ]]; then recall__current_status; return2main_menu; fi 
# check if network id is invalid. if it is, echo error message, recall current status and reload CreateNewSave
if [[ "$valid_check__saved_id" == "invalid network id" ]]; then echo "$error_msg"
echo ""; read -r -n 1 -s; recall__current_status; Logo; $action; fi
action=""
}
# check4invalid__saved_alias <-- ( error check for: "LoadFromSave" & "DeleteSave" )
function check4invalid__saved_alias {
error_msg="[ ERROR: $saved_alias doesn't exist. press any key to try again. ]"
if [[ "$saved_alias" == "q" ]] || [[ "$saved_alias" == "Q" ]]; then recall__current_status; return2main_menu; fi # <-- if user enters "q", quit to main menu
if [ ! -f ~/ZTC_Save/SAVED_NETWORKS/$saved_alias.txt ]; then echo "$error_msg"; echo ""; read -r -n 1 -s; recall__current_status; Logo; $action; fi 
action=""
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
}
# ManualInput
function ManualInput {
action="ManualInput"
store__current_status
error_msg="[ ~~~ [ERROR]: ID CANNOT BE EMPTY. PRESS ANY KEY TO TRY AGAIN. ~~~ ]"
clear; Logo
echo "/// CONNECT TO NETWORK ID"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
echo "[ ~~~ paste network-id ~~~ ]"; echo ""
echo ""; read -r input_id
check4invalid__input_id; clear
echo "[ CONNECTING TO: $input_id.. ]"; echo ""
echo "$ui1"; $_doso "$_ztc" "$_j" $input_id; echo "$ui1"; echo ""
saved_id=$input_id # <-- syncs value in input_id to saved_id ( they shall always hold the same value )
saved_alias="NONE SELECTED"
fetch_network_details
echo "[ STATUS UPDATED: ]"; echo ""
status_screen
store__lcn
return2main_menu
}
# LoadFromSave
function LoadFromSave {
action="LoadFromSave"
store__current_status
cd ~/ZTC_Save/SAVED_NETWORKS
gen_alias_index_txt
echo "/// CONNECT TO SAVED NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
echo "[ SAVEFILE FOUND ]"; echo ""
echo "$ui1"; cat alias_index.txt; echo "$ui1"; echo ""
echo "[ ~~~ type network alias & press [ENTER] ~~~ ]"; echo ""
echo ""; read -r saved_alias
check4invalid__saved_alias; clear
saved_id=$(<$saved_alias.txt) # <-- loads content of .txt into saved_id.
input_id=$saved_id # <-- syncs value in saved_id to input_id
echo "[ CONNECTING TO: $saved_id / ALIAS: $saved_alias ]"; echo ""; echo "$ui1"
$_doso "$_ztc" "$_j" $saved_id # <-- connects with network id stored in saved_id.
echo "$ui1"; echo ""; fetch_network_details
echo "[ STATUS UPDATED: ]"; echo ""
cd ~/ZTC_Save/
status_screen
store__lcn
return2main_menu
}
# CreateNewSave
function CreateNewSave {
action="CreateNewSave"
store__current_status
cd ~/ZTC_Save/SAVED_NETWORKS
echo "/// CREATE NEW SAVED NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
echo "[ ~~~ paste network-id ~~~ ]"; echo ""
echo ""; read -r saved_id; check4invalid__saved_id; echo ""
echo "[ ~~~ type network alias & press [ENTER] ~~~ ]"; echo ""; read -r saved_alias; echo ""
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
# DeleteSave
function DeleteSave {
action="DeleteSave"
store__current_status
cd ~/ZTC_Save/SAVED_NETWORKS
_msg="OPERATION CANCELED."
gen_alias_index_txt
echo "/// DELETE SAVED NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
echo "$ui1"; cat alias_index.txt; echo "$ui1"; echo ""
echo "[ ~~~ type network alias & press [ENTER] ~~~ ]"; echo ""; read -r saved_alias; echo ""
check4invalid__saved_alias; echo ""; echo "ARE YOU SURE YOU WANT TO DELETE $saved_alias ?"; echo ""
echo "Y) YES"
echo "N) NO"
echo ""; read -r DeleteSave
case $DeleteSave in
	Y|y) rm "$saved_alias.txt"; echo "$saved_alias has been deleted."; gen_alias_index_txt; recall__current_status; return2main_menu ;;
	N|n) echo "$_msg"; recall__current_status; return2main_menu;;
	*) clear; DeleteSave
esac 
}
# CheckClientInfo
function CheckClientInfo {
echo "/// CHECK CLIENT INFO"
echo "~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
$_doso "$_ztc" $_i; echo ""
return2main_menu
}
# CheckConnectedNetworks
function CheckConnectedNetworks {
echo "/// LIST CONNECTED NETWORKS"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
$_doso "$_ztc" "$_lnw"; echo ""
return2main_menu
}
# CheckPeers
function CheckPeers {
echo "/// LIST CONNECTED PEERS"
echo "~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
$_doso "$_ztc" peers; echo ""
return2main_menu
}
# CheckIP
function CheckIP {
echo "/// CHECK IP ADDRESS"
echo "~~~~~~~~~~~~~~~~~~~~~"; echo ""
if_network_not_present__fail
echo IP OF SELECTED ZEROTIER NETWORK:; echo ""
$_doso "$_ztc" get $input_id ip; echo ""
return2main_menu
}
# get_net_settings 
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
#function set_net_settings {
#echo "// SET NETWORK SETTINGS FOR $input_id:"
#echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
#echo "     ( feature will be added soon )"
#return2main_menu
#} 
############################################################################
# connection_menu ( sub menu 1 )
function connection_menu {
echo "// CONNECT TO NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~"
echo "1) CONNECT VIA NETWORK ID"
echo "2) CONNECT TO SAVED NETWORK"
echo "3) CREATE NEW SAVED NETWORK"
echo "4) DELETE SAVED NETWORK"
echo "Q) RETURN TO MAIN MENU"
echo ""; read -r connection_menu
case $connection_menu in
	1) Logo; ManualInput;;
	2) Logo; LoadFromSave;;
	3) Logo; CreateNewSave;;
	4) Logo; DeleteSave;;
	q|Q) return2main_menu;;
	*) clear; Logo; connection_menu
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
echo ""; read -r status_menu
case $status_menu in
	1) Logo; CheckConnectedNetworks;;
	2) Logo; CheckPeers;;
	3) Logo; CheckClientInfo;;
	4) Logo; CheckIP;;
	q|Q) return2main_menu;;
	*) clear; Logo; status_menu
esac
}
# get_set_menu ( sub menu 3 ) ( NOTE: this menu is currently disabled / main_menu relinks to get_net_settings instead )
function get_set_menu {
echo "// GET NETWORK SETTINGS"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
if_network_not_present__fail
echo "1) GET NETWORK SETTINGS FOR $input_id" 
#echo "2) SET NETWORK SETTINGS FOR $input_id" 
echo "Q) RETURN TO MAIN MENU"
echo ""; read -r get_set_menu
case $get_set_menu in
	1) Logo; get_net_settings;;
#	2) Logo; set_net_settings;; #########
	q|Q) return2main_menu;;
	*) clear; Logo; get_set_menu
esac
}
# disconnection_menu ( sub menu 4 )
function disconnection_menu {
echo "// DISCONNECT FROM NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "1) DC FROM $input_id" 
echo "2) DC FROM ANOTHER NETWORK" 
echo "Q) RETURN TO MAIN MENU"
echo ""; read -r disconnection_menu
case $disconnection_menu in
	1) $ui1; $_doso "$_ztc" $_l $input_id; $ui1;;
	2) $_doso "$_ztc" "$_lnw"; echo ""; echo "[ ~~~ paste network-id ~~~ ]"; 
	echo ""; read -r dc_other; $ui1; $_doso "$_ztc" $_l $dc_other; $ui1;;
	q|Q) return2main_menu;;
	*) clear; Logo; disconnection_menu
esac
init_status
store__lcn
return2main_menu
}
# return2main_menu
function return2main_menu {
echo ""; echo "[ ~~~ PRESS ANY KEY TO RETURN TO MAIN MENU ~~~ ]"
echo ""; read -r -n 1 -s
main_menu
}
# main_menu
function main_menu {
Logo
echo "// MAIN MENU"
echo "~~~~~~~~~~~~~~"
echo "1) CONNECT TO NETWORK"
echo "2) CHECK STATUS"
echo "3) GET NETWORK DETAILS"
echo "4) DISCONNECT FROM NETWORK"
echo "R) REFRESH NETWORK CONNECTION"
echo "Q) EXIT"
echo ""; read -r main_menu
case $main_menu in
	1) Logo; connection_menu;;
	2) Logo; status_menu;;
	3) Logo; get_net_settings;; # get_set_menu;;
	4) Logo; disconnection_menu;;
	r|R) Logo; recall__lcn; check4invalid__input_id; fetch_network_details; main_menu;;
	q|Q) echo ""; echo "// EXIT"; exit;;
	*) main_menu
esac
}
#####################################################
# shortcuts:
_ztc="zerotier-cli"
_i="info" 
_j="join"
_l="leave"
_lnw="listnetworks"
ui1="~~~~~~~~~~~~~~~~~~" 
#########################
#	ALPINE INTEGRATION
#########################
function compile4alpine {
  #================================================
  # Project: ZeroTier_AutoCompile-Alpine.sh
  # Author:  ConzZah / ©️ 2024
  # Last Modification: 23.06.2024 / 13:32 [v0.1]
  #================================================
wd=$(pwd); cd /home/$USER; mkdir -p ZeroTier_AutoCompile-Alpine; cd ZeroTier_AutoCompile-Alpine
doas apk add git wget build-base clang rust cargo make linux-headers openssl-dev nodejs nodejs-dev # installs dependencies for zerotier compilation
git clone https://github.com/zerotier/ZeroTierOne; cd ZeroTierOne # clones zerotier-one from github
doas make && echo ""; echo "DONE COMPILING!"; echo "" # runs make and shows message when done
doas make install && echo ""; echo "DONE INSTALLING, SETTING UP INIT SCRIPT.."; echo "" # runs make install and shows message when done
cd /home/$USER; doas rm -rf ZeroTier_AutoCompile-Alpine # removes working dir to save space since the binaries are compiled & installed by that point
cd /etc/init.d; doas wget -q -O zerotier-one https://raw.githubusercontent.com/ConzZah/ZeroTier_AutoCompile-Alpine/main/zerotier-one.initd; doas chmod 755 zerotier-one; cd $wd # installs init script
echo "tun" > zerotier-one.conf; doas mv -f zerotier-one.conf /usr/lib/modules-load.d/; doas modprobe tun; lsmod | grep tun
doas rc-update add zerotier-one; doas rc-service zerotier-one start # adds zerotier-one service and starts it. 
doas zerotier-one -d >/dev/null 2>&1; sleep 3; echo ""; echo ""; echo "[ PRESS ANY KEY TO START ZTC ]"; echo ""; read -r -n 1 -s
}
_y="-y"
_doso="sudo"
add_alpine="apk add"
is_alpine=$(uname -v|grep -o -w Alpine)
if [[ "$is_alpine" == "Alpine" ]]; then add="$add_alpine"; _doso="doas"; fi
#####################################################
# /// everything is set /// starting launch prep ///
#####################################################
# checks if zerotier is installed & if alias_index.txt exists - if not present, script will call InitialRun.
clear; check4installed_zerotier_client; if [ ! -f ~/ZTC_Save/SAVED_NETWORKS/alias_index.txt ]; then echo "[ ERROR ]: NO SAVEDATA FOUND.  ]"; echo ""; InitialRun; fi
cd ~/ZTC_Save # <-- cd's to save directory
init_status; recall__lcn; main_menu # <--  ( //LAUNCH\\ )