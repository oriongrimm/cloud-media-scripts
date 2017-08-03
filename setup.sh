#!/bin/sh

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
apt-get install bc -qq
apt-get install screen -qq
apt-get install unzip -qq
apt-get install fuse -qq
apt-get install git -qq
apt-get Install boltdb -qq

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
if [ ! -d "${local_dir}" ]; then
    mkdir -p "${local_dir}"
fi

# Media directory (FINAL) from "config"
if [ ! -d "${local_media_dir}" ]; then
    mkdir -p "${local_media_dir}"
fi

# Plexdrive directories from "config"
if [ ! -d "${plexdrive_dir}" ]; then
    mkdir "${plexdrive_dir}"
fi

if [ ! -d "${plexdrive_temp_dir}" ]; then
    mkdir -p "${plexdrive_temp_dir}"
fi

# .bin folder
if [ ! -d "${bin_dir}" ]; then
    mkdir -p "${bin_dir}"
fi

# adding ~/.bin to path
echo "PATH=${PATH}:${HOME}/.bin/" >>! ~/.bashrc

# copy git repo to root of user dir
git clone https://github.com/oriongrimm/cloud-media-scripts.git
cp -rf ./cloud-media-scripts/plexdrive "${cfg_dir}"/plexdrive
cp -rf ./cloud-media-scripts/rclone "${cfg_dir}"/rclone
cp -rf ./cloud-media-scripts/config "${cfg_dir}"/config
cp -rf ./cloud-media-scripts/scripts/* "${bin_dir}"
rm -rf ./cloud-media-scripts

########## Rclone ##########

echo "Installing or updating to latest stable rclone"

wget "${_rclone_url}"
unzip rclone-*-linux-amd64.zip
cp -rf rclone-*-linux-amd64/rclone "${bin_dir}"/rclone
chown root:root "${bin_dir}"/rclone
chmod 755 "${bin_dir}/rclone"
mkdir -p /usr/local/share/man/man1
cp "${bin_dir}"/rclone.1 /usr/local/share/man/man1/
mandb
rm -rf rclone-*-linux-amd64.zip
rm -rf rclone-*-linux-amd64

########## Plexdrive ##########

echo "Installing Plexdrive 5.0.0"

wget "${_plexdrive_url}"
cp -rf "${_plexdrive_bin}" "${bin_dir}"/plexdrive
rm -rf "${_plexdrive_bin}"

########## Intructions written to .txt ##########

echo "--------- Writing SETUP RCLONE Instrucions ----------"

echo "1. Now run rclone with the command:" >>! $HOME/.config/cloud-media-scripts/setup_rclone_instructions.txt
echo "${rclone_bin} config" >>! $HOME/.config/cloud-media-scripts/setup_rclone_instructions.txt
echo "2. You need to setup following:" >>! $HOME/.config/cloud-media-scripts/setup_rclone_instructions.txt
echo "Google Drive remote" >>! $HOME/.config/cloud-media-scripts/setup_rclone_instructions.txt
echo "Your Google Drive remote needs to be named '${rclone_cloud_endpoint%?}'" >>! $HOME/.config/cloud-media-scripts/setup_rclone_instructions.txt

echo "-------- Writing SETUP PLEXDRIVE Instructions --------"

echo "1. Now run plexdrive with the command:" >>! $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "${plexdrive_bin} --config=${plexdrive_dir} ${cloud_encrypt_dir}" >>! $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "2. Enter authorization" >>! $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "3. Cancel plexdrive by pressing CTRL+C" >>! $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "4. Run plexdrive with screen by running the following command:" >>! $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "screen -dmS plexdrive ${plexdrive_bin} ${plexdrive_options} ${cloud_encrypt_dir}" >>! $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "Exit screen session by pressing CTRL+A then D" >>! $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt

echo "go to $HOME/.config/cloud-media-scripts/" to see your setup help instructions
