#!/bin/sh

# script can executed remotely with
# "bash <(curl -s https://raw.githubusercontent.com/madslundt/cloud-media-scripts/master/setup.sh) 

########## CONFIGURATION ##########
wget https://raw.githubusercontent.com/madslundt/cloud-media-scripts/master/config #pulls latest config from master
. "./config"
###################################
########## DOWNLOADS ##########
# Rclone
_rclone_url="https://downloads.rclone.org/rclone-current-linux-amd64.zip" #current stable rclone release

# Plexdrive
_plexdrive_url="https://github.com/dweidenfeld/plexdrive/releases/download/4.0.0/plexdrive-linux-amd64"
_plexdrive_bin="plexdrive-linux-amd64"
###################################

# Install Dependencies
apt-get update
apt-get install unionfs-fuse -y
apt-get install bc -y
apt-get install screen -y
apt-get install unzip -y
apt-get install fuse -y
apt-get install git -y

# copy git repo to root of user dir
git clone https://github.com/madslundt/cloud-media-scripts.git
cp -rf ./cloud-media-scripts/* ~/
rm -rf ./cloud-media-scripts

if [ ! -d "${rclone_dir}" ]; then
    mkdir "${rclone_dir}"
fi
wget "${_rclone_url}"
unzip rclone-*-linux-amd64.zip
cp -rf rclone-*-linux-amd64/* "${rclone_dir}/"
rm -rf rclone-*-linux-amd64.zip
rm -rf rclone-*-linux-amd64


if [ ! -d "${plexdrive_dir}" ]; then
    mkdir "${plexdrive_dir}"
fi
wget "${_plexdrive_url}"
mv "${_plexdrive_bin}" "${plexdrive_dir}/"


if [ ! -d "${local_decrypt_dir}" ]; then
    mkdir -p "${local_decrypt_dir}"
fi

if [ ! -d "${plexdrive_temp_dir}" ]; then
    mkdir -p "${plexdrive_temp_dir}"
fi


echo "\n\n--------- SETUP RCLONE ----------\n"

echo "1. Now run rclone with the command:"
echo "\t${rclone_bin} --config=${rclone_cfg} config"
echo "2. You need to setup following:"
echo "\t- Google Drive remote"
echo "\t- Crypt for your Google Drive remote named '${rclone_cloud_endpoint%?}'"
echo "\t- Crypt for your local directory ('${cloud_encrypt_dir}') named '${rclone_local_endpoint%?}'"


echo "\n\n-------- SETUP PLEXDRIVE --------\n"

mongo="--mongo-database=${mongo_database} --mongo-host=${mongo_host}"
if [ ! -z "${mongo_user}" -a "${mongo_user}" != " " ]; then
    mongo="${mongo} --mongo-user=${mongo_user} --mongo-password=${mongo_password}"
fi

echo "1. Now run plexdrive with the command:"
echo "\t${plexdrive_bin} --config=${plexdrive_dir} ${mongo} ${cloud_encrypt_dir}"
echo "2. Enter authorization"
echo "3. Cancel plexdrive by pressing CTRL+C"
echo "4. Run plexdrive with screen by running the following command:"
echo "\tscreen -dmS plexdrive ${plexdrive_bin} --config=${plexdrive_dir} ${mongo} ${plexdrive_options} ${cloud_encrypt_dir}"
echo "Exit screen session by pressing CTRL+A then D"
