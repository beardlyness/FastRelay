#!/usr/bin/env bash
#===============================================================================================================================================
# (C) Copyright 2013-2019 under the Crypto World Foundation (https://cryptoworld.is).
#
# Licensed under the GNU GENERAL PUBLIC LICENSE, Version 3.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#===============================================================================================================================================
# title            :FastRelay
# description      :Open-Proxy setup helper for Tor.
# author           :TorWorld A Project Under The Crypto World Foundation.
# contributors     :Beardlyness, Lunar, KsaRedFx, SPMedia, NurdTurd
# date             :04-05-2019
# version          :0.1.6 Beta
# os               :Debian/Ubuntu (Debian 8 - 10 | Ubuntu 14.04 - 18.10)
# usage            :bash FastRelay.sh
# notes            :If you have any problems feel free to email us: security [AT] torworld [DOT] org
#===============================================================================================================================================

# Force check for root
  if ! [ $(id -u) = 0 ]; then
    echo "You need to be logged in as root!"
    exit 1
  fi

# Setting up an update/upgrade glabal function
    function upkeep() {
      echo "Performing upkeep.."
        apt-get update -y
        apt-get dist-upgrade -y
        apt-get clean -y
    }

# Setting up a Tor installer + status check with hault
    function torstall() {
      echo "Performing torstall.."
        apt-get install tor
        service tor status
        service tor stop
    }

# Setting up different Tor branches to prep for install
    function tor_stable () {
      echo "Grabbing Stable build dependencies.."
      echo deb http://deb.torproject.org/torproject.org $flavor main > /etc/apt/sources.list.d/repo.torproject.list
      echo deb-src http://deb.torproject.org/torproject.org $flavor main >> /etc/apt/sources.list.d/repo.torproject.list
        apt install tor deb.torproject.org-keyring
        curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
        gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
        gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
    }

    function tor_experimental () {
      echo "Grabbing Experimental build dependencies.."
        tor_stable
      echo deb https://deb.torproject.org/torproject.org tor-experimental-0.3.4.x-$flavor main >> /etc/apt/sources.list.d/repo.torproject.list
      echo deb-src https://deb.torproject.org/torproject.org tor-experimental-0.3.4.x-$flavor main >> /etc/apt/sources.list.d/repo.torproject.list
    }

    function tor_nightly () {
      echo "Grabbing Nightly build dependencies.."
        tor_stable
      echo deb http://deb.torproject.org/torproject.org tor-nightly-master-$flavor main >> /etc/apt/sources.list.d/repo.torproject.list
      echo deb-src http://deb.torproject.org/torproject.org tor-nightly-master-$flavor main >> /etc/apt/sources.list.d/repo.torproject.list
    }

    # Setting up different NGINX branches to prep for install
  function nginx_stable () {
      echo deb http://nginx.org/packages/$system/ $flavor nginx > /etc/apt/sources.list.d/$flavor.nginx.stable.list
      echo deb-src http://nginx.org/packages/$system/ $flavor nginx >> /etc/apt/sources.list.d/$flavor.nginx.stable.list
        wget https://nginx.org/keys/nginx_signing.key
        apt-key add nginx_signing.key
    }

  function nginx_mainline () {
      echo deb http://nginx.org/packages/mainline/$system/ $flavor nginx > /etc/apt/sources.list.d/$flavor.nginx.mainline.list
      echo deb-src http://nginx.org/packages/mainline/$system/ $flavor nginx >> /etc/apt/sources.list.d/$flavor.nginx.mainline.list
        wget https://nginx.org/keys/nginx_signing.key
        apt-key add nginx_signing.key
    }

    # Attached func for NGINX branch prep.
      function nginx_default() {
        echo "Installing NGINX.."
          apt-get install nginx
          service nginx status
        echo "Raising limit of workers.."
          ulimit -n 65536
          ulimit -a
        echo "Setting up Security Limits.."
          wget -O /etc/security/limits.conf https://raw.githubusercontent.com/torworld/fastrelay/master/etc/security/limits.conf
        echo "Setting up background NGINX workers.."
          wget -O /etc/default/nginx https://raw.githubusercontent.com/torworld/fastrelay/master/etc/default/nginx
          echo "Setting up configuration file for NGINX main configuration.."
            wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/torworld/fastrelay/master/nginx/nginx.conf
        echo "Setting up folders.."
          mkdir -p /etc/engine/ssl/live
          mkdir -p /var/www/html/pub/live
        echo "Restarting the NGINX service..."
        service nginx restart
        echo "Grabbing fastrelay-website-template from GitHub.."
          wget https://github.com/torworld/fastrelay-website-template/archive/master.tar.gz -O - | tar -xz -C /var/www/html/pub/live/  && mv /var/www/html/pub/live/fastrelay-website-template-master/* /var/www/html/pub/live/
        echo "Removing temporary files/folders.."
          rm -rf /var/www/html/pub/live/fastrelay-website-template-master*
      }


