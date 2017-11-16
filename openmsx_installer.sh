#!/bin/bash

#IN NO EVENT SHALL REGENTS BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR 
#CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS 
#DOCUMENTATION, EVEN IF REGENTS HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#REGENTS SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING 
#DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". REGENTS HAS NO OBLIGATION TO 
#PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
clear

echo -e "\e[93mFetching Information and installing 'dialog' file"
echo -e "\e[92m"
	
sudo apt-get update
sudo apt-get -y install dialog

function UpdatePi() {
	clear
	echo -e "\e[93mUpdate the Pi to latest OS"
	echo -e "\e[92m"
	sudo apt-get -y upgrade
	sudo apt-get -y dist-upgrade
	sudo apt-get -y autoremove
	sudo apt-get -y autoclean
}

function openMSXCompile() {
	mkdir ~/compiler
	cd ~/compiler
	echo -e "\e[93mget source code"
	echo -e "\e[92m"
	git clone https://github.com/openMSX/openMSX.git openMSX
	cd openMSX
	make
	sudo make install
}

function openMSX14Download() {
	clear
	echo -e "\e[93minstall openMSX"
	echo -e "\e[92m"
	InstallDependencies
	cd ~
	#install openMSX 0.13.0 dependencies 
	sudo apt-get -y install openmsx
	#sudo apt-get build-dep openmsx
	
	#install openMSX 0.14.0 over 0.13.0
	wget -N http://archive.raspbian.org/raspbian/pool/main/o/openmsx/openmsx-data_0.14.0-1_all.deb
	wget -N http://archive.raspbian.org/raspbian/pool/main/o/openmsx/openmsx_0.14.0-1_armhf.deb
	sudo dpkg -i openmsx-data_0.14.0-1_all.deb
	sudo dpkg -i openmsx_0.14.0-1_armhf.deb
}

function installSystemRoms() {
	echo -e "\e[93minstall system roms"
	echo -e "\e[92m"
	#rm -rf ~./openmsx/
	mkdir -p ~/.openMSX/share/systemroms
	mkdir -p ~/opt/openMSX/share/extensions/
	cd ~/.openMSX/share/

	wget https://vampier.net/systemroms.zip
	unzip -o ~/.openMSX/share/systemroms.zip
	rm systemroms.zip
}

function setOptimalSettings() {
echo -e "\e[93mSet config settings to best values"
cat > ~/.openMSX/share/settings.xml <<eol
<!DOCTYPE settings SYSTEM 'settings.dtd'>
<settings>
  <settings>
    <setting id="auto_enable_reverse">off</setting>
    <setting id="renderer">SDL</setting>
    <setting id="invalid_psg_directions_callback">psgdirectioncallback</setting>
    <setting id="di_halt_callback">dihaltcallback</setting>
    <setting id="default_machine">Panasonic_FS-A1GT</setting>
    <setting id="scanline">0</setting>
    <setting id="blur">0</setting>
    <setting id="fullscreen">true</setting>
    <setting id="osd_leds_set">handheld</setting>
    <setting id="horizontal_stretch">256.0</setting>
    <setting id="resampler">blip</setting>
    <setting id="fullspeedwhenloading">true</setting>
    <setting id="fast_cas_load_hack_enabled">true</setting>
    <setting id="maxframeskip">2</setting>
    <setting id="scale_factor">2</setting>
  </settings>
  <bindings>
    <bind key="keyb F12">toggle pause</bind>
  </bindings>
</settings>
eol
}

function setMFRSetup() {
echo -e "\e[93mSet MFR SCC+ SD SD Card to 1GB"
echo -e "\e[92m"
sudo mkdir -p /opt/openMSX/share/extensions/
sudo chown -R pi /opt/openMSX/share/extensions/
sudo cat > /opt/openMSX/share/extensions/MegaFlashROM_SCC+_SD.xml <<eol
<?xml version="1.0" ?>
<!DOCTYPE msxconfig SYSTEM 'msxconfig2.dtd'>
<msxconfig>
  <info>
    <name>MegaFlashROM SCC+ SD</name>
    <manufacturer>Manuel Pazos</manufacturer>
    <code/>
    <release_year>2013</release_year>
    <description>MSX Flash cartridge of 8MB with SCC-I and PSG and 2 SD card slots.</description>
    <type>Flash cartridge</type>
  </info>
  <devices>
    <primary slot="any">
      <secondary slot="any">
        <MegaFlashRomSCCPlusSD id="MegaFlashRom SCC+ SD">
          <mem base="0x0000" size="0x10000"/>
          <sound>
            <volume>9000</volume>
          </sound>
          <rom>
            <sha1>1621f623b834dc57cb2983f30b36bcc3ac56cafd</sha1>
          </rom>
          <sdcard1>
            <filename>SDcard1.sdc</filename>
            <size>1024</size>
          </sdcard1>
          <sramname>megaflashromsccplussd.sram</sramname>
          <hasmemorymapper>true</hasmemorymapper>
        </MegaFlashRomSccPlusSD>
      </secondary>
    </primary>
  </devices>
</msxconfig>
eol
}

