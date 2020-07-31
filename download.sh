#!/bin/bash

dependencies="libxml2-dev libssl-dev zlib1g-dev libbz2-dev libfuse-dev p7zip-full"
distroinstall="n"

checkxar () {
if ! [ -x "$(command -v xar)" ]; 
then
  echo 'Xar not found, installing now.' >&2
  installxar
  exit 1
else
  echo "Xar is installed"
fi
}

distroinstallprompt () {
    echo -e "Please" "enter" "the" "install" "command" "for" "your" "distro."
    echo "E.G 'sudo apt-get install' for Debian/Ubuntu"
    echo "'sudo pacman -S' for Arch/Manjaro"
    read distroinstall
}


installxar () {
    git clone https://github.com/VantaInc/xar.git
    cd xar/xar
    sudo ./autogen.sh
    make install
    rm -rf xar
}


cleanup () {

echo "Would you like the project dirrectory to be cleaned up? (Removing files that are no longer needed)"
echo "Y/N?"
read canswer
if [ "$canswer" = "Y" ] || [ "$canswer" = "y" ]
then
    sudo rm Info.Plist InstallAssistant.pkg InstallInfo.plist MajorOSInfo.pkg SharedSupport.dmg UpdateBrain.zip dd dmg2img Bom Payload PackageInfo Scripts BuildManifest.plist
    sudo rm -rf content darling-dmg installfiles
    rm SharedSupport.dmg
fi


if [ "$answer" = "N" ] || [ "$answer" = "n" ]
then
    exit
fi
}

# Installing required dependencies 
 echo "Installing dependencies..."
distroinstallprompt
 echo "Checking if xar is installed"
    workingdir=$(pwd)
    cd /usr/local/bin/
     if ! [ -x "$(command -v ls | grep 'xar')" ]; 
     then
     echo 'Xar not found, installing now.' >&2
     sudo cp $workingdir/xar /usr/local/bin
     exit 1
     else
     echo "cmake is installed"
          fi
 echo "Checking if cmake is installed"
     if ! [ -x "$(command -v cmake)" ]; 
     then
     echo 'cmake not found, installing now.' >&2
     sudo $distroinstall cmake
     exit 1
     else
     echo "cmake is installed"
          fi
# echo "Checking if Xar is installed or not"
# checkxar
git clone https://github.com/darlinghq/darling-dmg.git
cd darling-dmg
cmake .
make
mv darling-dmg dd
mv dd ../
cd ../

# Downloads macOS
python3 fetch-macOS.py --big-sur

# # Extracts InstallAssistant.pkg into the root of the project, moves SharedSupport.dmg into it's own folder and extracts that.
# # Then finally moves BaseSystem.dmg into the root.
xar -xf InstallAssistant.pkg
echo "Checking to see if SharedSupport.dmg extracted correctly"
7z l SharedSupport.dmg
mkdir installfiles
./dd SharedSupport.dmg installfiles/
cd installfiles/com_apple_MobileAsset_MacSoftwareUpdate/
ls
7z e *.zip
mv AssetData/Restore/BaseSystem.dmg ..
cd ..
mv BaseSystem.dmg ..

# Asking if the user wants BaseSystem to be converted to a .img file to then be used be a VM.
echo "Would you like the file (BaseSystem.dmg) to be converted to an .img file for use in a KVM?"
echo "Y/N?"
read answer
if [ "$answer" = "Y" ] || [ "$answer" = "y" ]
then
    dmg2img BaseSystem.dmg BaseSystem.img
fi

if [ "$answer" = "N" ] || [ "$answer" = "n" ]
then
    cleanup
    exit
fi

#Asking if the user would like the current directory to be cleaned up
echo "Would you like the project dirrectory to be cleaned up? (Removing files that are no longer needed)"
echo "Y/N?"
read imgcanswer #img because the user requested the file to be an img, canswer to match the standard cleanup.

if [ "$imgcanswer" = "Y" ] || [ "$imgcanswer" = "y" ]
then
    sudo rm Info.Plist InstallAssistant.pkg InstallInfo.plist MajorOSInfo.pkg SharedSupport.dmg UpdateBrain.zip dd dmg2img Bom Payload PackageInfo Scripts BuildManifest.plist BaseSystem.dmg
    sudo rm -rf content darling-dmg installfiles
    rm SharedSupport.dmg
    exit
fi

if [ "$imgcanswer" = "N" ] || [ "$imgcanswer" = "n" ]
then
    exit
fi

exit
