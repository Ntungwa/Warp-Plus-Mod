#!/bin/bash
#################### Warp-Plus v1.2.6 @ github.com/Ntungwa ##############################################
[[ $EUID -ne 0 ]] && { echo "not root!"; exec sudo "$0" "$@"; }
msg()     { echo -e "\e[1;37;40m $1 \e[0m";}
msg_ok()  { echo -e "\e[1;32;40m $1 \e[0m";}
msg_err() { echo -e "\e[1;31;40m $1 \e[0m";}
msg_inf() { echo -e "\e[1;36;40m $1 \e[0m";}
msg_war() { echo -e "\e[1;33;40m $1 \e[0m";}
hrline() { printf '\033[1;35;40m%s\033[0m\n' "$(printf '%*s' "${COLUMNS:-$(tput cols)}" '' | tr ' ' "${1:--}")"; }
echo; ############## Asciiart.eu@Cyberlarge ################
msg_inf ' _     _ _     _ _____      _____   ______   _____ '
msg_inf '  \___/  |     |   |   ___ |_____] |_____/  |     |'
msg_inf ' _/   \_ |_____| __|__     |       |     \_ |_____|';
hrline
##################################Variables###############################################################
WarpCfonCountry="";WarpLicKey="";CleanKeyCfon="";TorCountry="";Secure="no";ENABLEUFW="";VERSION="last";CountryAllow="XX"
################################Get arguments#############################################################
while [ "$#" -gt 0 ]; do
  case "$1" in
  	-country) CountryAllow="$2"; shift 2;;
  	-xuiver) VERSION="$2"; shift 2;;
  	-ufw) ENABLEUFW="$2"; shift 2;;
	-secure) Secure="$2"; shift 2;;
	-TorCountry) TorCountry="$2"; shift 2;;
	-WarpCfonCountry) WarpCfonCountry="$2"; shift 2;;
	-WarpLicKey) WarpLicKey="$2"; shift 2;;
	-CleanKeyCfon) CleanKeyCfon="$2"; shift 2;;
	-RandomTemplate) RNDTMPL="$2"; shift 2;;
	-Uninstall) UNINSTALL="$2"; shift 2;;
	-panel) PNLNUM="$2"; shift 2;;
	-subdomain) domain="$2"; shift 2;;
	-cdn) CFALLOW="$2"; shift 2;;
    *) shift 1;;
  esac
done
#############################################################################################################
service_enable() {
for service_name in "$@"; do
	systemctl is-active --quiet "$service_name" && systemctl stop "$service_name" > /dev/null 2>&1
	systemctl daemon-reload	> /dev/null 2>&1
	systemctl enable "$service_name" > /dev/null 2>&1
	systemctl start "$service_name" > /dev/null 2>&1
done
}
##############################WARP/Psiphon Change Region Country ############################################
if [[ -n "$WarpCfonCountry" || -n "$WarpLicKey" || -n "$CleanKeyCfon" ]]; then
WarpCfonCountry=$(echo "$WarpCfonCountry" | tr '[:lower:]' '[:upper:]')
cfonval=" --cfon --country $WarpCfonCountry";
[[ "$WarpCfonCountry" == "XX" ]] && cfonval=" --cfon --country ${Random_country}"
[[ "$WarpCfonCountry" =~ ^[A-Z]{2}$ ]] || cfonval="";
wrpky=" --key $WarpLicKey";[[ -n "$WarpLicKey" ]] || wrpky="";
[[ -n "$CleanKeyCfon" ]] && { cfonval=""; wrpky=""; }
######
cat > /etc/systemd/system/warp-plus.service << EOF
[Unit]
Description=warp-plus service
After=network.target nss-lookup.target

[Service]
WorkingDirectory=/etc/warp-plus/
ExecStart=/etc/warp-plus/warp-plus --scan${cfonval}${wrpky}
ExecStop=/bin/kill -TERM \$MAINPID
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF
######
rm -rf ~/.cache/warp-plus
service_enable "warp-plus"; 
msg "\nEnter after 10 seconds:\ncurl --socks5-hostname 127.0.0.1:8086 https://ipinfo.io/json/\n"
msg_inf "warp-plus settings changed!"
exit 1
fi
############################################Warp Plus (MOD)#############################################
systemctl stop warp-plus > /dev/null 2>&1
rm -rf ~/.cache/warp-plus /etc/warp-plus/
mkdir -p /etc/warp-plus/
chmod 777 /etc/warp-plus/
## Download Cloudflare Warp Mod (wireguard)
warpPlusDL="https://github.com/bepass-org/warp-plus/releases/latest/download/warp-plus_linux"

case "$(uname -m | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')" in
	x86_64 | amd64) wppDL="${warpPlusDL}-amd64.zip" ;;
	aarch64 | arm64) wppDL="${warpPlusDL}-arm64.zip" ;;
	armv*) wppDL="${warpPlusDL}-arm7.zip" ;;
	mips) wppDL="${warpPlusDL}-mips.zip" ;;
	mips64) wppDL="${warpPlusDL}-mips64.zip" ;;
	mips64le) wppDL="${warpPlusDL}-mips64le.zip" ;;
	mipsle*) wppDL="${warpPlusDL}-mipsle.zip" ;;
	riscv*) wppDL="${warpPlusDL}-riscv64.zip" ;;
	*) wppDL="${warpPlusDL}-amd64.zip" ;;
esac  

wget --quiet -P /etc/warp-plus/ "${wppDL}" || curl --output-dir /etc/warp-plus/ -LOs "${wppDL}" 
find "/etc/warp-plus/" -name '*.zip' | xargs -I {} sh -c 'unzip -d "$0" "{}" && rm -f "{}"' "/etc/warp-plus/"
cat > /etc/systemd/system/warp-plus.service << EOF
[Unit]
Description=warp-plus service
After=network.target nss-lookup.target

[Service]
WorkingDirectory=/etc/warp-plus/
ExecStart=/etc/warp-plus/warp-plus
ExecStop=/bin/kill -TERM \$MAINPID
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF
