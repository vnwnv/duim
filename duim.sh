#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/root/.acme.sh
export PATH

#Red="\\033[31m";
#Green="\\033[32m";
#Yellow="\\033[33m";
#End_color="\\033[0m";

Script_version="0.0.1";
Script_config_folder="/usr/local/etc/duimscript";
Script_db="/usr/local/etc/duimscript/data.json";

##TODO:
#path冲突检测
#change Aria2_config_url!
#support install without domain
#use json config file to install
#Statistics data download/upload/disk use/.etc
#autoremove
#dns ssl
#sync syncthing/upload to OneDrive/.etc
author()
{
	info_g "
 #  DUIM Script Powered By:
 #   _    __ ____ _   __ ______ ______
 #  | |  / //  _// | / // ____// ____/
 #  | | / / / / /  |/ // /    / __/   
 #  | |/ /_/ / / /|  // /___ / /___   
 #  |___//___//_/ |_/ \____//_____/   
 #  
 #  Author:	Vince
 #  Website:	https://www.vincehut.top
 #  Note:	Downloader and UI
 #              Install and Mangement
 #              All in One Script\U1F680
 "
}

check_relay()
{
    info_g "Recommend run this script in terminal multiplexer like screen and tmux"
    info_ly "This script need a fresh system!"
    info_m "\nDO NOT RUN ON PROCTION ENVIRONMENT!"
    info_m "\nUSE \"sudo\" NOT USE ROOT DIRECTLY!"
    info_ly "I'm sure to continue(y/N)"
    chioce_default_no
    if [ "$EUID" -ne 0 ]
    then
        info_r "Please use sudo!"
        exit 1
    fi
    if [[ $EUID = "$UID" && "$SUDO_USER" = "" ]]
    then
        info_r "You shouldn't use root directly!"
        exit 1
    fi
    info_g "Account check passed!\U1F389"
    info_g "Start check and install relay"
    apt update
    command_check_install jq
    command_check_install curl
    command_check_install unzip
    command_check_install "nginx" "systemctl enable nginx --now && rm -f /etc/nginx/sites-enabled/default"
    if [ ! -d "$Script_config_folder" ];
    then
        mkdir $Script_config_folder
        touch $Script_db
    fi
    if command_check acme.sh;
    then
        read -p "$(info_ly "SSL needs ACME.sh, install it? (Y/n)")" -r answer
        if [[ "$answer" = "n" ]] || [[ "$answer" =  "no" ]] || [[ "$answer" = "NO" ]] || [[ "$answer" = "N" ]];
        then
            info_ly "ACME.sh will not install"
        else
            read -p "$(info_g "ACME.sh needs your E-mail\n Please input ")" -r SSL_email
            curl https://get.acme.sh | sh -s email="$SSL_email"
            /root/.acme.sh/acme.sh --upgrade --auto-upgrade
        fi
    fi
}

set_default()
{
    #TODO proxy
    Aria2_config_url="https://github.com/P3TERX/aria2.conf/raw/master/aria2.conf"
    AriaNg_api="https://api.github.com/repos/mayswind/AriaNg/releases/latest"
    AriaNg_version=$(curl -L ${AriaNg_api} | jq -r .tag_name)
    AriaNg_download_url=https://github.com/mayswind/AriaNg/releases/download/${AriaNg_version}/AriaNg-${AriaNg_version}.zip
}

