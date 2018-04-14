#!/usr/bin/env bash
#===============================================================================================================================================
# (C) Copyright 2013-2018 under the Crypto World Foundation (https://cryptoworld.is).
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
# date             :04-13-2018
# version          :0.1.2 Beta
# os               :Debian/Ubuntu
# usage            :bash fastrelay.sh
# notes            :If you have any problems feel free to email us: security [AT] torworld [DOT] org
#===============================================================================================================================================

# Setting up an update/upgrade glabal function
    function upkeep() {
      apt-get update -y
      apt-get dist-upgrade -y
      apt-get clean -y
    }

# Grabbing info on active machine.
      flavor=`lsb_release -cs`
      system=`lsb_release -i | grep "Distributor ID:" | sed 's/Distributor ID://g' | sed 's/["]//g' | awk '{print tolower($1)}'`

# START

# Checking for multiple "required" pieces of software.
    if
      echo -e "\033[92mPerforming upkeep of system packages.. \e[0m"
        upkeep
        echo -e "\033[92mChecking software list..\e[0m"

      [ ! -x  /usr/bin/lsb_release ] || [ ! -x  /usr/bin/wget ] || [ ! -x  /usr/bin/curl ] || [ ! -x  /usr/bin/apt-transport-https ] || [ ! -x  /usr/bin/dirmngr ] || [ ! -x  /usr/bin/ca-certificates ] || [ ! -x  /usr/bin/dialog ] ; then

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
              echo deb http://deb.torproject.org/torproject.org $flavor main > /etc/apt/sources.list.d/deb.torproject.list
              echo deb-src http://deb.torproject.org/torproject.org $flavor main >> /etc/apt/sources.list.d/deb.torproject.list
                gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
                gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
              echo "Performing upkeep.."
                upkeep
                echo "Installing Tor now.."
                  apt-get install tor
                echo "Getting status of Tor."
                  service tor status
                echo "Stopping Tor service.."
                  service tor stop
                ;;
              2)
              echo deb http://deb.torproject.org/torproject.org $flavor main > /etc/apt/sources.list.d/deb.torproject.list
              echo deb-src http://deb.torproject.org/torproject.org $flavor main >> /etc/apt/sources.list.d/deb.torproject.list
              echo deb http://deb.torproject.org/torproject.org tor-experimental-0.3.3.x-$flavor main >> /etc/apt/sources.list.d/deb.torproject.list
              echo deb-src http://deb.torproject.org/torproject.org tor-experimental-0.3.3.x-$flavor main >> /etc/apt/sources.list.d/deb.torproject.list
                gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
                gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
              echo "Performing upkeep.."
                upkeep
                echo "Installing Tor now.."
                  apt-get install tor
                echo "Getting status of Tor."
                  service tor status
                echo "Stopping Tor service.."
                  service tor stop
                ;;
              3)
              echo deb http://deb.torproject.org/torproject.org $flavor main > /etc/apt/sources.list.d/deb.torproject.list
              echo deb-src http://deb.torproject.org/torproject.org $flavor main >> /etc/apt/sources.list.d/deb.torproject.list
              echo deb http://deb.torproject.org/torproject.org tor-nightly-master-$flavor main >> /etc/apt/sources.list.d/deb.torproject.list
              echo deb-src http://deb.torproject.org/torproject.org tor-nightly-master-$flavor main >> /etc/apt/sources.list.d/deb.torproject.list
                gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
                gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
              echo "Performing upkeep.."
                upkeep
                echo "Installing Tor now.."
                  apt-get install tor
                echo "Getting status of Tor."
                  service tor status
                echo "Stopping Tor service.."
                  service tor stop
                ;;
            esac
        clear

# Backlinking Nginx dependencies for APT.
    read -r -p "Do you want to fetch the core Nginx dependencies, and install? (Y/N) " REPLY
      case "${REPLY,,}" in
        [yY]|[yY][eE][sS])
              echo deb http://nginx.org/packages/$system/ $flavor nginx > /etc/apt/sources.list.d/tornginx.list
              echo deb-src http://nginx.org/packages/$system/ $flavor nginx >> /etc/apt/sources.list.d/tornginx.list
                wget -4 https://nginx.org/keys/nginx_signing.key
                apt-key add nginx_signing.key
              echo "Performing upkeep.."
                upkeep
              echo "Installing Nginx now.."
                apt-get install nginx
                service nginx status
              echo "Preventing Nginx from logging..."
                curl -s "https://raw.githubusercontent.com/beardlyness/FastRelay/master/nginx/nginx.conf" > /etc/nginx/nginx.conf
              echo "Restarting the Nginx service..."
                service nginx restart
              echo "Grabbing fastexit-website-template from GitHub.."
                wget -4 https://github.com/torworld/fastexit-website-template/archive/master.tar.gz -O - | tar -xz -C /usr/share/nginx/html/  && mv /usr/share/nginx/html/fastexit-website-template-master/* /usr/share/nginx/html/
              echo "Removing temporary files/folders.."
                rm -rf /usr/share/nginx/html/fastexit-website-template-master*
            ;;
          [nN]|[nN][oO])
            echo "You have said no? We cannot work without your permission!"
            ;;
          *)
            echo "Invalid response. You okay?"
            ;;
      esac

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
          read -r -p "DirPort: " REPLY
            if [[ "${REPLY,,}"  =~  ^([0-9])+$ ]]
              then
                echo "Machine DirPort is: '$REPLY' "
                echo DirPort $REPLY >> /etc/tor/torrc
              else
                echo "You did not input any numbers."
            fi

# ORPort
          read -r -p "ORPort: " REPLY
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
            CHOICE_HEIGHT=2
            BACKTITLE="TorWorld | FastRelay"
            TITLE="FastRelay ExitPolicy Setup"
            MENU="Choose one of the following ExitPolicy options:"

            OPTIONS=(1 "Reduced ExitPolicy"
                     2 "Browser Only ExitPolicy")

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
                            curl -s "https://raw.githubusercontent.com/beardlyness/FastRelay/master/policy/passive.s02018041301.exitlist.txt" >> /etc/tor/torrc
                            ;;
                        2)
                            echo "Loading in a Browser Only ExitPolicy.."
                            curl -s "https://raw.githubusercontent.com/beardlyness/FastRelay/master/policy/browser.s02018041301.exitlist.txt" >> /etc/tor/torrc
                            ;;
                esac
              clear

# Contact Information
            read -r -p "Contact Information: " REPLY
              if [[ "${REPLY,,}"  =~  ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]
                then
                  echo "Machines Contact info is: '$REPLY' "
                  echo ContactInfo $REPLY >> /etc/tor/torrc
                else
                  echo "Invalid."
              fi

# End statement
        echo -e "\e[5m" "\033[92mThat's all folks..\e[0m"
        echo RunAsDaemon 1 >> /etc/tor/torrc

# Close Arg for Main Statement.
      ;;
    [nN]|[nN][oO])
      echo "You have said no? We cannot work without your permission!"
      ;;
    *)
      echo "Invalid response. You okay?"
      ;;
esac
