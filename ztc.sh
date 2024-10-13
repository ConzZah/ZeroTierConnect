#!/usr/bin/env bash
  #===============================================
  # Project: zerotier-connect_v0.7.2 / patch #2 
  # Author:  ConzZah / ©️ 2024
  # Last Modification: 13.10.24 / 09:15 [v0.7.2]
  # https://github.com/ConzZah/ZeroTierConnect
  #===============================================
# check4installed_zerotier_client <-- ( checks if zerotier is installed & calls pingtest )
function check4installed_zerotier_client {
error_msg="[ [ERROR]: ZEROTIER COULD NOT BE FOUND. ]"; zt_install_check=$($_doso $_ztc $_i); clear; pingtest
if [[ "$zt_install_check" == "" ]]; then echo "$error_msg"; if [ ! -f /usr/sbin/zerotier-one ]; then echo ""; ask2install_zerotier_client; fi; fi
}
# ask2install_zerotier_client <--  ( asks user if they want to install the zerotier client if it hasnt been detected. )
function ask2install_zerotier_client {
echo "Y) INSTALL ZEROTIER"; echo "Q) EXIT"; echo ""; read -r ask2installZT
case $ask2installZT in
	Y|y) zt_installer;;
	q|Q) echo ""; echo "// EXIT"; exit;;
	*) clear; check4installed_zerotier_client
esac
}
# zt_installer <-- ( downloads & installs zerotier client binarys through https://www.zerotier.com/download/. Also, if you're on Alpine Linux, it will ask you to build from source. )
function zt_installer {
if [[ "$pm" == "apk" ]]; then clear; echo "ALPINE DETECTED"; echo ""; ask2compile4alpine; fi
_dlmsg="[ ::: DOWNLOADING & INSTALLING ZEROTIER, PLEASE WAIT.. ::: ]"; ZT_done_msg="[ ZEROTIER INSTALL FINISHED. PRESS ANY KEY TO LAUNCH ZTC ]"
echo ""; echo "$_dlmsg"; echo ""; ZTinstall=$(curl -s https://install.zerotier.com | $_doso bash) # default install through official script
echo ""; echo "$ZT_done_msg"; echo ""; read -r -n 1 -s; _launch
}
function ask2compile4alpine {
echo "Do you want to start building the ZeroTier Client from Source?"; echo ""; echo "( BE AWARE: This could take some time."; echo ""
echo "Y) BUILD FROM SOURCE"; echo "Q) EXIT"; read -r ask2compile4alpine
case $ask2compile4alpine in 
	Y|y) echo ""; compile4alpine;;
	q|Q) echo ""; echo "// EXIT"; exit;;
	*) clear; echo "ALPINE DETECTED"; echo ""; ask2compile4alpine