menu()
{
    info_normal "
   ------------------------------------------------
   |              DUIM Script v$Script_version              |
   |----------------------------------------------| 
   | About shell\U1F4C4                                |
   |----------------------------------------------|
   | 0 Update shell script                        |
   |----------------------------------------------|
   | Install\U2728                                    |
   |----------------------------------------------|
   | 1. Install Aria2 (Nginx reverse proxy)       |
   | 2. Install AriaNg                            |
   | 3. Install Filebrowser (Nginx reverse proxy) |
   | 4. Enable Nginx autoindex (Not finished)     |
   |----------------------------------------------|
   | Security\U1F512                                   |
   |----------------------------------------------|
   | 5. Get SSL for Aria2                         |
   | 6. Get SSL for AriaNg                        |
   | 7. Get SSL for Filebrowser                   |
   | 8. Use IP White List (Not finished)          |
   |----------------------------------------------|
   | Edit config\U1F4C2                                |
   |----------------------------------------------|
   | 9. Edit Aria2 config                         |
   | 10. Edit Filebrowser config                  |
   | 11. Edit Nginx config                        |
   |----------------------------------------------|
   | Tracker\U1F310                                    |
   |----------------------------------------------|
   | 12. Auto update trackers                     |
   |----------------------------------------------|
   | Status\U1F50D                                     |
   |----------------------------------------------|
   | 13. Show status info                         |
   ------------------------------------------------
"
    read -r option
    case $option in
        0)
        ;;
        1)
        Install_aria2
        ;;
        2)
        install_ariang
        ;;
        3)
        install_filebrowser
        ;;
        4)
        ;;
        5)
        domain_detect
        get_ssl_file "$Aria2_domain" Aria2
        ;;
        6)
        domain_detect
        get_ssl_file "$Ariang_domain" AriaNg
        ;;
        7)
        domain_detect
        get_ssl_file "$Filebrowser_domain" Filebrowser
        ;;
        8)
        ;;
        9)
        menu_extend_9
        ;;
        10)
        menu_extend_10
        ;;
        11)
        menu_extend_11
        ;;
        12)
        ;;
        13)
        ;;
        *)
        info_r "invalid input!"
    esac
}

menu_extend_9()
{
    #TODO:
    #4. Edit Aria2 PATH (local)
    #5. Edit Aria2 PATH (Nginx)
    info_normal "
    1. Edit Aria2 RPC secret
    2. Edit Aria2 RPC port (local port)
    3. Edit Aria2 RPC port (Nginx port)
    4. Edit Aria2 download location
    5. Edit config manually
    6. Back
    "
    read -r option
    case $option in
        1)
        ;;
        2)
        ;;
        3)
        ;;
        4)
        ;;
        *)
        info_r "invalid input!"
    esac
}

menu_extend_10()
{
    info_normal "
    1. Edit Filebrowser port (local port)
    2. Edit Filebrowser port (Nginx port)
    3. Delete Filebrowser database
    4. Edit config manually
    5. Back
    "
    read -r option
    case $option in
        1)
        ;;
        2)
        ;;
        3)
        ;;
        4)
        ;;
        *)
        info_r "invalid input!"
    esac
}

menu_extend_11()
{
    info_normal "
    1. Edit Aria2 domain
    2. Edit Filebrowser domain
    3. Back
    "
    read -r option
    case $option in
        1)
        ;;
        2)
        ;;
        3)
        ;;
        4)
        ;;
        *)
        info_r "invalid input!"
    esac
}