# START

# Checking for multiple "required" pieces of software.
    if
      echo -e "\033[92mPerforming upkeep of system packages.. \e[0m"
        upkeep
      echo -e "\033[92mChecking software list..\e[0m"

      [ ! -x  /usr/bin/lsb_release ] || [ ! -x  /usr/bin/curl ] || [ ! -x  /usr/bin/wget ] || [ ! -x  /usr/bin/apt-transport-https ] || [ ! -x  /usr/bin/dirmngr ] || [ ! -x  /usr/bin/ca-certificates ] || [ ! -x  /usr/bin/dialog ] ; then

        echo -e "\033[92mlsb_release: checking for software..\e[0m"
        echo -e "\033[34mInstalling lsb_release, Please Wait...\e[0m"
          apt-get install lsb-release

        echo -e "\033[92mwget: checking for software..\e[0m"
        echo -e "\033[34mInstalling wget, Please Wait...\e[0m"
          apt-get install wget

        echo -e "\033[92mcurl: checking for software..\e[0m"
        echo -e "\033[34mInstalling curl, Please Wait...\e[0m"
          apt-get install curl

        echo -e "\033[92mapt-transport-https: checking for software..\e[0m"
        echo -e "\033[34mInstalling apt-transport-https, Please Wait...\e[0m"
          apt-get install apt-transport-https

        echo -e "\033[92mdirmngr: checking for software..\e[0m"
        echo -e "\033[34mInstalling dirmngr, Please Wait...\e[0m"
          apt-get install dirmngr

        echo -e "\033[92mca-certificates: checking for software..\e[0m"
        echo -e "\033[34mInstalling ca-certificates, Please Wait...\e[0m"
          apt-get install ca-certificates

        echo -e "\033[92mdialog: checking for software..\e[0m"
        echo -e "\033[34mInstalling dialog, Please Wait...\e[0m"
          apt-get install dialog
    fi

# Grabbing info on active machine.
      flavor=`lsb_release -cs`
      system=`lsb_release -i | grep "Distributor ID:" | sed 's/Distributor ID://g' | sed 's/["]//g' | awk '{print tolower($1)}'`

# Backlinking Tor dependencies for APT.
          read -r -p "Do you want to fetch the core Tor dependencies? (Y/N) " REPLY
            case "${REPLY,,}" in
              [yY]|[yY][eE][sS])
                HEIGHT=20
                WIDTH=120
                CHOICE_HEIGHT=3
                BACKTITLE="TorWorld | FastRelay"
                TITLE="Tor Build Setup"
                MENU="Choose one of the following Build options:"

                OPTIONS=(1 "Stable Build"
                         2 "Experimental Build"
                         3  "Nightly Build")

                CHOICE=$(dialog --clear \
                                --backtitle "$BACKTITLE" \
                                --title "$TITLE" \
                                --menu "$MENU" \
                                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                                "${OPTIONS[@]}" \
                                2>&1 >/dev/tty)

                clear

# Attached Arg for dialogs $CHOICE output
            case $CHOICE in
              1)
                tor_stable
                upkeep
                torstall
                ;;
              2)
                tor_experimental
                upkeep
                torstall
                ;;
              3)
                tor_nightly
                upkeep
                torstall
                ;;
            esac
        clear

# Setting up the Torrc file with config input options.

# Nickname
          read -r -p "Nickname: " REPLY
            if [[ "${REPLY,,}"  =~  ^([a-zA-Z])+$ ]]
              then
                echo "Machine Nickname is: '$REPLY' "
                echo Nickname $REPLY > /etc/tor/torrc
              else
                echo "Invalid."
            fi

# DirPort
          read -r -p "DirPort (Example: 9030): " REPLY
            if [[ "${REPLY,,}"  =~  ^([0-9])+$ ]]
              then
                echo "Machine DirPort is: '$REPLY' "
                echo DirPort $REPLY >> /etc/tor/torrc
              else
                echo "You did not input any numbers."
            fi

# ORPort
          read -r -p "ORPort (Example: 9001): " REPLY
            if [[ "${REPLY,,}"  =~  ^([0-9])+$ ]]
              then
                echo "Machine ORPort is: '$REPLY' "
                echo ORPort $REPLY >> /etc/tor/torrc
              else
                echo "You did not input any numbers."
            fi