function openMSXStartScript() {
echo -e "\e[93mCreate start-up script"
echo -e "\e[92m"
cat > ~/start_openmsx.sh <<eol
clear
openmsx -ext "MegaFlashROM_SCC+_SD"  -machine "Panasonic_FS-A1GT"
eol

chmod +x ~/start_openmsx.sh
}

function installGoodMSXRoms() {
	clear
	echo -e "\e[93minstalling GoodMSX ROMSs"
	echo -e "\e[92m"
	cd ~
	mkdir -p ~/openmsx/roms/
	
	wget -N https://www.vampier.net/GOODMSX1_0.999.2.ZIP
	wget -N https://www.vampier.net/GOODMSX2_0.999.2.ZIP
	unzip -o GOODMSX1_0.999.2.ZIP -d ~/openmsx/roms/GoodMSX1
	unzip -o GOODMSX2_0.999.2.ZIP -d ~/openmsx/roms/GoodMSX2

}

function uninstallOpenMSX() {
	clear
	echo -e "\e[93mRemove openMSX and GoodMSX ROMs"
	echo -e "\e[92m"
	#remove current openMSX version
	sudo apt-get -y purge openmsx
	#remove packages that are not longer needed
	sudo apt-get -y autoremove
	#remove traces of the install
	sudo rm -rf /opt/openMSX/
	#remove settins
	sudo rm -rf ~/.openMSX/
	#remove roms 
	sudo rm -rf ~/openMSX/
}

dialog --title " openMSX 0.14.0 installer " --yesno  "This script will install openMSX 0.14.0 on your Raspberry Pi\nrunning Raspian Stretch (Raspian Lite Prefered)\n\nIt will download several files from the internet\n\nProceed at your own risk.\n\nAre you sure you want to continue?\n" 12 70

response=$?
case $response in
   0) echo -e "\e[93mInstalling openMSX 0.14.0"
	  echo -e "\e[92m";;
   1) clear
      echo -e "\e[93mProgram terminated."
	  echo -e "\e[92m"
	  exit 0;;
   255) clear
      echo -e "\e[93mProgram terminated."
	  echo -e "\e[92m"
	  exit 0;;
esac


DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

display_result() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$result" 0 0
}

while true; do
  exec 3>&1
  selection=$(dialog \
    --backtitle "Make your selection" \
    --title "- openMSX installer -" \
    --clear \
    --cancel-label "Exit" \
    --menu "Please select:" $HEIGHT $WIDTH 4 \
    "1" "Install openMSX" \
    "2" "Install GoodMSX 1 and 2 Roms" \
    "3" "Uninstall openMSX and GoodMSX Roms" \
	"4" "Update the Raspberry Pi OS and firmware"\
    2>&1 1>&3)
  exit_status=$?
  exec 3>&-
  case $exit_status in
    $DIALOG_CANCEL)
      clear
      echo -e "\e[93mProgram terminated."
      echo -e "\e[92m"
	  exit 0;;
    $DIALOG_ESC)
      clear
      echo -e "\e[93mProgram aborted." >&2
      echo -e "\e[92m"
	  exit 1;;
  esac
  case $selection in
    0 )
      clear
      echo -e "\e[93mProgram terminated."
	  echo -e "\e[92m"
	  exit 0;;
    1 )
		#install openMSX and system roms
		openMSX14Download
		installSystemRoms
		setOptimalSettings

		#test configuration 
		openmsx -testconfig -ext "MegaFlashROM_SCC+_SD"  -machine "Panasonic_FS-A1GT"

		#setup the MFR SCC+ SD with a 1GB SD-cart (emulated)
		setMFRSetup
		
		#create start script
		openMSXStartScript
		
		#exit
		dialog --title "Confirmation" --infobox  "openMSX 0.14.0 has been installed on your computer\n\nto start openMSX simply type ./start_openmsx\n\nThe standard configuration is a Panasonic_FS-A1GT with MFR SCC+ SD\n\nFind most MSX roms in the /home/pi/openmsx/roms/ folder.\n\n\nFor optimal performance set the resolution in /boot/config.txt to 640x480\n\nenjoy!" 16 80
      ;;
	2 )
		#install most ROMs
		installGoodMSXRoms
      ;;
    3 )
		dialog --title "Warning" --yesno  "openMSX will be uninstalled and all data in \n\n/opt/openmsx \n~/.openmsx \n~/openmsx\n\nwill be destroyed" 12 70

		response=$?
		case $response in
		   0) uninstallOpenMSX;;
		esac
      ;;
	 4 ) UpdatePi;;
	 5) 
  esac
done