esac
}
function compile4alpine {
wd=$(pwd); cd /$_home; mkdir -p ZeroTier_AutoCompile-Alpine; cd ZeroTier_AutoCompile-Alpine # creates build directory
doas apk add git wget build-base clang rust cargo make linux-headers openssl-dev # installs dependencies for zerotier compilation
git clone https://github.com/zerotier/ZeroTierOne; cd ZeroTierOne # clones zerotier-one from github
doas make && echo ""; echo "DONE COMPILING!"; echo ""; echo "ENTER PASSWORD TO INSTALL ZEROTIER"; echo ""; # runs make and shows message when done
doas make install && echo ""; echo "DONE INSTALLING, SETTING UP INIT SCRIPT.."; echo "" # runs make install and shows message when done
cd /$_home; doas rm -rf ZeroTier_AutoCompile-Alpine # removes working dir to save space 
cd /etc/init.d; doas wget -q -O zerotier-one https://raw.githubusercontent.com/ConzZah/ZeroTier_AutoCompile-Alpine/main/zerotier-one.initd; doas chmod 755 zerotier-one; cd $wd # installs init script
echo "tun" > zerotier-one.conf; doas mv -f zerotier-one.conf /usr/lib/modules-load.d/; doas modprobe tun; lsmod | grep tun
doas rc-update add zerotier-one; doas rc-service zerotier-one start # adds zerotier-one service and starts it. 
doas zerotier-one -d >/dev/null 2>&1; sleep 3; echo ""; echo ""; echo "[ PRESS ANY KEY TO START ZTC ]"; echo ""; read -r -n 1 -s; _launch
}
# Logo
function Logo { clear
echo "   .:*======= ConzZah's =======*:."
echo " $t1$t1"
echo " *     ZEROTIER-CONNECT v0.7.2      *"
echo " $t1$t1"; status_screen
}
# status_screen
function status_screen {
cnbf="UNABLE TO FETCH. AUTHORIZED?"; if [[ "$actual_netname" == "$cnbf" ]]; then nameclr="$red"; else nameclr="$_cr"; fi; echo ""
echo "$t1$t1$t1"
echo -e "[ NETWORK ID    : $input_id ]"
echo -e "[ NETWORK NAME  : $nameclr$actual_netname$_cr ]"  
echo -e "[ NETWORK ALIAS : $saved_alias ]"
echo "$t1$t1$t1"; echo ""
}
# init_status
function init_status { input_id="/"; saved_alias="/"; actual_netname="/";}
# store__current_status <-- stores current status in backup variables so we can reload them in case a user error occurs.
function store__current_status {
input_id__current=$input_id
saved_alias__current=$saved_alias
actual_netname__current=$actual_netname
}
# recall__current_status <-- loads status values, previously stored with "store__current_status", back into their actual variables.
function recall__current_status {
input_id=$input_id__current
saved_alias=$saved_alias__current
actual_netname=$actual_netname__current
}
# store__lcn <-- stores last connected network values in .txt files to reload them when needed.
function store__lcn {
if [ ! -d $_home/ZTC_Save/.LCN ]; then mkdir .LCN; fi; cd $_home/ZTC_Save/.LCN
echo "$input_id" > .lcn__input_id.txt
echo "$saved_alias" > .lcn__saved_alias.txt
echo "$actual_netname" > .lcn__actual_netname.txt
cd $_home/ZTC_Save/
}
# recall__lcn <-- recalls last connected network values into their variables
function recall__lcn {
if [ ! -d $_home/ZTC_Save/.LCN ]; then mkdir .LCN; init_status; fi; cd $_home/ZTC_Save/.LCN
input_id=$(<.lcn__input_id.txt)
saved_alias=$(<.lcn__saved_alias.txt)
actual_netname=$(<.lcn__actual_netname.txt)
cd $_home/ZTC_Save/
}
# fetch_network_details <-- fetches network name, rules & ip 
function fetch_network_details {
fetch_cmd="$_doso $_ztc get $input_id name"
echo "[ /// FETCHING NETWORK DETAILS.. ]"; echo ""; for net in {1..4}; do actual_netname=$($fetch_cmd); sleep 0.5; done # <-- fetching name 4 times 
if [[ "$actual_netname" == "" ]]; then actual_netname="$cnbf"; fi
# ^ if network name could not be fetched after 4 tries, update actual_netname & status_screen with: "NAME COULD NOT BE FETCHED."
allow_dns_status=$($_doso $_ztc get $input_id allowDNS); allow_default_status=$($_doso $_ztc get $input_id allowDefault)
allow_global_status=$($_doso $_ztc get $input_id allowGlobal); allow_managed_status=$($_doso $_ztc get $input_id allowManaged); ip_status=$($_doso $_ztc get $input_id ip)
}
# if_network_not_present__fail <-- will get triggered if $input_id is set to "/" or none at all.
function if_network_not_present__fail {
error_msg="[ ~~~ [ERROR]: NO NETWORK SELECTED, TRY AGAIN. ~~~ ]"
if [[ "$input_id" == "" || "$input_id" == "/" ]]; then echo "$error_msg"; echo ""; [ ! -z $_args ] && exit; _r2main="manual"; return2main_menu; fi
}
# check4invalid__id ( check if user input given is an actual network id )
function check4invalid__id {
error_msg="[ ERROR: INVALID NETWORK ID. PRESS ANY KEY TO TRY AGAIN. ]"
_check_id=$($_doso $_ztc $_j $input_id) # <-- checks if $input_id is valid by trying to join it  
if [[ "$input_id" =~ ^(q|Q)$ ]]; then recall__current_status; return2main_menu; fi  # <-- quit to main_menu during text entry: if user enters "q / Q", recall last known network values & quit to main menu
if [[ "$_check_id" == "404"* || "$_check_id" == "invalid network id" ]]; then echo "$error_msg"; echo ""; read -r -n 1 -s; recall__current_status; Logo; $back2; fi # NOTE: $back2 refers to the function that it was called from.
} 
# check4invalid__alias 
function check4invalid__alias {
_empty="[ ERROR: YOU ENTERED NOTHING. PRESS ANY KEY TO TRY AGAIN. ]"; doesnt_exist="[ ERROR: $saved_alias DOESN'T EXIST. PRESS ANY KEY TO TRY AGAIN. ]"
if [ ! -z "$initial_run" ] && [[ "$saved_alias" =~ ^(q|Q)$ ]]; then clear; InitialRun; fi
if [[ "$saved_alias" =~ ^(q|Q)$ ]]; then recall__current_status; return2main_menu; fi # <-- if user enters "q", quit to main menu
if [[ "$saved_alias" == "" ]]; then echo "$_empty"; echo ""; read -r -n 1 -s; recall__current_status; Logo; $back2; fi # <-- if user enters nothing, shows error and lets them try again
if [ ! -f $_home/ZTC_Save/SAVED_NETWORKS/$saved_alias.txt ]; then echo "$doesnt_exist"; echo ""; read -r -n 1 -s; recall__current_status; Logo; $back2; fi # <-- if input does not match any saved networks, shows error and lets them try again
}
# pingtest <-- checks if your machine is connected to the internet by pinging zerotier.com before starting ztc
function pingtest {
echo "CHECKING NETWORK CONNECTION.."; echo ""; if ping -q -i 0.5 -c 2 -w 7 zerotier.com > /dev/null 2>&1; then echo "ONLINE"; clear; else 
clear; echo "YOU'RE OFFLINE. CHECK YOUR CONNECTION & TRY AGAIN."; echo ""; echo "EXITING IN 3 SECONDS.."; echo ""; sleep 3; exit; fi; }
# check4save <-- checks if savedata exists by checking if savedir is empty.
function check4save { if [ -z "$( ls "$_home/ZTC_Save/SAVED_NETWORKS/" )" ]; then initial_run="1"; InitialRun; fi; }
# InitialRun <--- (only gets called if no savefile is detected)
function InitialRun { cd /$_home; mkdir -p $_home/ZTC_Save/SAVED_NETWORKS; cd $_home/ZTC_Save/SAVED_NETWORKS; init_status; Logo; Connect; }
# ztc_help <-- ZTC help / manual page
function ztc_help { cd $_home/ZTC_Save/; wget -q https://github.com/ConzZah/ZeroTierConnect/raw/main/ztc_helppage.txt; less ztc_helppage.txt; rm ztc_helppage.txt; [ ! -z $_args ] && exit; return2main_menu; }
# gen_alias_index_txt <-- generates alias_index.txt by displaying the contents of each savefile (the network id) alongside the filename (the alias).
function gen_alias_index_txt {
_index="alias_index.txt"; _desc="       ID          ALIAS"; _error="NO NETWORKS SAVED YET."
if [ -z "$( ls "$_home/ZTC_Save/SAVED_NETWORKS/" )" ]; then _desc="$_error"; fi; echo "$_desc"; echo "" # <-- if savefolder is empty, assign $_error to _desc
for network_alias in *.txt; do
if [[ "$_desc" == "$_error" ]]; then break; fi
network_id=$(cat "$network_alias"); echo "$network_id   $network_alias"|cut -d'.' -f1 >> raw_$_index
done; if [ -f raw_$_index ]; then sed '/^$/d' raw_$_index > $_index; cat $_index; echo ""; rm $_index; rm raw_$_index; fi
}
# Connect
function Connect {
back2="Connect"; store__current_status; cd $_home/ZTC_Save/SAVED_NETWORKS; ask4input="[ ~~~ type / paste network ID or alias ~~~ ]"
if [[ "$initial_run" == "1" ]]; then ask4input="WELCOME TO ZTC, ENTER A NETWORK ID TO GET STARTED."; fi
echo "/// CONNECT TO ZEROTIER NETWORK "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
gen_alias_index_txt; echo "$ask4input"; echo ""; read -r input_id
_id () {
check4invalid__id; savecheck=$(find -maxdepth 1 -name '*.txt' -exec grep -l $input_id {} +); sc="sc.txt" # ( check if entered network id is already saved and if so, load corresponding alias )
if [[ $savecheck == *"./"* ]]; then echo "$savecheck" > $sc; sed -i "s#.txt##g" $sc; sed -i "s#./##g" $sc; saved_alias=$(<$sc); rm $sc; # <-- ( loads found alias into $saved_alias )
else echo ""; echo "[ ~~~ enter alias for $input_id, to save this network ~~~ ]"; echo ""; read -r saved_alias; echo "" # <-- ( if the id should not be found in any savefile, prompt user to enter an alias & create new save entry. )
echo "$input_id" > $saved_alias.txt; echo "[ .:SAVE CREATED:. ]"; initial_run=""; sleep 0.4; fi # <-- stores network id in .txt <-- ( writes save )
}
_alias () {
saved_alias=$input_id; check4invalid__alias # if alias was entered, check if it exists.
input_id=$(<$saved_alias.txt) # <-- loads content of $saved_alias.txt into $input_id. <-- ( loads save )
check4invalid__id # <-- makes sure that the given network id is valid, else complains.
}
if [[ ${#input_id} -eq 16 ]]; then _id; else _alias; fi
clear; echo "[ CONNECTING TO NETWORK ID: $input_id / ALIAS: $saved_alias ]"; echo ""; echo "$t1"; $_doso $_ztc $_j $input_id; echo "$t1"; echo "" # <-- connects 
fetch_network_details; cd $_home/ZTC_Save/; store__lcn; store__current_status; echo "$_dmsg"; echo ""
return2main_menu
}
# reconnect <-- refreshes connection to the currently selected network.
function reconnect { if_network_not_present__fail; recall__lcn; check4invalid__id; fetch_network_details; store__lcn; echo "$_dmsg"; echo ""; return2main_menu ;}
# disconnect
function disconnect {
if_network_not_present__fail; store__current_status
echo "// DISCONNECT FROM NETWORK"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
echo "DISCONNECT FROM $input_id ?"; echo ""; echo "[ Y / N ]"; echo ""; read -r disconnect
case $disconnect in
	y|Y) echo ""; echo "$t1"; $_doso $_ztc $_l $input_id; echo "$t1"; init_status; store__lcn; store__current_status; return2main_menu;;
	N|n) echo ""; echo "CANCELED."; echo ""; recall__current_status; return2main_menu;;
	q|Q) return2main_menu;;
	*) Logo; disconnect
esac
init_status; store__lcn; return2main_menu
}
# DeleteSave
function DeleteSave {
back2="DeleteSave"; store__current_status; cd $_home/ZTC_Save/SAVED_NETWORKS
echo "/// DELETE SAVE ENTRY"
echo "~~~~~~~~~~~~~~~~~~~~~~"; echo ""
gen_alias_index_txt; echo ""; echo "[ ~~~ type network alias & press [ENTER] ~~~ ]"; echo ""; read -r saved_alias; echo ""
check4invalid__alias; echo ""; echo "ARE YOU SURE YOU WANT TO DELETE $saved_alias ?"; echo ""; echo "[ Y / N ]"; echo ""; read -r DeleteSave
case $DeleteSave in
	Y|y) _dl=$(<$saved_alias.txt); $_doso $_ztc $_l $_dl >/dev/null 2>&1; rm "$saved_alias.txt"; echo ""; echo "$saved_alias has been deleted."; recall__current_status; echo ""
	if [[ "$_dl" == "$input_id" ]]; then init_status; store__lcn; store__current_status; _dl=""; fi; _r2main="manual"; return2main_menu ;;
	N|n) echo ""; echo "CANCELED."; echo ""; recall__current_status; return2main_menu;;
	*) Logo; DeleteSave
