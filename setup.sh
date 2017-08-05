#!/bin/sh

if [ ! -d "${./config}" ]; then
	curl -K "https://raw.githubusercontent.com/oriongrimm/cloud-media-scripts/no_encryption/config" -o ./config
fi

########## CONFIGURATION ##########
. "./config"

########## DOWNLOADS ##########
# Rclone
_rclone_url="https://downloads.rclone.org/rclone-current-linux-amd64.zip" #current stable rclone release

# Plexdrive
_plexdrive_url="https://github.com/dweidenfeld/plexdrive/releases/download/5.0.0/plexdrive-linux-amd64"
_plexdrive_bin="plexdrive-linux-amd64"

# Install Dependencies
echo "installing and or updating dependencies"
apt-get update
apt-get install unionfs-fuse -qq
apt-get install screen -qq
apt-get install unzip -qq
apt-get install fuse -qq
apt-get install git -qq
apt-get install bc -qq

go get github.com/boltdb/bolt/...

########## Directories ##########
echo "creating directories for automation"

# rclone directories from "config"
if [ ! -d "${rclone_dir}" ]; then
	mkdir "${rclone_dir}"
fi

# Cloud directories from "config"
if [ ! -d "${cloud_dir}" ]; then
	mkdir "${cloud_dir}"
fi

# Local directories from "config"
if [ ! -d "${bin_dir}" ]; then
    mkdir -p "${bin_dir}"
fi

pathadd() {
    if [ -d "$bin_dir" ] && [[ ":$PATH:" != *":$bin_dir:"* ]]; then
        PATH="${PATH:+"$PATH:"}$bin_dir"
    fi
}

# copy git repo to root of user dir
git clone https://github.com/oriongrimm/cloud-media-scripts.git "${temp_dir}/CMS"
cp -rf "${temp_dir}/CMS/plexdrive" "${cfg_dir}/plexdrive"
cp -rf "${temp_dir}/CMS/rclone" "${cfg_dir}/rclone"
cp -rf "${temp_dir}/CMS/config" "${cfg_dir}/config"
cp -rf "${temp_dir}/CMS/scripts/*" "${bin_dir}"
rm -rf "${temp_dir}/CMS"

########## Rclone ##########

echo "Installing or updating to latest stable rclone"

wget -o "${temp_dir}/rclone" "${_rclone_url}"
unzip "${temp_dir}"/rclone/rclone-*-linux-amd64.zip
cp -rf "${temp_dir}"/rclone-*-linux-amd64/rclone "${bin_dir}"/rclone
chown root:root "${bin_dir}"/rclone
chmod 755 "${bin_dir}/rclone"
mkdir -p /usr/local/share/man/man1
cp "${bin_dir}"/rclone.1 /usr/local/share/man/man1/
mandb
rm -rf "${temp_dir}"/rclone-*-linux-amd64.zip
rm -rf "${temp_dir}"/rclone-*-linux-amd64

########## Plexdrive ##########

echo "Installing Plexdrive 5.0.0"

wget -o "${temp_dir}/plexdrive" "${_plexdrive_url}"
cp -rf "'${temp_dir}'/plexdrive/'${_plexdrive_bin}'" "${bin_dir}"/plexdrive
rm -rf "${_plexdrive_bin}"

########## Intructions written to .txt ##########

echo "--------- Writing SETUP RCLONE Instrucions ----------"

echo "1. Now run rclone with the command:" >> $HOME/.config/cloud-media-scripts/setup_rclone_instructions.txt
echo "${rclone_bin} config" >> $HOME/.config/cloud-media-scripts/setup_rclone_instructions.txt
echo "2. You need to setup following:" >> $HOME/.config/cloud-media-scripts/setup_rclone_instructions.txt
echo "Google Drive remote" >> $HOME/.config/cloud-media-scripts/setup_rclone_instructions.txt

echo "-------- Writing SETUP PLEXDRIVE Instructions --------"

echo "1. Now run plexdrive with the command:" >> $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "${plexdrive_bin} --config=${plexdrive_dir} ${cloud_encrypt_dir}" >> $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "2. Enter authorization" >> $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "3. Cancel plexdrive by pressing CTRL+C" >> $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "4. Run plexdrive with screen by running the following command:" >> $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "screen -dmS plexdrive ${plexdrive_bin} ${plexdrive_options} ${cloud_encrypt_dir}" >> $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "Exit screen session by pressing CTRL+A then D" >> $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt

echo "go to $HOME/.config/cloud-media-scripts/" to see your setup help instructions

###################################################

pathadd