Install_aria2()
{
    Aria2_nginx_config_name=aria2
    info_g "Installing Aria2"
    apt install -y aria2
    info_g "Downloading the best Aria2 config"
    mkdir /etc/aria2
    curl -L ${Aria2_config_url} -O /etc/aria2/aria2.conf
    touch /etc/systemd/system/aria2.service
    info_normal "[Unit]
Description=aria2 Daemon
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/aria2c --conf-path=/etc/aria2.conf -D
TimeoutStopSec=20

[Install]
WantedBy=default.target" >> /etc/systemd/system/aria2.service
    systemctl daemon-reload
    systemctl enable aria2 --now
    info_normal "Input the nginx path, such as /jsonrpc and /auth(default: /jsonrpc)"
    info_normal "With default, open the aria's jsonrpc by example.com/jsonrpc"
    read -r Aria2_path
    if [ "$Aria2_path" = "" ];
    then
        Aria2_path=/jsonrpc
    fi
    domain_detect
    if [[ "$Aria2_domain" != "null" ]] || [[ "$Filebrowser_domain" != "null" ]] || [[ "$Ariang_domain" != "null" ]];
    then
        read -p "Detected domain, use the same domain and port? (y/N)" -r answer
        if [[ "$answer" = "y" ]] || [[ "$answer" =  "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]];
        then
            Aria2_domain=$(domain_choose)
            Aria2_nginx_config_name=$Aria2_domain
            info_normal "server {
    location $Aria2_path {
        proxy_pass http://localhost:6800/jsonrpc;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \"upgrade\";
    }
}" >> /etc/nginx/sites-available/"$Aria2_nginx_config_name"
            return
        fi
    fi
    info_ly "You need append the DNS record first!"
    while true
    do
        info_normal "Input the aria2 domain, such as download.example.com"
        info_normal "If you want to use ip Press Enter"
        read -r Aria2_domain
        if [ "$Aria2_domain" = "" ];
        then
            info_normal "domain is empty ,do you want to use ip directly?(y/N)"
            info_ly "Not recomment use this on server."
            if [[ "$answer" = "y" ]] || [[ "$answer" =  "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]];
            then
                #use ip加入duim.json
                Aria2_domain=_
	        fi
        fi
    info_normal "Your domain is: $Aria2_domain"
    info_normal "Is That correct? (y/N)"
    read -r answer
    if [[ "$answer" = "y" ]] || [[ "$answer" =  "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]];
    Aria2_nginx_config_name=$Aria2_domain
    then break;
	fi
    done
    touch /etc/nginx/sites-available/"$Aria2_nginx_config_name"
    #aria2 PATH 加入 duim.json
    info_normal "Input the Nginx port, such as 80, this is usefull if you use single ip"
    info_normal "This port will proxy the Aria2"
    read -r Aria2_port
    #Aria2_port 加入 duim.json
    info_normal "server {
    listen $Aria2_port;
    listen [::]:$Aria2_port;
    index index.html;
    server_name $Aria2_domain;

    location $Aria2_path {
        proxy_pass http://localhost:6800/jsonrpc;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \"upgrade\";
    }
}" >> /etc/nginx/sites-available/"$Aria2_nginx_config_name"
    ln -s /etc/nginx/sites-available/"$Aria2_nginx_config_name" /etc/nginx/sites-enabled/
    systemctl reload nginx
}

install_filebrowser()
{
    Filebrowser_nginx_config_name=filebowser
    info_g "Installing filebrowser"
    curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
    mkdir /usr/local/etc/filebrowser
    touch /usr/local/etc/filebrowser/config.json
    #修改root目录
    info_normal '{
    "address": "127.0.0.1",
    "port": 8081,
    "auth.method": "noauth",
    "baseURL": "",
    "database": "/usr/local/etc/filebrowser/filebrowser.db",
    "root": "/home/vince/aria/download"
}' >> /usr/local/etc/filebrowser/config.json
    touch /etc/systemd/system/filebrowser.service
    info_normal "[Unit]
Description=Filebrowser Daemon
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/filebrowser -c /usr/local/etc/filebrowser/config.json
ExecStop=/bin/killall filebrowser
PrivateTmp=true

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/filebrowser.service
    systemctl daemon-reload
    systemctl enable filebrowser --now
    domain_detect
    if [[ "$Aria2_domain" != "null" ]] || [[ "$Filebrowser_domain" != "null" ]] || [[ "$Ariang_domain" != "null" ]];
    then
        read -p "Detected domain, use the same domain and port? (y/N)" -r answer
        if [[ "$answer" = "y" ]] || [[ "$answer" =  "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]];
        then
            Filebrowser_domain=$(domain_choose)
            Filebrowser_nginx_config_name=Filebrowser_domain
            info_normal "  location / {
        proxy_pass  http://127.0.0.1:8081;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }" >> /etc/nginx/sites-available/"$Filebrowser_nginx_config_name"
            systemctl reload nginx
            return
        fi
    fi
    info_normal -e "$Yellow You need append the DNS record first!"
    while true
    do
        info_normal "Input the filebrowser domain, such as download.example.com"
        info_normal "If you want to use ip Press Enter"
        read -r Filebrowser_domain
        if [ "$Filebrowser_domain" = "" ];
        then
            info_ly "Domain is empty, do you want to use ip directly? (Not recomment) (y/N)"
            if [[ "$answer" = "y" ]] || [[ "$answer" =  "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]];
            then
                Filebrowser_domain=_
                #use ip加入duim.json
            fi
        fi
        info_normal "Your domain is: $Filebrowser_domain"
        info_normal "Is That correct? (y/N)"
        read -r answer
        if [[ "$answer" = "y" ]] || [[ "$answer" =  "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]];
        then
            Filebrowser_nginx_config_name=$Filebrowser_domain
            break;
	    fi
    done
    touch /etc/nginx/sites-available/"$Filebrowser_nginx_config_name"
    info_normal "Input the Nginx port, such as 80, this is usefull if you use single ip"
    info_normal "This port will proxy the Filebrowser (default 80)"
    read -r Filebrowser_port
    #filebowser port 加入 duim.json
    info_normal "server {
    listen $Filebrowser_port;
    listen [::]:$Filebrowser_port;
    server_name $Filebrowser_domain;
    location / {
        proxy_pass  http://127.0.0.1:8081;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}" >> /etc/nginx/sites-available/"$Filebrowser_nginx_config_name"
}

install_ariang()
{
    Ariang_nginx_config_name=ariang
    info_normal "Installing AriaNg"
    mkdir /var/www/ariang
    curl -L "${AriaNg_download_url}" -O /var/www/ariang/
    unzip /var/www/ariang/*.zip -d /var/www/ariang/
    rm -f /var/www/ariang/*.zip
    info_normal "Input the nginx path, such as /ariang and /ng(default: /ariang)"
    info_normal "With default, open the ariang by example.com/ariang"
    read -r Ariang_path
    if [ "$Ariang_path" = "" ];
    then
        Ariang_path=/ariang
    fi
    domain_detect
    if [[ "$Aria2_domain" != "null" ]] || [[ "$Filebrowser_domain" != "null" ]] || [[ "$Ariang_domain" != "null" ]];
    then
        read -p "Detected domain, use the same domain and port? (y/N)" -r answer
        if [[ "$answer" = "y" ]] || [[ "$answer" =  "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]];
        then
            Ariang_domain=$(domain_choose)
            Ariang_nginx_config_name=$Ariang_domain
            sed -i "a/server_name/location /ariang {\nroot /var/www/ariang;\ntry_files \$uri \$uri/ =404;\n}" /etc/nginx/sites-available/"$Ariang_nginx_config_name"
            systemctl reload nginx
            return
        fi
    fi
    info_normal -e "$Yellow You need append the DNS record first!"
    while true
    do
        info_normal "Input the aria2 domain, such as download.example.com"
        info_normal "If you want to use ip Press Enter"
        read -r Aria2_domain
        if [ "$Ariang_domain" = "" ];
        then
            info_normal "domain is empty ,do you want to use ip directly?(y/N)"
            info_ly "Not recomment use this on server."
            if [[ "$answer" = "y" ]] || [[ "$answer" =  "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]];
            then
                #use ip加入duim.json
                Ariang_domain=_
                break;
	        fi
        fi
        info_normal "Your domain is: $Ariang_domain"
        info_normal "Is That correct? (y/N)"
        read -r answer
        if [[ "$answer" = "y" ]] || [[ "$answer" =  "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]];
        then break;
	    fi
    done
    touch /etc/nginx/sites-available/"$Ariang_nginx_config_name"
    info_normal "Input the Nginx port, such as 80, this is usefull if you use single ip"
    info_normal "This port will proxy the Filebrowser (default 80)"
    read -r Filebrowser_port
    #filebowser port 加入 duim.json
    info_normal "server {
        listen 80;
        listen [::]:80;
        root /var/www/ariang;
        server_name $Ariang_domain;
    location $Ariang_path {
        try_files \$uri \$uri/ =404;
    }
}" >> /etc/nginx/sites-available/"$Ariang_nginx_config_name"
}

domain_detect()
{
    Aria2_domain=$(cat $Script_db | jq -r .aria2.domain)
    Filebrowser_domain=$(cat $Script_db | jq -r .filebrowser.domain)
    Ariang_domain=$(cat $Script_db | jq -r .ariang.domain)
}

domain_choose()
{
    info_normal"choose one of them"
    info_normal -e "1. Aria2:$Aria2_domain
2. Filebrowser:$Filebrowser_domain
3. AriaNg:$Ariang_domain"
    read -r option
    while true
    do
        case $option in
            1)
            if [ "$Aria2_domain" != "null" ]
            then
                return "$Aria2_domain"
            else
                info_ly "Aria2 domain is empty!"
            fi
            ;;
            2)
            if [ "$Filebrowser_domain" != "null" ]
            then
                return "$Filebrowser_domain"
            else
                info_ly "Filebrowser domain is empty!"
            fi
            ;;
            3)
            if [ "$Ariang_domain" != "null" ]
            then
                return "$Ariang_domain"
            else
                info_ly "Ariang domain is empty!"
            fi
            ;;
            *)
            info_normal -e "$Red invalid input!"
        esac
    done
}

get_ssl_file()
{
    #$1 is domain name
    #$2 is dir name
    info_g "Use file challenge"
    acme.sh --set-default-ca --server letsencrypt
    acme.sh --issue -d "$1" --nginx --keylength ec-256
    acme.sh --install-cert -d "$1" --cert-file /etc/nginx/ssl/"$2"/cert.crt --key-file /etc/nginx/ssl/"$2"/cert.key --fullchain-file /etc/nginx/ssl/"$2"/fullchain.crt --reloadcmd "service nginx force-reload"
}
# not finished
get_ssl_dns()
{
    #$1 is domain name
    #$2 is DNS provider
    #$3 is api account name
    #$4 is api key
    #$5 is other info
    info_g "Use DNS challenge"
}

#####################
#      Modules      #
#####################
command_check()
{
    ! command -v "$1" &> /dev/null
}
command_check_install()
{
    #$2 is after install hook
    if ! command -v "$1" &> /dev/null
    then
        printf "%b" "$3"
        apt install "$1"
        $2
    fi
}

chioce_default_yes()
{
    read -r answer
	if [[ "$answer" = "n" ]] || [[ "$answer" =  "no" ]] || [[ "$answer" = "NO" ]] || [[ "$answer" = "N" ]];
	then
        info_m "Exit!" && exit 0
    else
        return
	fi
}

chioce_default_no()
{
    read -r  answer
    if [[ "$answer" = "y" ]] || [[ "$answer" =  "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]];
    then 
        return
    else
        info_m "Exit!" && exit 0
	fi
}

color_print()
{
    normal=$(tput sgr0)
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    blue=$(tput setaf 4)
    cyan=$(tput setaf 6)
    magenta=$(tput setaf 164)
    yellow=$(tput setaf 3)
    lime_yellow=$(tput setaf 190)
    powder_blue=$(tput setaf 153)
    bright=$(tput bold)
    blink=$(tput blink)
    reverse=$(tput smso)
    underline=$(tput smul)
    info_normal() { printf "%b\n" " $*"; }
    info_r() { printf "%b\n" "${red} $*${normal}"; }
    info_g() { printf "%b\n" "${green} $*${normal}"; }
    info_b() { printf "%b\n" "${blue} $*${normal}"; }
    info_c() { printf "%b\n" "${cyan} $*${normal}"; }
    info_m() { printf "%b\n" "${magenta} $*${normal}"; }
    info_y() { printf "%b\n" "${yellow} $*${normal}"; }
    info_ly() { printf "%b\n" "${lime_yellow} $*${normal}"; }
    info_pb() { printf "%b\n" "${powder_blue} $*${normal}"; }
    info_bright() { printf "%b\n" "${bright} $*${normal}"; }
    info_blink() { printf "%b\n" "${blink} $*${normal}"; }
    info_reverse() { printf "%b\n" "${reverse} $*${normal}"; }
    info_underline() { printf "%b\n" "${underline} $*${normal}"; }
}
#####################
#    Modules_END    #
#####################
color_print
author
check_relay
menu