esac 
}
# nwqr <-- creates qr code for currently selected network id ( uses local qrencode instead of qrenco.de as of v0.7.2 )
function nwqr { 
if_network_not_present__fail; echo "QR CODE FOR NETWORK ID: $input_id"; echo "";
_nwqr="https://joinzt.com/addnetwork?nwid=$input_id&v=1"
qrencode -m 2 -t utf8 <<< "$_nwqr"; echo ""; nwqr=""
[ ! -z $_args ] && exit; _r2main="manual"; return2main_menu
}
# CheckClientInfo
function CheckClientInfo {
echo "/// CLIENT INFO"
echo "~~~~~~~~~~~~~~~~~"; echo ""
IFS=" " read -r -a _info <<< "$($_doso $_ztc $_i)" # <-- creates array, (uses spaces as seperator), and writes output of "sudo/doas zerotier-cli info" to said array 
echo "ZEROTIER VERSION: ${_info[3]}"; echo ""
echo "CLIENT ID: ${_info[2]}"; echo ""
echo "STATE: ${_info[4]}"; echo ""; [ ! -z $_args ] && exit; _r2main="manual"; return2main_menu; }
# CheckConnectedNetworks
function CheckConnectedNetworks {
echo "/// CONNECTED NETWORKS"
echo "~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
$_doso $_ztc $_lnw|sed 's#200 listnetworks##g'; echo ""; _r2main="manual"; return2main_menu; }
# CheckConnectedPeers
function CheckConnectedPeers {
echo "/// CONNECTED PEERS"
echo "~~~~~~~~~~~~~~~~~~~~~"
$_doso $_ztc peers|sed 's#200 peers##g'; echo ""; _r2main="manual"; return2main_menu; }
# get_net_info
function get_net_info {
if_network_not_present__fail
echo "// NETWORK INFO FOR $input_id:"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"; echo ""
fetch_network_details
echo "Network Name: $actual_netname"; echo ""
echo "Network ID: $input_id"; echo ""
echo "Network IP: $ip_status"; echo ""
echo "#### NETWORK RULES: ####"; echo ""
echo "Allow DNS: $allow_dns_status"; echo ""
echo "Allow Default: $allow_default_status"; echo ""
echo "Allow Global: $allow_global_status"; echo ""
echo "Allow Managed: $allow_managed_status"; echo ""
[ ! -z $_args ] && exit; _r2main="manual"; return2main_menu
}
# return2main_menu
function return2main_menu {
# defaults to auto (0.7s wait time & instant transition to main_menu)
# ^ unless _r2main="manual" is specified BEFORE return2main_menu (see get_net_info for example)
_msg_auto="[ ~~~ RETURNING TO MAIN MENU.. ~~~ ]"; _msg_manual="[ ~~~ PRESS ANY KEY TO RETURN TO MAIN MENU ~~~ ]"
if [[ "$_r2main" == "" ]]; then _r2main="sleep 0.7"; _msg="$_msg_auto"; fi # <-- auto 
if [[ "$_r2main" == "manual" ]]; then _r2main="read -r -n 1 -s"; _msg="$_msg_manual"; fi # <-- manual
echo "$_msg"; $_r2main
_msg=""; _r2main="" # <-- initializes to avoid conflicts
main_menu
}
# main_menu
function main_menu {
Logo; back2=""
echo "// MAIN MENU"
echo "~~~~~~~~~~~~~~"
echo "C)  CONNECT TO NETWORK"
echo "DC) DISCONNECT FROM NETWORK"
echo "R)  REFRESH NETWORK CONNECTION"
echo "I)  GET INFO ABOUT CURRENT NETWORK"
echo "LP) DISPLAY CONNECTED PEERS"
echo "LN) DISPLAY CONNECTED NETWORKS"
echo "CI) GET INFO ABOUT ZT CLIENT"
echo "H)  HELP"
echo "Q)  QUIT"
echo ""; read -r main_menu
case $main_menu in
	c|C) Logo; Connect;;
	dc|DC) Logo; disconnect;;
	r|R) Logo; reconnect;;
	i|I|netstat) Logo; get_net_info;;
	lp|LP) Logo; CheckConnectedPeers;;
	ln|LN|listnetworks) Logo; CheckConnectedNetworks;;
	ci|CI|info) Logo; CheckClientInfo;;
	dl|DL|delete) Logo; DeleteSave;;
	qr|QR) Logo; nwqr;;
	h|H|help) Logo; ztc_help;;
	q|Q|exit) echo ""; echo "// EXIT"; exit;;
	*) main_menu
