#!/bin/bash -e

set -x

PROJECT_NAME="openwrt"

rm -rf files
rsync -a common-files/ files/
rsync -a custom-files/ files/

mkdir -p files/root
cp .env files/root/.env

. .env

PACKAGES_ARCH=$(cat .config | grep CONFIG_TARGET_ARCH_PACKAGES | awk -F '=' '{print $2}' | sed 's/"//g')
OPENWRT_VERSION=$(cat ./include/version.mk | grep 'VERSION_NUMBER:=$(if' | awk -F ',' '{print $3}' | awk -F ')' '{print $1}')
BIG_VERSION=$(echo $OPENWRT_VERSION | awk -F '.' '{print $1"."$2}')

echo "PACKAGES_ARCH: $PACKAGES_ARCH OPENWRT_VERSION: $OPENWRT_VERSION BIG_VERSION: $BIG_VERSION"

# 添加 SSH 相关
if [ -f "files/etc/dropbear/authorized_keys" ];then
    chmod 644 files/etc/dropbear/authorized_keys
fi

# 不需要的镜像
sed -i '/CONFIG_ISO_IMAGES/ c\# CONFIG_ISO_IMAGES is not set' .config
sed -i '/CONFIG_TARGET_IMAGES_PAD/ c\# CONFIG_TARGET_IMAGES_PAD is not set' .config
sed -i '/CONFIG_VDI_IMAGES/ c\# CONFIG_VDI_IMAGES is not set' .config
sed -i '/CONFIG_VMDK_IMAGES/ c\# CONFIG_VMDK_IMAGES is not set' .config
sed -i '/CONFIG_VHDX_IMAGES/ c\# CONFIG_VHDX_IMAGES is not set' .config

# base packages
all_packages="-dnsmasq dnsmasq-full luci luci-compat luci-lib-ipkg luci-app-opkg luci-theme-bootstrap luci-lib-base luci-app-firewall openssl-util"

# printenv | grep 'CONFIG_', export all config
for config in $(printenv | grep '^CONFIG_'); do
    config_name=$(echo $config | awk -F '=' '{print $1}')
    config_value=$(echo $config | awk -F '=' '{print $2}')
    sed -i "/$config_name/ c\\$config_name=$config_value" .config
done

make info
if [ -z "$PROFILE" ]; then
    make image PACKAGES="$all_packages" FILES="files"
else
    make image PROFILE="$PROFILE" PACKAGES="$all_packages" FILES="files"
fi