# Dialog for ExitPolicy selection.
            HEIGHT=20
            WIDTH=120
            CHOICE_HEIGHT=4
            BACKTITLE="TorWorld | FastRelay"
            TITLE="FastRelay ExitPolicy Setup"
            MENU="Choose one of the following ExitPolicy options:"

            OPTIONS=(1 "Reduced ExitPolicy"
                     2 "Browser Only ExitPolicy"
                     3 "NON-Exit (RELAY ONLY) Policy"
                     4 "Bridge Only (Unlisted Bridge) Policy")

            CHOICE=$(dialog --clear \
                            --backtitle "$BACKTITLE" \
                            --title "$TITLE" \
                            --menu "$MENU" \
                            $HEIGHT $WIDTH $CHOICE_HEIGHT \
                            "${OPTIONS[@]}" \
                            2>&1 >/dev/tty)

                clear
                case $CHOICE in
                        1)
                            echo "Loading in a Passive ExitPolicy.."
                              wget https://raw.githubusercontent.com/torworld/fastrelay/master/policy/passive.s02018050201.exitlist.txt -O ->> /etc/tor/torrc
                            ;;
                        2)
                            echo "Loading in a Browser Only ExitPolicy.."
                              wget https://raw.githubusercontent.com/torworld/fastrelay/master/policy/browser.s02018050201.exitlist.txt -O ->> /etc/tor/torrc
                            ;;
                        3)
                            echo "Loading in NON-EXIT (RELAY ONLY) Policy"
                              wget https://raw.githubusercontent.com/torworld/fastrelay/master/policy/nonexit.s02018050201.list.txt -O ->> /etc/tor/torrc
                            ;;
                        4)
                            echo "Loading in Bridge Only (Unlisted Bridge) Policy"
                              wget https://raw.githubusercontent.com/torworld/fastrelay/master/policy/bridge.s02019011501.list -O ->> /etc/tor/torrc
                            ;;
                esac
              clear

              # NGINX Arg main
              read -r -p "Do you want to fetch the core NGINX dependencies, and install? (Y/N) " REPLY
                case "${REPLY,,}" in
                  [yY]|[yY][eE][sS])
                    HEIGHT=20
                    WIDTH=120
                    CHOICE_HEIGHT=2
                    BACKTITLE="TorWorld | FastRelay"
                    TITLE="NGINX Branch Builds"
                    MENU="Choose one of the following Build options:"

                    OPTIONS=(1 "Stable"
                             2 "Mainline")

                    CHOICE=$(dialog --clear \
                                    --backtitle "$BACKTITLE" \
                                    --title "$TITLE" \
                                    --menu "$MENU" \
                                    $HEIGHT $WIDTH $CHOICE_HEIGHT \
                                    "${OPTIONS[@]}" \
                                    2>&1 >/dev/tty)


              # Attached Arg for dialogs $CHOICE output
                  case $CHOICE in
                    1)
                      echo "Grabbing Stable build dependencies.."
                        nginx_stable
                        upkeep
                        nginx_default
                        ;;
                    2)
                      echo "Grabbing Mainline build dependencies.."
                        nginx_mainline
                        upkeep
                        nginx_default
                        ;;
                  esac
              clear

              # Close Arg for Main Statement.
                    ;;
                  [nN]|[nN][oO])
                    echo "You have said no? We cannot work without your permission!"
                    ;;
                  *)
                    echo "Invalid response. You okay?"
                    ;;
              esac


# Contact Information
            read -r -p "Contact Information: " REPLY
              if [[ "${REPLY,,}"  =~  ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]
                then
                  echo "Machines Contact info is: '$REPLY' | You must enter a valid email address for now. You can change it manually later on via ('/etc/tor/torrc')"
                  echo ContactInfo $REPLY >> /etc/tor/torrc
                else
                  echo "Invalid."
              fi

# Setup Arg for PIP+Nyx
    read -r -p "Do you wish to install Nyx to monitor your Tor Relay? (Y/N) " REPLY
      case "${REPLY,,}" in
        [yY]|[yY][eE][sS])
              echo "Setting up Python-PIP in order to install Nyx.."
                apt-get install python-pip
                pip install nyx
              echo -e "ControlPort 9051\nCookieAuthentication 1" >> /etc/tor/torrc
                upkeep
                service tor restart
            ;;
          [nN]|[nN][oO])
            echo "You have said no? We cannot work without your permission!"
            ;;
          *)
            echo "Invalid response. You okay?"
            ;;
      esac

# Close Arg for Main Statement.
      ;;
    [nN]|[nN][oO])
      echo "You have said no? We cannot work without your permission!"
      ;;
    *)
      echo "Invalid response. You okay?"
      ;;
esac