esac
}
# important vars
_doso="sudo"
_home="/home/$USER"
_ztc="zerotier-cli"
_i="info"
_j="join"
_l="leave"
_lnw="listnetworks"
_dmsg="[ ~~~ DONE ~~~ ]"
t1="~~~~~~~~~~~~~~~~~~"
# check_deps <-- determine package manager & check for missing dependencies (curl & qrencode)
function check_deps {
clear; echo "INSTALLING MISSING DEPENDENCIES.."; echo ""; _qrencode="qrencode"
i=0; bin=("apt" "apk" "dnf" "yum" "pacman" "zypper" "brew"); pm="" 
while [ $i -lt ${#bin[@]} ]; do
if type -p "${bin[$i]}" > /dev/null; then pm="${bin[$i]}"; _add="$pm install"; break; fi
((i++))
done
if [[ "$pm" == "apk" ]]; then _doso="doas"; _add="apk add"; _qrencode="libqrencode-tools"; fi
if [[ "$pm" == "pacman" ]]; then _add="pacman -S"; fi
(! type -p curl >/dev/null && $_doso $_add curl)
(! type -p qrencode  >/dev/null && $_doso $_add $_qrencode)
}
_cr='\033[0m'; red='\033[0;31m'; green='\033[0;32m'; blue='\033[0;34m' # <-- basic colors
if [ "$EUID" -eq 0 ]; then _home="/root"; fi # <-- if user is root, changes $_home from "/home/$USER" to "/root" ( this also means that root has it's own savedir )
##########  ARGS  ##########
# (work in progress)
if [[ "$1" =~ ^(c|C|j|J|join)$ ]]; then $_doso $_ztc $_j "$2"; exit; fi # <-- join
if [[ "$1" =~ ^(dc|DC|l|L|leave)$ ]]; then $_doso $_ztc $_l "$2"; exit; fi # <-- leave
if [[ "$1" =~ ^(ci|CI|info)$ ]]; then _args="1"; CheckClientInfo; exit; fi # <-- info
if [[ "$1" =~ ^(ln|LN|listnetworks)$ ]]; then $_doso $_ztc $_lnw; exit; fi # <-- listnetworks
if [[ "$1" =~ ^(lp|LP|listpeers)$ ]]; then $_doso $_ztc listpeers; exit; fi # <-- listpeers
if [[ "$1" =~ ^(g|G|get)$ ]]; then $_doso $_ztc get "$2" "$3"; exit; fi # <-- get
if [[ "$1" =~ ^(s|S|set)$ ]]; then $_doso $_ztc set "$2" "$3"; exit; fi # <-- set
if [[ "$1" =~ ^(qr|QR)$ ]]; then _args="1"; input_id=$2; nwqr; exit; fi # <-- qr code generation 
if [[ "$1" =~ ^(i|I)$ ]]; then _args="1" input_id=$2; get_net_info; exit; fi # <-- network info
if [[ "$1" =~ ^(h|H|help)$ ]]; then _args="1"; ztc_help; exit; fi # <-- help page
# _launch
function _launch { clear; check_deps; check4installed_zerotier_client; check4save; init_status; recall__lcn; main_menu; }; _launch  # <--  ( //LAUNCH\\ )
